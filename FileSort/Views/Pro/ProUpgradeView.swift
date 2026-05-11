import SwiftUI

struct ProUpgradeView: View {
    @State private var isPurchasing = false
    @Environment(\.dismiss) private var dismiss

    private let features: [(icon: String, title: String, description: String)] = [
        ("infinity", "Unlimited Sorting", "No 50-file limit per operation"),
        ("slider.horizontal.3", "Custom Rules", "Sort by name, size, date, and more"),
        ("icloud.fill", "iCloud Drive", "Sort files in iCloud Drive folders"),
        ("doc.on.doc.fill", "Duplicate Detection", "Find and remove duplicate files"),
        ("arrow.uturn.backward.circle.fill", "Batch Undo", "Undo any past operation (up to 50)"),
        ("square.and.arrow.up", "History Export", "Export sorting history as CSV"),
        ("folder.badge.gearshape", "Folder Templates", "Use {YYYY}/{MM} tokens for paths"),
        ("folder.fill.badge.plus", "Multi-Directory", "Sort multiple folders at once")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    purchaseSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("FileSort Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(colors: [.appSecondary, .appPrimary], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Text("Unlock Full Power")
                .font(.title2.bold())
                .foregroundColor(.appTextPrimary)
            Text("One-time purchase. No subscriptions.")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
        }
        .padding(.top, 8)
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            ForEach(features, id: \.icon) { feature in
                HStack(spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.title3)
                        .foregroundColor(.appPrimary)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(feature.description)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.appCardBackground)
                .cornerRadius(10)
            }
        }
    }

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    isPurchasing = true
                    let success = await ProManager.shared.purchase()
                    isPurchasing = false
                    if success { dismiss() }
                }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isPurchasing ? "Purchasing..." : "Unlock Pro — $3.99")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [.appPrimary, .appSecondary], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(14)
            }
            .disabled(isPurchasing)

            Button {
                Task {
                    await ProManager.shared.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(.top, 8)
    }
}
