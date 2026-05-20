import Foundation

actor RuleEngineService {
    func matchFiles(_ files: [ScannedFile], rules: [SortRule], targetBaseURL: URL) -> ([SortAction], [Conflict]) {
        var actions: [SortAction] = []
        var conflicts: [Conflict] = []
        let sortedRules = rules.filter(\.isEnabled).sorted { $0.priority < $1.priority }
        for file in files {
            if let rule = findFirstMatchingRule(file: file, rules: sortedRules) {
                let destFolder = targetBaseURL.appendingPathComponent(rule.targetFolderPath)
                let destURL = destFolder.appendingPathComponent(file.url.lastPathComponent)
                let action = SortAction(sourceURL: file.url, destinationURL: destURL, file: file, matchedRuleName: rule.name)
                if FileManager.default.fileExists(atPath: destURL.path) {
                    let conflict = Conflict(action: action, existingFileURL: destURL)
                    conflicts.append(conflict)
                    actions.append(SortAction(sourceURL: file.url, destinationURL: destURL, file: file, matchedRuleName: rule.name, status: .conflict))
                } else {
                    actions.append(action)
                }
            } else {
                let destFolder = targetBaseURL.appendingPathComponent(file.category.defaultFolderName)
                let destURL = destFolder.appendingPathComponent(file.url.lastPathComponent)
                let action = SortAction(sourceURL: file.url, destinationURL: destURL, file: file, matchedRuleName: nil)
                if FileManager.default.fileExists(atPath: destURL.path) {
                    let conflict = Conflict(action: action, existingFileURL: destURL)
                    conflicts.append(conflict)
                    actions.append(SortAction(sourceURL: file.url, destinationURL: destURL, file: file, matchedRuleName: nil, status: .conflict))
                } else {
                    actions.append(action)
                }
            }
        }
        return (actions, conflicts)
    }

    private func findFirstMatchingRule(file: ScannedFile, rules: [SortRule]) -> SortRule? {
        for rule in rules {
            if matchesRule(file: file, rule: rule) {
                return rule
            }
        }
        return nil
    }

    private func matchesRule(file: ScannedFile, rule: SortRule) -> Bool {
        let value: String
        switch rule.conditionType {
        case "fileType":
            value = file.category.rawValue
        case "fileName":
            value = file.displayName
        case "fileExtension":
            value = file.fileExtension
        case "fileSize":
            return compareSize(file.size, with: rule.conditionValue, operator: rule.conditionOperator)
        case "creationDate":
            return compareDate(file.creationDate, with: rule.conditionValue, operator: rule.conditionOperator)
        case "modificationDate":
            return compareDate(file.modificationDate, with: rule.conditionValue, operator: rule.conditionOperator)
        default:
            return false
        }
        return compareString(value, with: rule.conditionValue, operator: rule.conditionOperator)
    }

    private func compareString(_ value: String, with target: String, operator op: String) -> Bool {
        switch op {
        case "equals": return value.lowercased() == target.lowercased()
        case "contains": return value.lowercased().contains(target.lowercased())
        case "startsWith": return value.lowercased().hasPrefix(target.lowercased())
        default: return false
        }
    }

    private func compareSize(_ size: Int64, with target: String, operator op: String) -> Bool {
        guard let targetSize = parseSize(target) else { return false }
        switch op {
        case "greaterThan": return size > targetSize
        case "lessThan": return size < targetSize
        case "equals": return size == targetSize
        default: return false
        }
    }

    private func compareDate(_ date: Date?, with target: String, operator op: String) -> Bool {
        guard let date = date, let targetDate = parseDate(target) else { return false }
        switch op {
        case "greaterThan": return date > targetDate
        case "lessThan": return date < targetDate
        case "equals": return Calendar.current.isDate(date, inSameDayAs: targetDate)
        default: return false
        }
    }

    private func parseSize(_ string: String) -> Int64? {
        let lower = string.lowercased().trimmingCharacters(in: .whitespaces)
        if lower.hasSuffix("mb") {
            return Int64(Double(lower.replacingOccurrences(of: "mb", with: "")) ?? 0) * 1024 * 1024
        } else if lower.hasSuffix("kb") {
            return Int64(Double(lower.replacingOccurrences(of: "kb", with: "")) ?? 0) * 1024
        } else if lower.hasSuffix("gb") {
            return Int64(Double(lower.replacingOccurrences(of: "gb", with: "")) ?? 0) * 1024 * 1024 * 1024
        }
        return Int64(lower)
    }

    private func parseDate(_ string: String) -> Date? {
        let formatters = [
            { () -> DateFormatter in let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f },
            { () -> DateFormatter in let f = DateFormatter(); f.dateFormat = "MM/dd/yyyy"; return f },
            { () -> DateFormatter in let f = DateFormatter(); f.dateStyle = .medium; return f }
        ]
        for factory in formatters {
            if let date = factory().date(from: string) { return date }
        }
        return nil
    }
}
