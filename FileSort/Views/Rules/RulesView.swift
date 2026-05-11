import SwiftUI
import SwiftData

struct RulesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SortRule.priority, order: .reverse) private var rules: [SortRule]
    @State private var viewModel = RulesViewModel()
    @State private var showProUpgrade = false

    var body: some View {
        List {
            if rules.isEmpty {
                ContentUnavailableView(
                    "No Rules Yet",
                    systemImage: "slider.horizontal.3",
                    description: Text("Create custom rules to organize files your way")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(rules) { rule in
                    RuleRow(rule: rule, isPro: viewModel.isPro) {
                        viewModel.toggleRule(rule)
                    } onEdit: {
                        viewModel.editRule(rule)
                    } onUpgrade: {
                        showProUpgrade = true
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteRule(rule, modelContext: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Rules")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.resetForm()
                    viewModel.showRuleEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showRuleEditor) {
            RuleEditView(viewModel: viewModel) {
                viewModel.saveRule(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showProUpgrade) {
            ProUpgradeView()
        }
    }
}

struct RuleRow: View {
    let rule: SortRule
    let isPro: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onUpgrade: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: Binding(get: { rule.isEnabled }, set: { _ in onToggle() }))
                .labelsHidden()

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(rule.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if rule.isPro && !isPro {
                        proBadge
                    }
                }
                Text(ruleDescription)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Button { onEdit() } label: {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(.appAccent)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if rule.isPro && !isPro {
                onUpgrade()
            } else {
                onEdit()
            }
        }
    }

    private var proBadge: some View {
        Text("PRO")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(Color.appSecondary)
            .cornerRadius(3)
    }

    private var ruleDescription: String {
        let type = SortRule.ConditionType(rawValue: rule.conditionType) ?? .extensionType
        return "IF \(type.displayName) = \"\(rule.conditionValue)\" → \(rule.destinationPath)"
    }
}
