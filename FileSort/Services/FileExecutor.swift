import Foundation

actor FileExecutor {
    private let fileManager = FileManager.default

    func execute(actions: [SortAction], mode: ExecutionMode = .move, onProgress: ((Double) -> Void)? = nil) async throws -> (completedCount: Int, snapshot: UndoSnapshot?) {
        guard !actions.isEmpty else { return (0, nil) }

        let operations = actions.map { FileOperation.from(action: $0) }
        let totalCount = actions.count
        var completedCount = 0

        for action in actions {
            let destDir = action.destinationURL.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: destDir.path) {
                try fileManager.createDirectory(at: destDir, withIntermediateDirectories: true)
            }

            let finalDestination = resolveConflict(at: action.destinationURL, originalName: action.file.name)

            switch mode {
            case .move:
                try fileManager.moveItem(at: action.file.url, to: finalDestination)
            case .copy:
                try fileManager.copyItem(at: action.file.url, to: finalDestination)
            }
            completedCount += 1
            onProgress?(Double(completedCount) / Double(totalCount))
        }

        let snapshot = UndoSnapshot(
            operations: operations,
            directoryPath: actions.first?.file.url.deletingLastPathComponent().path ?? ""
        )
        return (completedCount, snapshot)
    }

    func undo(snapshot: UndoSnapshot) async throws {
        for operation in snapshot.operations.reversed() {
            if fileManager.fileExists(atPath: operation.destinationURL.path) {
                try fileManager.moveItem(at: operation.destinationURL, to: operation.sourceURL)
            }
        }
    }

    private func resolveConflict(at destination: URL, originalName: String) -> URL {
        guard fileManager.fileExists(atPath: destination.path) else { return destination }
        let nameStem = originalName.components(separatedBy: ".").dropLast().joined(separator: ".")
        let ext = destination.pathExtension
        var counter = 1
        var newDestination: URL
        repeat {
            let newName = ext.isEmpty ? "\(nameStem) (\(counter))" : "\(nameStem) (\(counter)).\(ext)"
            newDestination = destination.deletingLastPathComponent().appendingPathComponent(newName)
            counter += 1
        } while fileManager.fileExists(atPath: newDestination.path) && counter < 100
        return newDestination
    }

    enum ExecutionMode {
        case move
        case copy
    }
}
