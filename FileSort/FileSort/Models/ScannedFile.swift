import Foundation
import UniformTypeIdentifiers

struct ScannedFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let fileExtension: String
    let mimeType: String
    let size: Int64
    let creationDate: Date?
    let modificationDate: Date?
    let category: FileCategory

    var displayName: String {
        name.isEmpty ? url.lastPathComponent : name
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    init(url: URL, name: String = "", fileExtension: String = "", mimeType: String = "", size: Int64 = 0, creationDate: Date? = nil, modificationDate: Date? = nil, category: FileCategory = .other) {
        self.url = url
        self.name = name.isEmpty ? url.deletingPathExtension().lastPathComponent : name
        self.fileExtension = fileExtension.isEmpty ? url.pathExtension.lowercased() : fileExtension
        self.mimeType = mimeType
        self.size = size
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.category = category
    }
}

enum FileCategory: String, CaseIterable, Codable {
    case documents
    case images
    case videos
    case audio
    case archives
    case code
    case other

    var displayName: String {
        switch self {
        case .documents: return "Documents"
        case .images: return "Images"
        case .videos: return "Videos"
        case .audio: return "Audio"
        case .archives: return "Archives"
        case .code: return "Code"
        case .other: return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .documents: return "doc.fill"
        case .images: return "photo.fill"
        case .videos: return "film.fill"
        case .audio: return "music.note"
        case .archives: return "archivebox.fill"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .other: return "questionmark.folder.fill"
        }
    }

    var defaultFolderName: String {
        switch self {
        case .documents: return "Documents"
        case .images: return "Photos"
        case .videos: return "Videos"
        case .audio: return "Audio"
        case .archives: return "Archives"
        case .code: return "Code"
        case .other: return "Other"
        }
    }

    static func from(utType: UTType?) -> FileCategory {
        guard let utType = utType else { return .other }
        if utType.conforms(to: .pdf) || utType.conforms(to: .plainText) || utType.conforms(to: .rtf) || utType.conforms(to: .presentation) || utType.conforms(to: .spreadsheet) { return .documents }
        if utType.conforms(to: .image) { return .images }
        if utType.conforms(to: .movie) || utType.conforms(to: .video) { return .videos }
        if utType.conforms(to: .audio) { return .audio }
        if utType.conforms(to: .archive) || utType.conforms(to: .zip) { return .archives }
        if utType.conforms(to: .sourceCode) { return .code }
        return .other
    }

    static func from(extension ext: String) -> FileCategory {
        let ext = ext.lowercased()
        let docExts = ["pdf", "doc", "docx", "txt", "rtf", "xls", "xlsx", "ppt", "pptx", "pages", "numbers", "keynote", "csv"]
        let imgExts = ["jpg", "jpeg", "png", "gif", "heic", "heif", "tiff", "bmp", "svg", "webp", "raw"]
        let vidExts = ["mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v"]
        let audExts = ["mp3", "wav", "aac", "flac", "m4a", "ogg", "wma"]
        let arcExts = ["zip", "rar", "7z", "tar", "gz", "bz2", "xz", "dmg", "iso"]
        let codeExts = ["swift", "py", "js", "ts", "html", "css", "json", "xml", "java", "c", "cpp", "h", "go", "rs", "rb", "php", "sh"]
        if docExts.contains(ext) { return .documents }
        if imgExts.contains(ext) { return .images }
        if vidExts.contains(ext) { return .videos }
        if audExts.contains(ext) { return .audio }
        if arcExts.contains(ext) { return .archives }
        if codeExts.contains(ext) { return .code }
        return .other
    }
}
