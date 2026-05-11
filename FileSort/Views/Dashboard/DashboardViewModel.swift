import SwiftUI
import SwiftData
import PhotosUI

@MainActor
@Observable
final class DashboardViewModel {
    var messyFileCount: Int = 0
    var scannedFiles: [ScannedFile] = []
    var sortActions: [SortAction] = []
    var isScanning: Bool = false
    var isSorting: Bool = false
    var sortProgress: Double = 0.0
    var showResult: Bool = false
    var showPreview: Bool = false
    var showDuplicateView: Bool = false
    var duplicateGroups: [DuplicateGroup] = []
    var lastUndoSnapshot: UndoSnapshot?
    var undoStack: [UndoSnapshot] = []
    var canUndo: Bool = false
    var errorMessage: String?
    var selectedDirectory: URL?
    var categoryStats: [FileCategory: Int] = [:]

    private let scanEngine = FileScanEngine()
    private let ruleEngine = RuleEngine()
    private let fileExecutor = FileExecutor()
    private let duplicateDetector = DuplicateDetector()
    private let bookmarkManager = BookmarkManager()
    private let maxUndoStack = 50
    let freeFileLimit = 50

    var isPro: Bool { ProManager.shared.isPro }

    var sortMode: FileExecutor.ExecutionMode {
        let modeString = UserDefaults.standard.string(forKey: "sortMode") ?? "move"
        return modeString == "copy" ? .copy : .move
    }

    func scanDirectory(_ url: URL) async {
        isScanning = true
        errorMessage = nil
        do {
            scannedFiles = try await scanEngine.scan(directory: url)
            messyFileCount = scannedFiles.count
            categoryStats = Dictionary(grouping: scannedFiles) { $0.category }.mapValues { $0.count }
        } catch {
            errorMessage = error.localizedDescription
        }
        isScanning = false
    }

    func prepareSort(rules: [SortRule], baseDirectory: URL) async {
        guard !scannedFiles.isEmpty else { return }
        let filesToSort: [ScannedFile]
        if !isPro && scannedFiles.count > freeFileLimit {
            filesToSort = Array(scannedFiles.prefix(freeFileLimit))
        } else {
            filesToSort = scannedFiles
        }
        sortActions = await ruleEngine.resolve(files: filesToSort, baseDirectory: baseDirectory, customRules: rules)
        showPreview = true
    }

    func executeSort(modelContext: ModelContext) async {
        guard !sortActions.isEmpty else { return }
        isSorting = true
        sortProgress = 0.0

        do {
            let result = try await fileExecutor.execute(actions: sortActions, mode: sortMode) { [weak self] progress in
                Task { @MainActor in
                    self?.sortProgress = progress
                }
            }
            if let snapshot = result.snapshot {
                undoStack.append(snapshot)
                if undoStack.count > maxUndoStack {
                    undoStack.removeFirst()
                }
                lastUndoSnapshot = snapshot
                canUndo = true
            }

            let historyRecord = SortHistoryRecord(
                directoryPath: sortActions.first?.file.url.deletingLastPathComponent().path ?? "",
                fileCount: result.completedCount,
                categoryCounts: categoryStats
            )
            modelContext.insert(historyRecord)

            sortProgress = 1.0
            showResult = true
            scannedFiles = []
            messyFileCount = 0
            categoryStats = [:]
        } catch {
            errorMessage = error.localizedDescription
        }
        isSorting = false
    }

    func undoLast() async {
        guard let snapshot = undoStack.last else { return }
        do {
            try await fileExecutor.undo(snapshot: snapshot)
            undoStack.removeLast()
            lastUndoSnapshot = undoStack.last
            canUndo = !undoStack.isEmpty
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func undoSpecific(_ snapshot: UndoSnapshot) async {
        do {
            try await fileExecutor.undo(snapshot: snapshot)
            if let index = undoStack.firstIndex(where: { $0.id == snapshot.id }) {
                undoStack.remove(at: index)
            }
            lastUndoSnapshot = undoStack.last
            canUndo = !undoStack.isEmpty
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func findDuplicates() async {
        guard isPro else { return }
        duplicateGroups = await duplicateDetector.findDuplicates(in: scannedFiles)
        showDuplicateView = !duplicateGroups.isEmpty
    }

    func deleteDuplicate(_ file: ScannedFile) async {
        do {
            try FileManager.default.removeItem(at: file.url)
            if let groupIndex = duplicateGroups.firstIndex(where: { $0.files.contains(where: { $0.id == file.id }) }) {
                let group = duplicateGroups[groupIndex]
                duplicateGroups[groupIndex] = DuplicateGroup(
                    fileName: group.fileName,
                    fileSize: group.fileSize,
                    fileHash: group.fileHash,
                    files: group.files.filter { $0.id != file.id }
                )
                if duplicateGroups[groupIndex].files.count < 2 {
                    duplicateGroups.remove(at: groupIndex)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveBookmark(for url: URL) async {
        _ = try? await bookmarkManager.saveBookmark(for: url)
    }
}
