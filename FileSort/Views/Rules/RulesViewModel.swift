import SwiftUI
import SwiftData

@MainActor
@Observable
final class RulesViewModel {
    var newRuleName = ""
    var newConditionType = SortRule.ConditionType.extensionType
    var newConditionValue = ""
    var newDestinationPath = ""
    var showRuleEditor = false
    var editingRule: SortRule?

    var isPro: Bool { ProManager.shared.isPro }

    func saveRule(modelContext: ModelContext) {
        let rule: SortRule
        if let editing = editingRule {
            editing.name = newRuleName
            editing.conditionType = newConditionType.rawValue
            editing.conditionValue = newConditionValue
            editing.destinationPath = newDestinationPath
            editing.isPro = newConditionType.isProOnly
            rule = editing
        } else {
            rule = SortRule(
                name: newRuleName,
                conditionType: newConditionType.rawValue,
                conditionValue: newConditionValue,
                destinationPath: newDestinationPath,
                isPro: newConditionType.isProOnly
            )
            modelContext.insert(rule)
        }
        try? modelContext.save()
        resetForm()
    }

    func deleteRule(_ rule: SortRule, modelContext: ModelContext) {
        modelContext.delete(rule)
        try? modelContext.save()
    }

    func toggleRule(_ rule: SortRule) {
        rule.isEnabled.toggle()
        try? rule.modelContext?.save()
    }

    func editRule(_ rule: SortRule) {
        editingRule = rule
        newRuleName = rule.name
        newConditionType = SortRule.ConditionType(rawValue: rule.conditionType) ?? .extensionType
        newConditionValue = rule.conditionValue
        newDestinationPath = rule.destinationPath
        showRuleEditor = true
    }

    func resetForm() {
        newRuleName = ""
        newConditionType = .extensionType
        newConditionValue = ""
        newDestinationPath = ""
        editingRule = nil
        showRuleEditor = false
    }
}
