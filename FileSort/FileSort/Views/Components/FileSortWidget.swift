import WidgetKit
import SwiftUI

struct FileSortEntry: TimelineEntry {
    let date: Date
    let fileCount: Int
    let lastSortDate: String?
}

struct FileSortProvider: TimelineProvider {
    func placeholder(in context: Context) -> FileSortEntry {
        FileSortEntry(date: Date(), fileCount: 0, lastSortDate: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (FileSortEntry) -> Void) {
        let entry = readSharedEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FileSortEntry>) -> Void) {
        let entry = readSharedEntry()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func readSharedEntry() -> FileSortEntry {
        guard let defaults = UserDefaults(suiteName: AppConstants.AppGroup.id) else {
            return FileSortEntry(date: Date(), fileCount: 0, lastSortDate: nil)
        }
        let fileCount = defaults.integer(forKey: AppConstants.Widget.fileCountKey)
        let lastSortDate = defaults.string(forKey: AppConstants.Widget.lastSortDateKey)
        return FileSortEntry(date: Date(), fileCount: fileCount, lastSortDate: lastSortDate)
    }
}

struct FileSortWidgetEntryView: View {
    let entry: FileSortEntry

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.badge.gearshape.fill")
                .font(.title2)
                .foregroundStyle(.blue)
            Text("FileSort")
                .font(.headline)
            if entry.fileCount > 0 {
                Text("\(entry.fileCount) files sorted")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Tap to sort files")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let lastDate = entry.lastSortDate {
                Text("Last: \(lastDate)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct FileSortWidget: Widget {
    let kind: String = AppConstants.Widget.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FileSortProvider()) { entry in
            FileSortWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FileSort")
        .description("Quick access to file sorting")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
