import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var historyVM = HistoryViewModel()
    @Environment(PurchaseManager.self) private var purchaseManager

    var body: some View {
        List {
            if historyVM.historyItems.isEmpty {
                ContentUnavailableView("No History", systemImage: "clock.arrow.circlepath", description: Text("Sort history will appear here"))
            } else {
                ForEach(historyVM.historyItems) { item in
                    HistoryRow(item: item, formattedDate: historyVM.formattedDate(item.batchDate), formattedSize: historyVM.formattedSize(item.totalSize))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                historyVM.deleteHistory(item, modelContext: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                Task { _ = await historyVM.undoBatch(item, modelContext: modelContext) }
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.backward")
                            }
                            .tint(.orange)
                            .disabled(!purchaseManager.isPremium)
                        }
                }
            }
        }
        .navigationTitle("History")
        .overlay {
            if historyVM.isUndoing {
                ProgressView("Undoing...")
            }
        }
        .onAppear {
            historyVM.loadHistory(modelContext: modelContext)
        }
    }
}

struct HistoryRow: View {
    let item: MoveHistory
    let formattedDate: String
    let formattedSize: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.branch")
                .font(.title3)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(item.fileCount) files moved")
                    .font(.subheadline.bold())
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(formattedSize)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
