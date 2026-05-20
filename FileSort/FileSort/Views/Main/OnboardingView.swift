import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("folder.badge.gearshape.fill", "Sort Files Instantly", "Select any folder and organize files with one tap"),
        ("list.bullet.rectangle", "Smart Rules", "Create custom rules to automatically sort files by type, name, or size"),
        ("doc.on.doc.fill", "Find Duplicates", "Detect and remove duplicate files to reclaim storage space"),
        ("arrow.uturn.backward", "Undo Anytime", "Changed your mind? Undo any sort batch with one tap"),
    ]

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                VStack(spacing: 20) {
                    Image(systemName: page.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(.blue)
                    Text(page.title)
                        .font(.title2.bold())
                    Text(page.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    hasSeenOnboarding = true
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom, 32)
        }
    }
}
