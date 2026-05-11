import Foundation
import SwiftData

@Model
final class SortHistoryRecord {
    @Attribute(.unique) var id: UUID
    var directoryPath: String
    var fileCount: Int
    var categoryCounts: Data
    var timestamp: Date
    var isUndone: Bool

    init(directoryPath: String, fileCount: Int, categoryCounts: [FileCategory: Int], timestamp: Date = Date(), isUndone: Bool = false) {
        self.id = UUID()
        self.directoryPath = directoryPath
        self.fileCount = fileCount
        self.timestamp = timestamp
        self.isUndone = isUndone
        do {
            self.categoryCounts = try JSONEncoder().encode(categoryCounts.mapKeys { $0.rawValue })
        } catch {
            self.categoryCounts = Data()
        }
    }

    func getCategoryCounts() -> [FileCategory: Int] {
        guard let dict = try? JSONDecoder().decode([String: Int].self, from: categoryCounts) else { return [:] }
        return dict.compactMapKeys { FileCategory(rawValue: $0) }
    }
}

extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        var result = [T: Value]()
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }

    func compactMapKeys<T: Hashable>(_ transform: (Key) -> T?) -> [T: Value] {
        var result = [T: Value]()
        for (key, value) in self {
            if let newKey = transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}
