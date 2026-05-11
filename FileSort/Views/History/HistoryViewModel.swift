import SwiftUI
import SwiftData

@MainActor
@Observable
final class HistoryViewModel {
    var selectedRecord: SortHistoryRecord?
    var showExportSheet = false
    var exportText = ""

    var isPro: Bool { ProManager.shared.isPro }

    func exportHistory(records: [SortHistoryRecord]) {
        var csv = "Date,Directory,Files,Undone\n"
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        for record in records {
            csv += "\(formatter.string(from: record.timestamp)),\(record.directoryPath),\(record.fileCount),\(record.isUndone)\n"
        }
        exportText = csv
        showExportSheet = true
    }
}
