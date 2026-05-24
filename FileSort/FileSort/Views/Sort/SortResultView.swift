import SwiftUI
import SwiftData

struct SortResultView: View {
    let successCount: Int
    let failCount: Int
    let totalFiles: Int
    let failedFiles: [(fileName: String, error: String)]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CelebrationView(
                    movedCount: successCount,
                    savedSpace: "\(successCount) of \(totalFiles) files"
                )
                statsSection
                if !failedFiles.isEmpty {
                    failedFilesSection
                }
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Sort Complete")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatsCardView(title: "Moved", value: "\(successCount)", icon: "checkmark.circle.fill", color: .green)
            if failCount > 0 {
                StatsCardView(title: "Failed", value: "\(failCount)", icon: "xmark.circle.fill", color: .red)
            }
            StatsCardView(title: "Total", value: "\(totalFiles)", icon: "doc.fill", color: .blue)
        }
    }

    private var failedFilesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Failed Files")
                .font(.subheadline.bold())
                .foregroundStyle(.red)
            ForEach(failedFiles, id: \.fileName) { item in
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                    Text(item.fileName)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Text(item.error)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background(.red.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            NavigationLink {
                HistoryView()
            } label: {
                Label("View History", systemImage: "clock.arrow.circlepath")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
