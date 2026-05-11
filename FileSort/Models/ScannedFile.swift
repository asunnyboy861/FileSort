import Foundation

struct ScannedFile: Identifiable, Sendable {
    let id: UUID
    let url: URL
    let name: String
    let size: Int64
    let modifiedDate: Date
    let category: FileCategory

    init(url: URL, name: String, size: Int64, modifiedDate: Date, category: FileCategory) {
        self.id = UUID()
        self.url = url
        self.name = name
        self.size = size
        self.modifiedDate = modifiedDate
        self.category = category
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
