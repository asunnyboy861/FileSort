import SwiftUI

struct RuleEditView: View {
    @Bindable var rule: SortRule
    let onSave: (SortRule) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedConditionType = SortRule.ConditionType.fileType
    @State private var selectedOperator = SortRule.ConditionOperator.equals

    var body: some View {
        Form {
            Section("Rule Name") {
                TextField("e.g., Move PDFs", text: $rule.name)
            }
            Section("Condition") {
                Picker("Match By", selection: $selectedConditionType) {
                    ForEach(SortRule.ConditionType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .onChange(of: selectedConditionType) { _, newValue in
                    rule.conditionType = newValue.rawValue
                }
                Picker("Operator", selection: $selectedOperator) {
                    ForEach(SortRule.ConditionOperator.allCases, id: \.self) { op in
                        Text(op.displayName).tag(op)
                    }
                }
                .onChange(of: selectedOperator) { _, newValue in
                    rule.conditionOperator = newValue.rawValue
                }
                TextField("Value", text: $rule.conditionValue)
            }
            Section("Destination") {
                TextField("Folder Name", text: $rule.targetFolderPath)
                    .textContentType(.none)
            }
        }
        .navigationTitle(rule.name.isEmpty ? "New Rule" : "Edit Rule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    onSave(rule)
                    dismiss()
                }
                .disabled(rule.name.isEmpty || rule.conditionValue.isEmpty || rule.targetFolderPath.isEmpty)
            }
        }
        .onAppear {
            selectedConditionType = SortRule.ConditionType(rawValue: rule.conditionType) ?? .fileType
            selectedOperator = SortRule.ConditionOperator(rawValue: rule.conditionOperator) ?? .equals
        }
    }
}
