import Foundation
import SwiftData

actor RuleEngine {
    private let fileManager = FileManager.default
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func resolve(files: [ScannedFile], baseDirectory: URL, customRules: [SortRule]) -> [SortAction] {
        var actions: [SortAction] = []
        let enabledRules = customRules.filter { $0.isEnabled }.sorted { $0.priority > $1.priority }

        for file in files {
            let destinationURL: URL
            let category: FileCategory

            if let matchedRule = matchCustomRule(file: file, rules: enabledRules) {
                category = file.category
                destinationURL = baseDirectory.appendingPathComponent(matchedRule.destinationPath).appendingPathComponent(file.name)
            } else {
                category = file.category
                destinationURL = baseDirectory.appendingPathComponent(category.folderName).appendingPathComponent(file.name)
            }

            var action = SortAction(file: file, destinationURL: destinationURL, category: category)
            action.isConflict = fileManager.fileExists(atPath: destinationURL.path)
            actions.append(action)
        }

        return actions
    }

    private func matchCustomRule(file: ScannedFile, rules: [SortRule]) -> SortRule? {
        for rule in rules {
            if matchesRule(file: file, rule: rule) {
                return rule
            }
        }
        return nil
    }

    private func matchesRule(file: ScannedFile, rule: SortRule) -> Bool {
        guard let conditionType = SortRule.ConditionType(rawValue: rule.conditionType) else { return false }
        switch conditionType {
        case .extensionType:
            return file.url.pathExtension.lowercased() == rule.conditionValue.lowercased()
        case .fileType:
            return file.category.rawValue == rule.conditionValue.lowercased()
        case .nameContains:
            return file.name.localizedCaseInsensitiveContains(rule.conditionValue)
        case .sizeGreaterThan:
            guard let size = Int64(rule.conditionValue) else { return false }
            return file.size > size
        case .sizeLessThan:
            guard let size = Int64(rule.conditionValue) else { return false }
            return file.size < size
        case .dateAfter:
            guard let date = dateFormatter.date(from: rule.conditionValue) else { return false }
            return file.modifiedDate > date
        case .dateBefore:
            guard let date = dateFormatter.date(from: rule.conditionValue) else { return false }
            return file.modifiedDate < date
        }
    }
}
