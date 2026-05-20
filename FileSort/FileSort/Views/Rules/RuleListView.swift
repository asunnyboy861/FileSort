import SwiftUI
import SwiftData

struct RuleListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var ruleVM = RuleEngineViewModel()
    @State private var showAddRule = false
    @State private var editingRule: SortRule?
    @Environment(PurchaseManager.self) private var purchaseManager

    var body: some View {
        List {
            Section {
                ForEach(ruleVM.rules) { rule in
                    RuleRow(rule: rule, onToggle: {
                        ruleVM.toggleRule(rule, modelContext: modelContext)
                    })
                    .onTapGesture { editingRule = rule }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            ruleVM.deleteRule(rule, modelContext: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove { from, to in
                    ruleVM.moveRule(from: from, to: to, modelContext: modelContext)
                }
            } header: {
                if ruleVM.rules.isEmpty {
                    Text("No rules yet. Add your first rule or use defaults.")
                }
            }
        }
        .navigationTitle("Sort Rules")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddRule = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Defaults") {
                    ruleVM.createDefaultRules(modelContext: modelContext)
                }
            }
        }
        .sheet(isPresented: $showAddRule) {
            NavigationStack {
                RuleEditView(rule: SortRule()) { rule in
                    ruleVM.addRule(rule, modelContext: modelContext)
                }
            }
        }
        .sheet(item: $editingRule) { rule in
            NavigationStack {
                RuleEditView(rule: rule) { updatedRule in
                    ruleVM.updateRule(updatedRule, modelContext: modelContext)
                }
            }
        }
        .onAppear {
            ruleVM.loadRules(modelContext: modelContext)
        }
    }
}

struct RuleRow: View {
    let rule: SortRule
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: Binding(get: { rule.isEnabled }, set: { _ in onToggle() }))
                .labelsHidden()
            VStack(alignment: .leading, spacing: 2) {
                Text(rule.name)
                    .font(.subheadline.bold())
                Text(ruleDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "folder.fill")
                .font(.caption)
                .foregroundStyle(.blue)
            Text(rule.targetFolderPath)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var ruleDescription: String {
        "\(SortRule.ConditionType(rawValue: rule.conditionType)?.displayName ?? rule.conditionType) \(SortRule.ConditionOperator(rawValue: rule.conditionOperator)?.displayName ?? rule.conditionOperator) \"\(rule.conditionValue)\""
    }
}
