import Foundation

struct DuplicateGroup: Identifiable, Sendable {
    let id: UUID
    let fileName: String
    let fileSize: Int64
    let fileHash: String
    let files: [ScannedFile]

    init(fileName: String, fileSize: Int64, fileHash: String, files: [ScannedFile]) {
        self.id = UUID()
        self.fileName = fileName
        self.fileSize = fileSize
        self.fileHash = fileHash
        self.files = files
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    var wastedSpace: Int64 {
        Int64(files.count - 1) * fileSize
    }

    var formattedWastedSpace: String {
        ByteCountFormatter.string(fromByteCount: wastedSpace, countStyle: .file)
    }
}
