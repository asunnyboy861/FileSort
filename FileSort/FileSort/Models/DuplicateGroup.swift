import Foundation

struct DuplicateGroup: Identifiable {
    let id = UUID()
    let files: [ScannedFile]
    let fileSize: Int64
    let hashValue: String

    var totalWastedSpace: Int64 {
        fileSize * Int64(max(0, files.count - 1))
    }

    var formattedWastedSpace: String {
        ByteCountFormatter.string(fromByteCount: totalWastedSpace, countStyle: .file)
    }
}
