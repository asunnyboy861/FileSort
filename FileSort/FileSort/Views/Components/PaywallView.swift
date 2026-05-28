import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: Tier = .yearly
    @State private var isPurchasing = false

    enum Tier: String, CaseIterable {
        case monthly, yearly, lifetime
        var displayName: String { rawValue.capitalized }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                featureList
                tierPicker
                purchaseButton
                legalLinks
                restoreButton
            }
            .padding()
        }
        .background(.background)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") { dismiss() }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text("FileSort Pro")
                .font(.title.bold())
            Text("Unlock powerful file management features")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureRow(icon: "infinity", text: "Unlimited Custom Rules", isFree: false)
            FeatureRow(icon: "doc.on.doc.fill", text: "Duplicate File Detection", isFree: false)
            FeatureRow(icon: "arrow.uturn.backward", text: "Unlimited Undo History", isFree: false)
            FeatureRow(icon: "square.grid.2x2.fill", text: "Home Screen Widget", isFree: false)
            FeatureRow(icon: "waveform.path.badge.plus", text: "Siri Shortcuts Integration", isFree: false)
            FeatureRow(icon: "sort.up", text: "Unlimited Monthly Sorts", isFree: false)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var tierPicker: some View {
        VStack(spacing: 12) {
            ForEach(Tier.allCases, id: \.self) { tier in
                tierCard(tier)
            }
        }
    }

    private func tierCard(_ tier: Tier) -> some View {
        Button {
            selectedTier = tier
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(tierTitle(for: tier))
                            .font(.subheadline.bold())
                        if tier == .yearly {
                            Text("Best Value")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.green, in: Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                    Text(priceText(for: tier))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let unitPrice = unitPriceText(for: tier) {
                        Text(unitPrice)
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
                Spacer()
                if selectedTier == tier {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                }
            }
            .padding()
            .background(selectedTier == tier ? Color.blue.opacity(0.1) : Color.clear, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedTier == tier ? Color.blue : Color.gray.opacity(0.3), lineWidth: selectedTier == tier ? 2 : 1))
        }
        .buttonStyle(.plain)
    }

    private func tierTitle(for tier: Tier) -> String {
        switch tier {
        case .monthly: return "Monthly — 1 Month"
        case .yearly: return "Yearly — 1 Year"
        case .lifetime: return "Lifetime — Forever"
        }
    }

    private func unitPriceText(for tier: Tier) -> String? {
        switch tier {
        case .monthly: return nil
        case .yearly: return "~$1.67/month"
        case .lifetime: return nil
        }
    }

    private var purchaseButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            if isPurchasing {
                ProgressView()
                    .tint(.white)
            } else {
                Text(selectedTier == .lifetime ? "Purchase" : "Subscribe")
                    .font(.headline)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .disabled(isPurchasing)
    }

    private var legalLinks: some View {
        VStack(spacing: 4) {
            if selectedTier == .lifetime {
                Text("One-time purchase. No recurring charges.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: AppConstants.URLs.privacy)!)
                    .font(.caption2)
                Link("Terms of Use", destination: URL(string: AppConstants.URLs.terms)!)
                    .font(.caption2)
            }
        }
        .padding(.top, 4)
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task { await purchaseManager.restorePurchases() }
        }
        .font(.caption)
        .foregroundStyle(.blue)
    }

    private func priceText(for tier: Tier) -> String {
        switch tier {
        case .monthly: return purchaseManager.monthlyProduct?.displayPrice ?? "$3.99/month"
        case .yearly: return "\(purchaseManager.yearlyProduct?.displayPrice ?? "$19.99")/year — Save 58%"
        case .lifetime: return purchaseManager.lifetimeProduct?.displayPrice ?? "$39.99 one-time"
        }
    }

    private func purchase() async {
        isPurchasing = true
        let product: Product?
        switch selectedTier {
        case .monthly: product = purchaseManager.monthlyProduct
        case .yearly: product = purchaseManager.yearlyProduct
        case .lifetime: product = purchaseManager.lifetimeProduct
        }
        if let product {
            _ = await purchaseManager.purchase(product)
        }
        isPurchasing = false
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let isFree: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(isFree ? .green : .yellow)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
            if isFree {
                Text("Free")
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.green.opacity(0.2), in: Capsule())
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
    }
}
