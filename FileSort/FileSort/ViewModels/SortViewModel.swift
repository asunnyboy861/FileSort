import Foundation
import SwiftData
import Observation

@Observable
final class SortViewModel {
    var sortActions: [SortAction] = []
    var conflicts: [Conflict] = []
    var isSorting = false
    var sortError: String?
    var sortResult: SortResult?
    var conflictResolution: Conflict.ConflictResolution = .rename

    private let ruleEngineService = RuleEngineService()
    private let fileMoveService = FileMoveService()

    struct SortResult {
        let successCount: Int
        let failCount: Int
        let totalFiles: Int
        let failedFiles: [(fileName: String, error: String)]
    }

    var hasConflicts: Bool { !conflicts.isEmpty }

    var pendingActions: [SortAction] {
        sortActions.filter { if case .pending = $0.status { return true } else { return false } }
    }

    func generateSortPlan(files: [ScannedFile], rules: [SortRule], targetBaseURL: URL) async {
        isSorting = true
        sortError = nil
        let (actions, foundConflicts) = await ruleEngineService.matchFiles(files, rules: rules, targetBaseURL: targetBaseURL)
        sortActions = actions
        conflicts = foundConflicts
        isSorting = false
    }

    func executeSort(modelContext: ModelContext) async {
        isSorting = true
        sortError = nil
        let pending = sortActions.filter { action in
            if case .completed = action.status { return false }
            if case .skipped = action.status { return false }
            return true
        }
        let result = await fileMoveService.executeActions(pending, conflictResolution: conflictResolution)
        sortResult = SortResult(successCount: result.successCount, failCount: result.failCount, totalFiles: pending.count, failedFiles: result.failedActions)
        if !result.moveRecords.isEmpty {
            let undoService = UndoService()
            undoService.saveBatch(records: result.moveRecords, modelContext: modelContext)
        }
        updateWidgetData(successCount: result.successCount)
        isSorting = false
    }

    private func updateWidgetData(successCount: Int) {
        guard let defaults = UserDefaults(suiteName: AppConstants.AppGroup.id) else { return }
        let currentTotal = defaults.integer(forKey: AppConstants.Widget.fileCountKey)
        defaults.set(currentTotal + successCount, forKey: AppConstants.Widget.fileCountKey)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        defaults.set(formatter.string(from: Date()), forKey: AppConstants.Widget.lastSortDateKey)
    }

    func clearPlan() {
        sortActions = []
        conflicts = []
        sortResult = nil
        sortError = nil
    }
}
