import SwiftUI
import SafariServices

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var showProUpgrade = false
    @State private var showContactSupport = false
    @AppStorage("sortMode") private var sortMode = "move"

    var body: some View {
        List {
            proSection
            sortingSection
            supportSection
            legalSection
            aboutSection
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showProUpgrade) {
            ProUpgradeView()
        }
        .sheet(isPresented: $showContactSupport) {
            ContactSupportView()
        }
    }

    private var proSection: some View {
        Section {
            if viewModel.isPro {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.appSecondary)
                    Text("FileSort Pro")
                        .foregroundColor(.appSecondary)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.appSuccess)
                }
            } else {
                Button {
                    showProUpgrade = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundColor(.appSecondary)
                        Text("Upgrade to Pro")
                            .foregroundColor(.appSecondary)
                        Spacer()
                        Text("$3.99")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        } header: {
            Text("Pro")
        }
    }

    private var sortingSection: some View {
        Section {
            Picker("Sort Mode", selection: $sortMode) {
                Text("Move Files").tag("move")
                Text("Copy Files").tag("copy")
            }
        } header: {
            Text("Sorting")
        }
    }

    private var supportSection: some View {
        Section {
            Button {
                showContactSupport = true
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Contact Support")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }

            if !viewModel.isPro {
                Button {
                    Task { await viewModel.restorePurchases() }
                } label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                        Text("Restore Purchases")
                    }
                }
            }
        } header: {
            Text("Support")
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: viewModel.supportURL) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Help & Support")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            Link(destination: viewModel.privacyURL) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            Link(destination: viewModel.termsURL) {
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("Terms of Use")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
        } header: {
            Text("Legal")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.appTextSecondary)
            }
        } header: {
            Text("About")
        }
    }
}
