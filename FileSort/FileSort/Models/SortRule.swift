import Foundation
import SwiftData

@Model
final class SortRule {
    @Attribute(.unique) var id: UUID
    var name: String
    var conditionType: String
    var conditionValue: String
    var conditionOperator: String
    var targetFolderPath: String
    var priority: Int
    var isEnabled: Bool
    var createdAt: Date

    init(name: String = "", conditionType: String = "fileType", conditionValue: String = "", conditionOperator: String = "equals", targetFolderPath: String = "", priority: Int = 0, isEnabled: Bool = true) {
        self.id = UUID()
        self.name = name
        self.conditionType = conditionType
        self.conditionValue = conditionValue
        self.conditionOperator = conditionOperator
        self.targetFolderPath = targetFolderPath
        self.priority = priority
        self.isEnabled = isEnabled
        self.createdAt = Date()
    }

    enum ConditionType: String, CaseIterable {
        case fileType = "fileType"
        case fileName = "fileName"
        case fileExtension = "fileExtension"
        case fileSize = "fileSize"
        case creationDate = "creationDate"
        case modificationDate = "modificationDate"

        var displayName: String {
            switch self {
            case .fileType: return "File Type"
            case .fileName: return "File Name"
            case .fileExtension: return "Extension"
            case .fileSize: return "File Size"
            case .creationDate: return "Created Date"
            case .modificationDate: return "Modified Date"
            }
        }
    }

    enum ConditionOperator: String, CaseIterable {
        case equals = "equals"
        case contains = "contains"
        case startsWith = "startsWith"
        case greaterThan = "greaterThan"
        case lessThan = "lessThan"

        var displayName: String {
            switch self {
            case .equals: return "Equals"
            case .contains: return "Contains"
            case .startsWith: return "Starts With"
            case .greaterThan: return "Greater Than"
            case .lessThan: return "Less Than"
            }
        }
    }
}
