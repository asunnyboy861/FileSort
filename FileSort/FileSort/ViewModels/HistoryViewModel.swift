import Foundation
import SwiftData
import Observation

@Observable
final class HistoryViewModel {
    var historyItems: [MoveHistory] = []
    var isLoading = false
    var isUndoing = false
    var undoError: String?

    private let undoService = UndoService()

    func loadHistory(modelContext: ModelContext) {
        isLoading = true
        historyItems = undoService.loadHistory(modelContext: modelContext)
        isLoading = false
    }

    func undoBatch(_ history: MoveHistory, modelContext: ModelContext) async -> Bool {
        isUndoing = true
        undoError = nil
        let success = await undoService.undoBatch(history, modelContext: modelContext)
        if !success {
            undoError = "Failed to undo some file moves"
        }
        loadHistory(modelContext: modelContext)
        isUndoing = false
        return success
    }

    func deleteHistory(_ history: MoveHistory, modelContext: ModelContext) {
        modelContext.delete(history)
        try? modelContext.save()
        loadHistory(modelContext: modelContext)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    func formattedSize(_ size: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
