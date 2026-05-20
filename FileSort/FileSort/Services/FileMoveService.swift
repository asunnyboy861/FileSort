import Foundation

actor FileMoveService {
    func executeActions(_ actions: [SortAction], conflictResolution: Conflict.ConflictResolution = .rename) async -> (successCount: Int, failCount: Int, moveRecords: [MoveRecord]) {
        var successCount = 0
        var failCount = 0
        var moveRecords: [MoveRecord] = []
        for var action in actions {
            do {
                let destURL = try resolveDestination(action.destinationURL, resolution: conflictResolution)
                let destDir = destURL.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: destDir.path) {
                    try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)
                }
                try FileManager.default.moveItem(at: action.sourceURL, to: destURL)
                action.status = .completed
                successCount += 1
                moveRecords.append(MoveRecord(sourceURL: action.sourceURL, destinationURL: destURL, fileName: action.file.url.lastPathComponent))
            } catch {
                action.status = .failed(error.localizedDescription)
                failCount += 1
            }
        }
        return (successCount, failCount, moveRecords)
    }

    func undoMoves(_ records: [MoveRecord]) async -> (successCount: Int, failCount: Int) {
        var successCount = 0
        var failCount = 0
        for record in records.reversed() {
            do {
                let sourceDir = record.sourceURL.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: sourceDir.path) {
                    try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)
                }
                try FileManager.default.moveItem(at: record.destinationURL, to: record.sourceURL)
                successCount += 1
            } catch {
                failCount += 1
            }
        }
        return (successCount, failCount)
    }

    private func resolveDestination(_ url: URL, resolution: Conflict.ConflictResolution) throws -> URL {
        switch resolution {
        case .skip:
            return url
        case .overwrite:
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            return url
        case .rename:
            return uniqueDestination(url)
        case .ask:
            return uniqueDestination(url)
        }
    }

    private func uniqueDestination(_ url: URL) -> URL {
        if !FileManager.default.fileExists(atPath: url.path) { return url }
        let directory = url.deletingLastPathComponent()
        let name = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        var counter = 1
        var newURL: URL
        repeat {
            let newName = ext.isEmpty ? "\(name) (\(counter))" : "\(name) (\(counter)).\(ext)"
            newURL = directory.appendingPathComponent(newName)
            counter += 1
        } while FileManager.default.fileExists(atPath: newURL.path) && counter < 1000
        return newURL
    }
}
