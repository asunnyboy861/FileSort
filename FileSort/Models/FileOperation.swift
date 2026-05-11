import Foundation

struct FileOperation: Codable, Sendable {
    let sourceURL: URL
    let destinationURL: URL
    let fileName: String

    static func from(action: SortAction) -> FileOperation {
        FileOperation(
            sourceURL: action.file.url,
            destinationURL: action.destinationURL,
            fileName: action.file.name
        )
    }
}
