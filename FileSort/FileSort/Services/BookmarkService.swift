import Foundation

struct BookmarkService {
    func saveBookmark(for url: URL) throws {
        let data = try url.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        var bookmarks = loadAllBookmarks()
        bookmarks[url.path] = data
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: AppConstants.Bookmarks.storageKey)
        }
        saveRecentDirectory(url.path)
    }

    func accessBookmark(for path: String) -> URL? {
        let bookmarks = loadAllBookmarks()
        guard let data = bookmarks[path] else { return nil }
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: data,
            options: .withoutUI,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else { return nil }
        _ = url.startAccessingSecurityScopedResource()
        return url
    }

    func removeBookmark(for path: String) {
        var bookmarks = loadAllBookmarks()
        bookmarks.removeValue(forKey: path)
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: AppConstants.Bookmarks.storageKey)
        }
        removeRecentDirectory(path)
    }

    func loadAllBookmarks() -> [String: Data] {
        guard let data = UserDefaults.standard.data(forKey: AppConstants.Bookmarks.storageKey) else { return [:] }
        return (try? JSONDecoder().decode([String: Data].self, from: data)) ?? [:]
    }

    func loadRecentDirectories() -> [RecentDirectory] {
        guard let data = UserDefaults.standard.data(forKey: AppConstants.Bookmarks.recentDirectoriesKey) else { return [] }
        return (try? JSONDecoder().decode([RecentDirectory].self, from: data)) ?? []
    }

    private func saveRecentDirectory(_ path: String) {
        var recents = loadRecentDirectories()
        recents.removeAll { $0.path == path }
        let dirName = URL(fileURLWithPath: path).lastPathComponent
        recents.insert(RecentDirectory(path: path, name: dirName, lastAccessed: Date()), at: 0)
        if recents.count > AppConstants.Bookmarks.maxRecentDirectories {
            recents = Array(recents.prefix(AppConstants.Bookmarks.maxRecentDirectories))
        }
        if let encoded = try? JSONEncoder().encode(recents) {
            UserDefaults.standard.set(encoded, forKey: AppConstants.Bookmarks.recentDirectoriesKey)
        }
    }

    private func removeRecentDirectory(_ path: String) {
        var recents = loadRecentDirectories()
        recents.removeAll { $0.path == path }
        if let encoded = try? JSONEncoder().encode(recents) {
            UserDefaults.standard.set(encoded, forKey: AppConstants.Bookmarks.recentDirectoriesKey)
        }
    }
}

struct RecentDirectory: Codable, Identifiable {
    var id: String { path }
    let path: String
    let name: String
    let lastAccessed: Date
}
