import Foundation
import StoreKit
import Observation

@Observable
final class PurchaseManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = true
    var purchaseError: String?

    static let monthlyID = "com.zzoutuo.FileSort.monthly"
    static let yearlyID = "com.zzoutuo.FileSort.yearly"
    static let lifetimeID = "com.zzoutuo.FileSort.lifetime"

    var isPremium: Bool { !purchasedProductIDs.isEmpty }

    var monthlyProduct: Product? { products.first { $0.id == Self.monthlyID } }
    var yearlyProduct: Product? { products.first { $0.id == Self.yearlyID } }
    var lifetimeProduct: Product? { products.first { $0.id == Self.lifetimeID } }

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: [Self.monthlyID, Self.yearlyID, Self.lifetimeID])
            products = storeProducts
            await updatePurchasedProducts()
        } catch {
            purchaseError = error.localizedDescription
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                return true
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
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    self.purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                } catch {
                    self.purchaseError = error.localizedDescription
                }
            }
        }
    }

    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchasedIDs.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchasedIDs
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
