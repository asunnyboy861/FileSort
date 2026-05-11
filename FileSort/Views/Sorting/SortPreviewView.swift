import SwiftUI

struct SortPreviewView: View {
    let actions: [SortAction]
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(actions) { action in
                    HStack {
                        Image(systemName: action.category.systemImageName)
                            .foregroundColor(Color(hex: action.category.colorHex))
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(action.file.name)
                                .font(.subheadline)
                                .lineLimit(1)
                            Text(action.file.formattedSize)
                                .font(.caption2)
                                .foregroundColor(.appTextSecondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(action.category.folderName)
                                .font(.subheadline)
                                .foregroundColor(.appPrimary)
                            if action.isConflict {
                                HStack(spacing: 2) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Conflict")
                                }
                                .font(.caption2)
                                .foregroundColor(.appWarning)
                            }
                            if action.isDuplicate {
                                HStack(spacing: 2) {
                                    Image(systemName: "doc.on.doc.fill")
                                    Text("Duplicate")
                                }
                                .font(.caption2)
                                .foregroundColor(.appDanger)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .navigationTitle("Sort Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        onConfirm()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
