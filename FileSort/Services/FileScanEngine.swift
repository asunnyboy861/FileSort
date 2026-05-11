import Foundation

actor FileScanEngine {
    private let fileManager = FileManager.default

    func scan(directory: URL) async throws -> [ScannedFile] {
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        var scannedFiles: [ScannedFile] = []
        for url in contents {
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
            guard !isDir.boolValue else { continue }
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            let size = Int64(resourceValues.fileSize ?? 0)
            let modifiedDate = resourceValues.contentModificationDate ?? Date()
            let category = FileCategory.classify(url: url)
            let file = ScannedFile(url: url, name: url.lastPathComponent, size: size, modifiedDate: modifiedDate, category: category)
            scannedFiles.append(file)
        }
        return scannedFiles
    }

    func scanMultiple(directories: [URL]) async throws -> [ScannedFile] {
        var allFiles: [ScannedFile] = []
        for directory in directories {
            let files = try await scan(directory: directory)
            allFiles.append(contentsOf: files)
        }
        return allFiles
    }

    func countFiles(in directory: URL) -> Int {
        guard let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]) else { return 0 }
        return contents.filter { url in
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
            return !isDir.boolValue
        }.count
    }
}
