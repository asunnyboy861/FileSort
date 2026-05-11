import Foundation
import SwiftData

@Model
final class SortRule {
    @Attribute(.unique) var id: UUID
    var name: String
    var conditionType: String
    var conditionValue: String
    var destinationPath: String
    var isEnabled: Bool
    var priority: Int
    var isPro: Bool
    var createdAt: Date

    init(name: String, conditionType: String, conditionValue: String, destinationPath: String, isEnabled: Bool = true, priority: Int = 0, isPro: Bool = false) {
        self.id = UUID()
        self.name = name
        self.conditionType = conditionType
        self.conditionValue = conditionValue
        self.destinationPath = destinationPath
        self.isEnabled = isEnabled
        self.priority = priority
        self.isPro = isPro
        self.createdAt = Date()
    }

    enum ConditionType: String, CaseIterable, Identifiable {
        case extensionType = "extension"
        case fileType = "fileType"
        case nameContains = "nameContains"
        case sizeGreaterThan = "sizeGreaterThan"
        case sizeLessThan = "sizeLessThan"
        case dateAfter = "dateAfter"
        case dateBefore = "dateBefore"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .extensionType: return "File Extension"
            case .fileType: return "File Type"
            case .nameContains: return "Name Contains"
            case .sizeGreaterThan: return "Size Greater Than"
            case .sizeLessThan: return "Size Less Than"
            case .dateAfter: return "Date After"
            case .dateBefore: return "Date Before"
            }
        }

        var isProOnly: Bool {
            switch self {
            case .sizeGreaterThan, .sizeLessThan, .dateAfter, .dateBefore:
                return true
            default:
                return false
            }
        }
    }
}
