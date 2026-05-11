import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Sort", systemImage: "arrow.down.doc.fill")
                }
                .tag(0)
            NavigationStack {
                RulesView()
            }
            .tabItem {
                Label("Rules", systemImage: "slider.horizontal.3")
            }
            .tag(1)
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(2)
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(.appPrimary)
    }
}
