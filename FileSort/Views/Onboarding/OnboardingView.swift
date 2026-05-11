import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentStep = 0
    @State private var showDocumentPicker = false

    private let steps = [
        OnboardingStep(
            icon: "folder.badge.gearshape.fill",
            title: "Auto File Sorting",
            description: "FileSort automatically organizes your messy files into categorized folders with a single tap.",
            color: Color.appPrimary
        ),
        OnboardingStep(
            icon: "hand.raised.fill",
            title: "100% Private",
            description: "All processing happens on your device. No data ever leaves your iPhone.",
            color: Color.appSuccess
        ),
        OnboardingStep(
            icon: "crown.fill",
            title: "Pro Features",
            description: "Unlock custom rules, duplicate detection, iCloud sorting, and more with a one-time purchase.",
            color: Color.appSecondary
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentStep) {
                ForEach(0..<steps.count, id: \.self) { index in
                    stepView(steps[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 12) {
                if currentStep == steps.count - 1 {
                    Button {
                        hasCompletedOnboarding = true
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.appPrimary, .appSecondary], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                    }
                } else {
                    Button {
                        withAnimation { currentStep += 1 }
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .cornerRadius(14)
                    }
                }

                if currentStep > 0 {
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .foregroundColor(.appTextSecondary)
                }
            }
            .padding()
        }
        .background(Color.appBackground)
    }

    private func stepView(_ step: OnboardingStep) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: step.icon)
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(colors: [step.color, step.color.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )
            Text(step.title)
                .font(.title.bold())
                .foregroundColor(.appTextPrimary)
            Text(step.description)
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}

struct OnboardingStep {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
