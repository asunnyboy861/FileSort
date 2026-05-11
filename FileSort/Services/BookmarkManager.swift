import Foundation

actor BookmarkManager {
    private let bookmarkKey = "com.zzoutuo.FileSort.securityBookmarks"
    private let defaults = UserDefaults.standard

    func saveBookmark(for url: URL) throws -> Data {
        let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
        var bookmarks = loadAllBookmarks()
        bookmarks[url.path] = bookmarkData
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            defaults.set(encoded, forKey: bookmarkKey)
        }
        return bookmarkData
    }

    func accessBookmark(for path: String) -> URL? {
        guard let bookmarkData = loadAllBookmarks()[path] else { return nil }
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale) else { return nil }
        if isStale {
            _ = try? saveBookmark(for: url)
        }
        let _ = url.startAccessingSecurityScopedResource()
        return url
    }

    func stopAccessing(url: URL) {
        url.stopAccessingSecurityScopedResource()
    }

    private func loadAllBookmarks() -> [String: Data] {
        guard let data = defaults.data(forKey: bookmarkKey),
              let bookmarks = try? JSONDecoder().decode([String: Data].self, from: data) else { return [:] }
        return bookmarks
    }

    func hasBookmark(for path: String) -> Bool {
        loadAllBookmarks()[path] != nil
    }
}
