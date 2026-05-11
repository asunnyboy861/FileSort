import Foundation

struct SortAction: Identifiable, Sendable {
    let id: UUID
    let file: ScannedFile
    let destinationURL: URL
    let category: FileCategory
    var isConflict: Bool
    var isDuplicate: Bool

    init(file: ScannedFile, destinationURL: URL, category: FileCategory, isConflict: Bool = false, isDuplicate: Bool = false) {
        self.id = UUID()
        self.file = file
        self.destinationURL = destinationURL
        self.category = category
        self.isConflict = isConflict
        self.isDuplicate = isDuplicate
    }
}
