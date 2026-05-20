import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showPaywall = false

    var body: some View {
        List {
            subscriptionSection
            featuresSection
            legalSection
            aboutSection
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView()
            }
        }
    }

    private var subscriptionSection: some View {
        Section {
            if purchaseManager.isPremium {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("FileSort Pro")
                        .font(.subheadline.bold())
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(.yellow)
                        Text("Upgrade to Pro")
                            .font(.subheadline.bold())
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Button {
                Task { await purchaseManager.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(.subheadline)
            }
        } header: {
            Text("Subscription")
        }
    }

    private var featuresSection: some View {
        Section {
            NavigationLink {
                RuleListView()
            } label: {
                Label("Sort Rules", systemImage: "list.bullet.rectangle")
            }
            NavigationLink {
                HistoryView()
            } label: {
                Label("Sort History", systemImage: "clock.arrow.circlepath")
            }
        } header: {
            Text("Features")
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://asunnyboy861.github.io/FileSort/support.html")!) {
                Label("Support", systemImage: "questionmark.circle")
            }
            Link(destination: URL(string: "https://asunnyboy861.github.io/FileSort/privacy.html")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: URL(string: "https://asunnyboy861.github.io/FileSort/terms.html")!) {
                Label("Terms of Use", systemImage: "doc.text")
            }
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
        } header: {
            Text("Legal & Support")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Build")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}
