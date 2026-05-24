import Foundation

enum AppConstants {
    enum AppGroup {
        static let id = "group.com.zzoutuo.FileSort"
    }

    enum IAP {
        static let monthlyID = "com.zzoutuo.FileSort.monthly"
        static let yearlyID = "com.zzoutuo.FileSort.yearly"
        static let lifetimeID = "com.zzoutuo.FileSort.lifetime"
        static let allIDs = [monthlyID, yearlyID, lifetimeID]
    }

    enum Widget {
        static let kind = "FileSortWidget"
        static let fileCountKey = "widget_fileCount"
        static let lastSortDateKey = "widget_lastSortDate"
    }

    enum URLs {
        static let baseURL = "https://asunnyboy861.github.io/FileSort"
        static var support: String { "\(baseURL)/support.html" }
        static var privacy: String { "\(baseURL)/privacy.html" }
        static var terms: String { "\(baseURL)/terms.html" }
    }

    enum Limits {
        static let maxUndoBatches = 50
        static let freeMaxRules = 1
        static let freeMaxUndoBatches = 1
        static let freeMonthlySorts = 3
        static let largeFileThreshold: Int64 = 10_485_760
        static let partialHashSize = 1_048_576
    }

    enum FreeUsage {
        static let sortCountKey = "freeMonthlySortCount"
        static let sortMonthKey = "freeMonthlySortMonth"
        static let duplicateCountKey = "freeMonthlyDuplicateCount"
        static let duplicateMonthKey = "freeMonthlyDuplicateMonth"
        static let freeMonthlyDuplicates = 1
    }

    enum Bookmarks {
        static let storageKey = "savedDirectoryBookmarks"
        static let recentDirectoriesKey = "recentDirectories"
        static let maxRecentDirectories = 5
    }
}
