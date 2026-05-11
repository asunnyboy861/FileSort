import Foundation
import SwiftData

@Model
final class FolderTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var templateString: String
    var createdAt: Date

    init(name: String, templateString: String) {
        self.id = UUID()
        self.name = name
        self.templateString = templateString
        self.createdAt = Date()
    }

    func resolvePath(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        var result = templateString
        formatter.dateFormat = "yyyy"
        result = result.replacingOccurrences(of: "{YYYY}", with: formatter.string(from: date))
        formatter.dateFormat = "MM"
        result = result.replacingOccurrences(of: "{MM}", with: formatter.string(from: date))
        formatter.dateFormat = "dd"
        result = result.replacingOccurrences(of: "{DD}", with: formatter.string(from: date))
        return result
    }
}
