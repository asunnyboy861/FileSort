import AppIntents
import SwiftData

struct SortNowIntent: AppIntent {
    static var title: LocalizedStringResource = "Sort Files Now"
    static var description = IntentDescription("Sort files in your Downloads folder using existing rules")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let container = try ModelContainer(for: SortRule.self, MoveHistory.self)
        let context = ModelContext(container)
        let rules = (try? context.fetch(FetchDescriptor<SortRule>())) ?? []
        guard !rules.isEmpty else {
            return .result(value: "No sort rules found. Open FileSort to create rules first.")
        }
        let downloadsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        guard let targetURL = downloadsPath else {
            return .result(value: "Could not access Downloads folder.")
        }
        let scanService = FileScanService()
        let files: [ScannedFile]
        do {
            files = try await scanService.scanDirectory(targetURL)
        } catch {
            return .result(value: "Failed to scan Downloads: \(error.localizedDescription)")
        }
        guard !files.isEmpty else {
            return .result(value: "No files found in Downloads folder.")
        }
        let ruleEngine = RuleEngineService()
        let (actions, _) = await ruleEngine.matchFiles(files, rules: rules, targetBaseURL: targetURL)
        let moveService = FileMoveService()
        let result = await moveService.executeActions(actions)
        var message = "Sorted \(result.successCount) files successfully. \(result.failCount) failed."
        if !result.failedActions.isEmpty {
            let names = result.failedActions.prefix(3).map { $0.fileName }.joined(separator: ", ")
            message += " Failed: \(names)"
        }
        return .result(value: message)
    }
}

struct SortDirectoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Sort Directory"
    static var description = IntentDescription("Sort files in a specific directory")

    @Parameter(title: "Directory Path", default: "Downloads")
    var directoryPath: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let container = try ModelContainer(for: SortRule.self, MoveHistory.self)
        let context = ModelContext(container)
        let rules = (try? context.fetch(FetchDescriptor<SortRule>())) ?? []
        guard !rules.isEmpty else {
            return .result(value: "No sort rules found. Open FileSort to create rules first.")
        }
        var targetURL: URL?
        if directoryPath.lowercased() == "downloads" {
            targetURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        } else if directoryPath.lowercased() == "documents" {
            targetURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        } else if directoryPath.lowercased() == "desktop" {
            targetURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        } else {
            targetURL = URL(fileURLWithPath: directoryPath)
        }
        guard let url = targetURL, FileManager.default.fileExists(atPath: url.path) else {
            return .result(value: "Directory not found: \(directoryPath)")
        }
        let scanService = FileScanService()
        let files: [ScannedFile]
        do {
            files = try await scanService.scanDirectory(url)
        } catch {
            return .result(value: "Failed to scan directory: \(error.localizedDescription)")
        }
        guard !files.isEmpty else {
            return .result(value: "No files found in \(directoryPath).")
        }
        let ruleEngine = RuleEngineService()
        let (actions, _) = await ruleEngine.matchFiles(files, rules: rules, targetBaseURL: url)
        let moveService = FileMoveService()
        let result = await moveService.executeActions(actions)
        var message = "Sorted \(result.successCount) files in \(directoryPath). \(result.failCount) failed."
        if !result.failedActions.isEmpty {
            let names = result.failedActions.prefix(3).map { $0.fileName }.joined(separator: ", ")
            message += " Failed: \(names)"
        }
        return .result(value: message)
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
