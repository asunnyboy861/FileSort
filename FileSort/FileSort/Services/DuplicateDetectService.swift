import Foundation
import CryptoKit

struct DuplicateDetectService {
    func findDuplicates(
        in files: [ScannedFile],
        progressHandler: @MainActor (Int, Int) -> Void = { _, _ in }
    ) async -> [DuplicateGroup] {
        let sizeGroups = Dictionary(grouping: files) { $0.size }
        let potentialDuplicates = sizeGroups.filter { $0.value.count > 1 && $0.key > 0 }
        let total = potentialDuplicates.count
        var duplicateGroups: [DuplicateGroup] = []
        for (index, (_, filesWithSameSize)) in potentialDuplicates.enumerated() {
            await MainActor.run { progressHandler(index + 1, total) }
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
                    let hash: String?
                    if file.size > AppConstants.Limits.largeFileThreshold {
                        hash = Self.partialSHA256(of: file.url)
                    } else {
                        hash = Self.sha256(of: file.url)
                    }
                    if let hash { return (hash, file) }
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

    private static func partialSHA256(of url: URL) -> String? {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
        let headSize = min(AppConstants.Limits.partialHashSize, data.count)
        let headData = data.prefix(headSize)
        let tailSize = min(AppConstants.Limits.partialHashSize, max(0, data.count - headSize))
        let tailData = data.suffix(tailSize)
        var hasher = SHA256()
        hasher.update(data: headData)
        if tailSize > 0 {
            hasher.update(data: tailData)
        }
        let hash = hasher.finalize()
        return hash.compactMap { String(format: "%02x", $0) }.joined()
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
