import Foundation
import UniformTypeIdentifiers

actor FileScanService {
    func scanDirectory(_ url: URL) async throws -> [ScannedFile] {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .contentTypeKey], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        var files: [ScannedFile] = []
        for fileURL in fileURLs {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDir), isDir.boolValue { continue }
            let file = try await parseFile(url: fileURL)
            files.append(file)
        }
        return files
    }

    func scanDirectories(_ urls: [URL]) async throws -> [ScannedFile] {
        var allFiles: [ScannedFile] = []
        for url in urls {
            let files = try await scanDirectory(url)
            allFiles.append(contentsOf: files)
        }
        return allFiles
    }

    private func parseFile(url: URL) async throws -> ScannedFile {
        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .contentTypeKey])
        let size = Int64(resourceValues.fileSize ?? 0)
        let creationDate = resourceValues.creationDate
        let modificationDate = resourceValues.contentModificationDate
        let utType = resourceValues.contentType
        let category = FileCategory.from(utType: utType)
        let ext = url.pathExtension.lowercased()
        let finalCategory: FileCategory
        if case .other = category, !ext.isEmpty {
            finalCategory = FileCategory.from(extension: ext)
        } else {
            finalCategory = category
        }
        let mimeType = utType?.preferredMIMEType ?? ""
        return ScannedFile(url: url, fileExtension: ext, mimeType: mimeType, size: size, creationDate: creationDate, modificationDate: modificationDate, category: finalCategory)
    }

    func countFilesInDirectory(_ url: URL) -> Int {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            return contents.filter { !$0.hasDirectoryPath }.count
        } catch {
            return 0
        }
    }
}
