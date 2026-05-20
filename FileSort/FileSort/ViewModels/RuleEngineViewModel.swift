import Foundation
import SwiftData
import Observation
import SwiftUI

@Observable
final class RuleEngineViewModel {
    var rules: [SortRule] = []
    var isLoading = false
    var errorMessage: String?

    func loadRules(modelContext: ModelContext) {
        isLoading = true
        let descriptor = FetchDescriptor<SortRule>(sortBy: [SortDescriptor(\.priority)])
        rules = (try? modelContext.fetch(descriptor)) ?? []
        isLoading = false
    }

    func addRule(_ rule: SortRule, modelContext: ModelContext) {
        modelContext.insert(rule)
        try? modelContext.save()
        loadRules(modelContext: modelContext)
    }

    func updateRule(_ rule: SortRule, modelContext: ModelContext) {
        try? modelContext.save()
        loadRules(modelContext: modelContext)
    }

    func deleteRule(_ rule: SortRule, modelContext: ModelContext) {
        modelContext.delete(rule)
        try? modelContext.save()
        loadRules(modelContext: modelContext)
    }

    func deleteRules(at offsets: IndexSet, modelContext: ModelContext) {
        for index in offsets {
            modelContext.delete(rules[index])
        }
        try? modelContext.save()
        loadRules(modelContext: modelContext)
    }

    func toggleRule(_ rule: SortRule, modelContext: ModelContext) {
        rule.isEnabled.toggle()
        try? modelContext.save()
        loadRules(modelContext: modelContext)
    }

    func moveRule(from source: IndexSet, to destination: Int, modelContext: ModelContext) {
        rules.move(fromOffsets: source, toOffset: destination)
        for (index, rule) in rules.enumerated() {
            rule.priority = index
        }
        try? modelContext.save()
    }

    func createDefaultRules(modelContext: ModelContext) {
        let existingCount = (try? modelContext.fetchCount(FetchDescriptor<SortRule>())) ?? 0
        guard existingCount == 0 else { return }
        let defaults: [(String, String, String, String, String)] = [
            ("PDF Documents", "fileExtension", "pdf", "equals", "Documents"),
            ("Image Files", "fileType", "images", "equals", "Photos"),
            ("Video Files", "fileType", "videos", "equals", "Videos"),
            ("Audio Files", "fileType", "audio", "equals", "Audio"),
            ("Archive Files", "fileType", "archives", "equals", "Archives"),
            ("Source Code", "fileType", "code", "equals", "Code"),
        ]
        for (index, d) in defaults.enumerated() {
            let rule = SortRule(name: d.0, conditionType: d.1, conditionValue: d.2, conditionOperator: d.3, targetFolderPath: d.4, priority: index)
            modelContext.insert(rule)
        }
        try? modelContext.save()
        loadRules(modelContext: modelContext)
    }
}
