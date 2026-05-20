import Foundation

struct SortAction: Identifiable {
    let id = UUID()
    let sourceURL: URL
    let destinationURL: URL
    let file: ScannedFile
    let matchedRuleName: String?
    var status: ActionStatus = .pending

    enum ActionStatus {
        case pending
        case completed
        case failed(String)
        case skipped
        case conflict
    }
}

struct Conflict: Identifiable {
    let id = UUID()
    let action: SortAction
    let existingFileURL: URL
    let resolution: ConflictResolution = .ask

    enum ConflictResolution {
        case skip
        case rename
        case overwrite
        case ask
    }
}
