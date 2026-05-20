import Foundation
import Observation

@Observable
final class ScannerViewModel {
    var scannedFiles: [ScannedFile] = []
    var isScanning = false
    var scanError: String?
    var selectedDirectory: URL?
    var categoryCounts: [FileCategory: Int] = [:]
    var totalSize: Int64 = 0

    private let scanService = FileScanService()

    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    var categoryBreakdown: [(category: FileCategory, count: Int, percentage: Double)] {
        let total = scannedFiles.count
        return FileCategory.allCases.compactMap { cat in
            let count = categoryCounts[cat] ?? 0
            guard count > 0 else { return nil }
            return (cat, count, Double(count) / Double(total) * 100)
        }.sorted { $0.count > $1.count }
    }

    func scanDirectory(_ url: URL) async {
        isScanning = true
        scanError = nil
        selectedDirectory = url
        do {
            let files = try await scanService.scanDirectory(url)
            scannedFiles = files
            categoryCounts = Dictionary(grouping: files) { $0.category }.mapValues { $0.count }
            totalSize = files.reduce(0) { $0 + $1.size }
        } catch {
            scanError = error.localizedDescription
        }
        isScanning = false
    }

    func clearResults() {
        scannedFiles = []
        categoryCounts = [:]
        totalSize = 0
        scanError = nil
    }
}
