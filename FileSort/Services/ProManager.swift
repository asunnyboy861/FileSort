import Foundation
import StoreKit

@MainActor
@Observable
final class ProManager {
    static let shared = ProManager()

    var isPro: Bool = false
    var isLoading: Bool = true
    var product: Product?
    var purchaseError: String?

    private let productId = "com.zzoutuo.FileSort.pro"
    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProductAndStatus() }
    }

    func loadProductAndStatus() async {
        isLoading = true
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == productId {
                        isPro = transaction.revocationDate == nil
                    }
                }
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isLoading = false
    }

    func purchase() async -> Bool {
        guard let product = product else { return false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isPro = true
                    await transaction.finish()
                    return true
                }
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await loadProductAndStatus()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == "com.zzoutuo.FileSort.pro" {
                        self?.isPro = transaction.revocationDate == nil
                    }
                    await transaction.finish()
                }
            }
        }
    }
}
