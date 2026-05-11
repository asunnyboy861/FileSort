import SwiftUI

struct DuplicateListView: View {
    let groups: [DuplicateGroup]
    let onDelete: (ScannedFile) -> Void
    @Environment(\.dismiss) private var dismiss

    var totalWastedSpace: String {
        let total = groups.reduce(Int64(0)) { $0 + $1.wastedSpace }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("\(groups.count) duplicate groups")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        Text("\(totalWastedSpace) wasted")
                            .font(.subheadline)
                            .foregroundColor(.appDanger)
                    }
                }

                ForEach(groups) { group in
                    Section {
                        ForEach(group.files) { file in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(file.name)
                                        .font(.subheadline)
                                    Text(file.formattedSize)
                                        .font(.caption)
                                        .foregroundColor(.appTextSecondary)
                                }
                                Spacer()
                                Button {
                                    onDelete(file)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.appDanger)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: "doc.on.doc.fill")
                            Text("\(group.fileName) — \(group.formattedWastedSpace) wasted")
                        }
                    }
                }
            }
            .navigationTitle("Duplicates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
