import Foundation
import SwiftData

struct UndoService {
    static let maxBatches = AppConstants.Limits.maxUndoBatches

    func saveBatch(records: [MoveRecord], modelContext: ModelContext) {
        trimOldBatches(modelContext: modelContext)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(records) {
            let totalSize = records.reduce(Int64(0)) { $0 + (FileManager.default.fileExists(atPath: $1.destinationURL.path) ? ((try? FileManager.default.attributesOfItem(atPath: $1.destinationURL.path)[.size] as? Int64) ?? 0) : 0) }
            let history = MoveHistory(movesData: data, fileCount: records.count, totalSize: totalSize)
            modelContext.insert(history)
            try? modelContext.save()
        }
    }

    func undoBatch(_ history: MoveHistory, modelContext: ModelContext) async -> Bool {
        let decoder = JSONDecoder()
        guard let records = try? decoder.decode([MoveRecord].self, from: history.movesData) else { return false }
        let moveService = FileMoveService()
        let result = await moveService.undoMoves(records)
        if result.successCount > 0 {
            modelContext.delete(history)
            try? modelContext.save()
        }
        return result.failCount == 0
    }

    func loadHistory(modelContext: ModelContext) -> [MoveHistory] {
        let descriptor = FetchDescriptor<MoveHistory>(sortBy: [SortDescriptor(\.batchDate, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func trimOldBatches(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<MoveHistory>(sortBy: [SortDescriptor(\.batchDate, order: .reverse)])
        guard let all = try? modelContext.fetch(descriptor) else { return }
        if all.count >= Self.maxBatches {
            for history in all.dropFirst(Self.maxBatches - 1) {
                modelContext.delete(history)
            }
            try? modelContext.save()
        }
    }
}
