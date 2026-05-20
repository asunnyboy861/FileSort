import Foundation
import SwiftData

@Model
final class MoveHistory {
    @Attribute(.unique) var id: UUID
    var batchDate: Date
    var movesData: Data
    var fileCount: Int
    var totalSize: Int64

    init(batchDate: Date = Date(), movesData: Data = Data(), fileCount: Int = 0, totalSize: Int64 = 0) {
        self.id = UUID()
        self.batchDate = batchDate
        self.movesData = movesData
        self.fileCount = fileCount
        self.totalSize = totalSize
    }
}

struct MoveRecord: Codable {
    let sourceURL: URL
    let destinationURL: URL
    let fileName: String
}
