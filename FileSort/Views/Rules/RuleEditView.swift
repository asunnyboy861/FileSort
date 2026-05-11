import SwiftUI

struct RuleEditView: View {
    @Bindable var viewModel: RulesViewModel
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showProUpgrade = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Rule Details") {
                    TextField("Rule Name", text: $viewModel.newRuleName)

                    Picker("Condition", selection: $viewModel.newConditionType) {
                        ForEach(SortRule.ConditionType.allCases) { type in
                            HStack {
                                Text(type.displayName)
                                if type.isProOnly {
                                    Text("PRO")
                                        .font(.caption2)
                                        .foregroundColor(.appSecondary)
                                }
                            }
                            .tag(type)
                        }
                    }

                    if viewModel.newConditionType == .fileType {
                        Picker("File Type", selection: $viewModel.newConditionValue) {
                            ForEach(FileCategory.allCases) { cat in
                                Text(cat.displayName).tag(cat.rawValue)
                            }
                        }
                    } else {
                        TextField(conditionPlaceholder, text: $viewModel.newConditionValue)
                    }

                    TextField("Destination Folder", text: $viewModel.newDestinationPath)
                }

                Section {
                    Button {
                        if viewModel.newConditionType.isProOnly && !viewModel.isPro {
                            showProUpgrade = true
                        } else if !viewModel.newRuleName.isEmpty && !viewModel.newConditionValue.isEmpty && !viewModel.newDestinationPath.isEmpty {
                            onSave()
                            dismiss()
                        }
                    } label: {
                        Text(viewModel.editingRule == nil ? "Create Rule" : "Save Changes")
                            .fontWeight(.semibold)
                    }
                    .disabled(viewModel.newRuleName.isEmpty || viewModel.newConditionValue.isEmpty || viewModel.newDestinationPath.isEmpty)
                }
            }
            .navigationTitle(viewModel.editingRule == nil ? "New Rule" : "Edit Rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetForm()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showProUpgrade) {
                ProUpgradeView()
            }
        }
    }

    private var conditionPlaceholder: String {
        switch viewModel.newConditionType {
        case .extensionType: return "e.g. pdf, jpg, mp4"
        case .nameContains: return "e.g. screenshot, invoice"
        case .sizeGreaterThan: return "Size in bytes (e.g. 1048576 for 1MB)"
        case .sizeLessThan: return "Size in bytes"
        case .dateAfter: return "YYYY-MM-DD"
        case .dateBefore: return "YYYY-MM-DD"
        default: return "Value"
        }
    }
}
