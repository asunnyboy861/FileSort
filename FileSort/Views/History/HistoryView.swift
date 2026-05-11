import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SortHistoryRecord.timestamp, order: .reverse) private var records: [SortHistoryRecord]
    @State private var viewModel = HistoryViewModel()
    @State private var showProUpgrade = false

    var body: some View {
        List {
            if records.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your sorting history will appear here")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(records) { record in
                    HistoryRow(record: record, isPro: viewModel.isPro)
                        .onTapGesture {
                            if viewModel.isPro {
                                viewModel.selectedRecord = record
                            } else {
                                showProUpgrade = true
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(record)
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !records.isEmpty && viewModel.isPro {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.exportHistory(records: records)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ActivityViewController(activityItems: [viewModel.exportText])
        }
        .sheet(isPresented: $showProUpgrade) {
            ProUpgradeView()
        }
    }
}

struct HistoryRow: View {
    let record: SortHistoryRecord
    let isPro: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.isUndone ? "arrow.uturn.backward.circle" : "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(record.isUndone ? .appWarning : .appSuccess)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.directoryURL.lastPathComponent)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text("\(record.fileCount) files sorted")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(record.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                if !isPro {
                    Text("PRO")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.appSecondary)
                        .cornerRadius(3)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

extension SortHistoryRecord {
    var directoryURL: URL {
        URL(fileURLWithPath: directoryPath)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
