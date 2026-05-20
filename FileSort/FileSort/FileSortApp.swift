import SwiftUI
import SwiftData

@main
struct FileSortApp: App {
    let purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [SortRule.self, MoveHistory.self])
        .environment(purchaseManager)
    }
}
