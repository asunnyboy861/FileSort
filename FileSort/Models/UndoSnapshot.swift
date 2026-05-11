import Foundation

struct UndoSnapshot: Codable, Identifiable, Sendable {
    let id: UUID
    let timestamp: Date
    let operations: [FileOperation]
    let directoryPath: String
    let fileCount: Int

    init(operations: [FileOperation], directoryPath: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.operations = operations
        self.directoryPath = directoryPath
        self.fileCount = operations.count
    }
}
