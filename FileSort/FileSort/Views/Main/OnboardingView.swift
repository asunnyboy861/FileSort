import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    @State private var showPaywall = false

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("folder.badge.gearshape.fill", "Sort Files Instantly", "Select any folder and organize files with one tap"),
        ("list.bullet.rectangle", "Smart Rules", "Create custom rules to automatically sort files by type, name, or size"),
        ("doc.on.doc.fill", "Find Duplicates", "Detect and remove duplicate files to reclaim storage space"),
        ("arrow.uturn.backward", "Undo Anytime", "Changed your mind? Undo any sort batch with one tap"),
        ("crown.fill", "Unlock More with Pro", "Custom rules, duplicate detection, widget, shortcuts, and unlimited undo"),
    ]

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                VStack(spacing: 20) {
                    Image(systemName: page.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(index == pages.count - 1 ? .yellow : .blue)
                    Text(page.title)
                        .font(.title2.bold())
                    Text(page.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    if index == pages.count - 1 {
                        proFeaturesList
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            if currentPage == pages.count - 1 {
                lastPageButtons
            } else {
                Button("Next") {
                    withAnimation { currentPage += 1 }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView()
            }
        }
    }

    private var proFeaturesList: some View {
        VStack(alignment: .leading, spacing: 8) {
            FeatureRow(icon: "list.bullet.rectangle", text: "Unlimited Custom Rules", isFree: false)
            FeatureRow(icon: "doc.on.doc.fill", text: "Duplicate Detection", isFree: false)
            FeatureRow(icon: "arrow.uturn.backward", text: "Unlimited Undo History", isFree: false)
            FeatureRow(icon: "square.grid.2x2", text: "Home Screen Widget", isFree: false)
            FeatureRow(icon: "arrow.triangle.branch", text: "Shortcuts Integration", isFree: false)
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)
    }

    private var lastPageButtons: some View {
        VStack(spacing: 12) {
            Button {
                showPaywall = true
            } label: {
                Label("Unlock Pro", systemImage: "crown.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Button("Start Free") {
                hasSeenOnboarding = true
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
}
