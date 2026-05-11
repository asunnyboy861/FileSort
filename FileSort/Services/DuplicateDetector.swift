import Foundation
import CryptoKit

actor DuplicateDetector {
    func findDuplicates(in files: [ScannedFile]) async -> [DuplicateGroup] {
        let sizeGroups = Dictionary(grouping: files) { $0.size }
        let potentialDuplicates = sizeGroups.filter { $0.value.count > 1 }

        var duplicateGroups: [DuplicateGroup] = []

        for (_, sameSizeFiles) in potentialDuplicates {
            let hashGroups = Dictionary(grouping: sameSizeFiles) { file in
                computeSHA256(for: file.url)
            }

            for (hash, duplicateFiles) in hashGroups where duplicateFiles.count > 1 {
                let group = DuplicateGroup(
                    fileName: duplicateFiles[0].name,
                    fileSize: duplicateFiles[0].size,
                    fileHash: hash,
                    files: duplicateFiles
                )
                duplicateGroups.append(group)
            }
        }

        return duplicateGroups.sorted { $0.wastedSpace > $1.wastedSpace }
    }

    private func computeSHA256(for url: URL) -> String {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return UUID().uuidString }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
