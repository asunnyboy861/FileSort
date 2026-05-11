import Foundation
import UniformTypeIdentifiers

enum FileCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case documents
    case images
    case videos
    case music
    case archives
    case spreadsheets
    case presentations
    case code
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .documents: return "Documents"
        case .images: return "Images"
        case .videos: return "Videos"
        case .music: return "Music"
        case .archives: return "Archives"
        case .spreadsheets: return "Spreadsheets"
        case .presentations: return "Presentations"
        case .code: return "Code"
        case .other: return "Other"
        }
    }

    var folderName: String {
        switch self {
        case .documents: return "Documents"
        case .images: return "Images"
        case .videos: return "Videos"
        case .music: return "Music"
        case .archives: return "Archives"
        case .spreadsheets: return "Spreadsheets"
        case .presentations: return "Presentations"
        case .code: return "Code"
        case .other: return "Other"
        }
    }

    var systemImageName: String {
        switch self {
        case .documents: return "doc.fill"
        case .images: return "photo.fill"
        case .videos: return "video.fill"
        case .music: return "music.note"
        case .archives: return "doc.zipper"
        case .spreadsheets: return "tablecells.fill"
        case .presentations: return "play.rectangle.fill"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .other: return "folder.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .documents: return "4A90D9"
        case .images: return "E5734A"
        case .videos: return "9B59B6"
        case .music: return "F39C12"
        case .archives: return "7F8C8D"
        case .spreadsheets: return "27AE60"
        case .presentations: return "E74C3C"
        case .code: return "1ABC9C"
        case .other: return "95A5A6"
        }
    }

    static func classify(url: URL) -> FileCategory {
        let ext = url.pathExtension.lowercased()
        if let utType = UTType(filenameExtension: ext) {
            if utType.conforms(to: .image) { return .images }
            if utType.conforms(to: .movie) { return .videos }
            if utType.conforms(to: .audio) { return .music }
            if utType.conforms(to: .spreadsheet) { return .spreadsheets }
            if utType.conforms(to: .presentation) { return .presentations }
            if utType.conforms(to: .sourceCode) || utType.conforms(to: .script) { return .code }
            if utType.conforms(to: .archive) || utType.conforms(to: .gzip) { return .archives }
            if utType.conforms(to: .pdf) || utType.conforms(to: .plainText) || utType.conforms(to: .rtf) || utType.conforms(to: .html) { return .documents }
        }
        return classifyByExtension(ext)
    }

    private static func classifyByExtension(_ ext: String) -> FileCategory {
        let imageExts: Set<String> = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "webp", "heic", "heif", "svg", "ico", "raw", "cr2", "nef"]
        let videoExts: Set<String> = ["mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v", "3gp", "ts"]
        let musicExts: Set<String> = ["mp3", "wav", "aac", "flac", "ogg", "wma", "m4a", "aiff", "alac"]
        let archiveExts: Set<String> = ["zip", "rar", "7z", "tar", "gz", "bz2", "xz", "dmg", "iso", "pkg"]
        let spreadsheetExts: Set<String> = ["xls", "xlsx", "csv", "ods", "numbers"]
        let presentationExts: Set<String> = ["ppt", "pptx", "key", "odp"]
        let codeExts: Set<String> = ["swift", "py", "js", "ts", "html", "css", "java", "c", "cpp", "h", "go", "rs", "rb", "php", "sh", "json", "xml", "yaml", "yml", "sql", "md"]
        let docExts: Set<String> = ["pdf", "doc", "docx", "txt", "rtf", "odt", "pages", "epub", "mobi"]

        if imageExts.contains(ext) { return .images }
        if videoExts.contains(ext) { return .videos }
        if musicExts.contains(ext) { return .music }
        if archiveExts.contains(ext) { return .archives }
        if spreadsheetExts.contains(ext) { return .spreadsheets }
        if presentationExts.contains(ext) { return .presentations }
        if codeExts.contains(ext) { return .code }
        if docExts.contains(ext) { return .documents }
        return .other
    }
}
