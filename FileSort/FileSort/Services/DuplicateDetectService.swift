import Foundation
import CryptoKit

struct DuplicateDetectService {
    func findDuplicates(in files: [ScannedFile]) async -> [DuplicateGroup] {
        let sizeGroups = Dictionary(grouping: files) { $0.size }
        let potentialDuplicates = sizeGroups.filter { $0.value.count > 1 && $0.key > 0 }
        var duplicateGroups: [DuplicateGroup] = []
        for (_, filesWithSameSize) in potentialDuplicates {
            let hashGroups = await computeHashes(files: filesWithSameSize)
            for (_, filesWithSameHash) in hashGroups where filesWithSameHash.count > 1 {
                let group = DuplicateGroup(
                    files: filesWithSameHash,
                    fileSize: filesWithSameHash.first?.size ?? 0,
                    hashValue: filesWithSameHash.first?.url.lastPathComponent ?? ""
                )
                duplicateGroups.append(group)
            }
        }
        return duplicateGroups.sorted { $0.totalWastedSpace > $1.totalWastedSpace }
    }

    private func computeHashes(files: [ScannedFile]) async -> [String: [ScannedFile]] {
        await withTaskGroup(of: (String, ScannedFile?).self) { group in
            for file in files {
                group.addTask {
                    if let hash = Self.sha256(of: file.url) {
                        return (hash, file)
                    }
                    return ("", nil)
                }
            }
            var hashMap: [String: [ScannedFile]] = [:]
            for await (hash, file) in group {
                guard let file = file, !hash.isEmpty else { continue }
                hashMap[hash, default: []].append(file)
            }
            return hashMap
        }
    }

    private static func sha256(of url: URL) -> String? {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func deleteFiles(_ urls: [URL]) async -> (deleted: Int, failed: Int) {
        await withCheckedContinuation { continuation in
            var deleted = 0
            var failed = 0
            for url in urls {
                do {
                    try FileManager.default.removeItem(at: url)
                    deleted += 1
                } catch {
                    failed += 1
                }
            }
            continuation.resume(returning: (deleted, failed))
        }
    }
}
