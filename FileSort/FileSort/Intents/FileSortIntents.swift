import AppIntents

struct SortNowIntent: AppIntent {
    static var title: LocalizedStringResource = "Sort Files Now"
    static var description = IntentDescription("Sort files in your Downloads folder using existing rules")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct SortDirectoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Sort Directory"
    static var description = IntentDescription("Sort files in a specific directory")

    @Parameter(title: "Directory Path", default: "Downloads")
    var directoryPath: String

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct FileSortShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: SortNowIntent(), phrases: [
            "Sort my files with \(.applicationName)",
            "Organize downloads with \(.applicationName)"
        ], shortTitle: "Sort Now", systemImageName: "folder.badge.gearshape.fill")

        AppShortcut(intent: SortDirectoryIntent(), phrases: [
            "Sort \(.applicationName) directory",
            "Organize folder with \(.applicationName)"
        ], shortTitle: "Sort Directory", systemImageName: "arrow.triangle.branch")
    }
}
