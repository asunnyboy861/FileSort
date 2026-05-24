import Foundation
import Observation

@Observable
final class DuplicateViewModel {
    var duplicateGroups: [DuplicateGroup] = []
    var isScanning = false
    var scanError: String?
    var totalWastedSpace: Int64 = 0
    var selectedForDeletion: Set<URL> = []
    var scanProgress: Double = 0

    private let duplicateService = DuplicateDetectService()

    var formattedWastedSpace: String {
        ByteCountFormatter.string(fromByteCount: totalWastedSpace, countStyle: .file)
    }

    var duplicateCount: Int {
        duplicateGroups.reduce(0) { $0 + $1.files.count - 1 }
    }

    func scanForDuplicates(in files: [ScannedFile]) async {
        isScanning = true
        scanError = nil
        selectedForDeletion.removeAll()
        scanProgress = 0
        let groups = await duplicateService.findDuplicates(in: files) { current, total in
            self.scanProgress = total > 0 ? Double(current) / Double(total) : 0
        }
        duplicateGroups = groups
        totalWastedSpace = groups.reduce(0) { $0 + $1.totalWastedSpace }
        isScanning = false
    }

    func toggleSelection(url: URL) {
        if selectedForDeletion.contains(url) {
            selectedForDeletion.remove(url)
        } else {
            selectedForDeletion.insert(url)
        }
    }

    func selectDuplicatesInGroup(_ group: DuplicateGroup, keeping first: ScannedFile) {
        for file in group.files where file.url != first.url {
            selectedForDeletion.insert(file.url)
        }
    }

    func deleteSelected() async -> (deleted: Int, failed: Int) {
        let urls = Array(selectedForDeletion)
        let result = await duplicateService.deleteFiles(urls)
        selectedForDeletion.removeAll()
        duplicateGroups = duplicateGroups.map { group in
            let remaining = group.files.filter { !urls.contains($0.url) }
            if remaining.count < 2 { return nil }
            return DuplicateGroup(files: remaining, fileSize: group.fileSize, hashValue: group.hashValue)
        }.compactMap { $0 }
        totalWastedSpace = duplicateGroups.reduce(0) { $0 + $1.totalWastedSpace }
        return result
    }

    func clearResults() {
        duplicateGroups = []
        totalWastedSpace = 0
        selectedForDeletion.removeAll()
        scanError = nil
    }
}
