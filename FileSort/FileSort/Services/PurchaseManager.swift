import Foundation
import StoreKit
import Observation

@Observable
final class PurchaseManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = true
    var purchaseError: String?

    static let monthlyID = AppConstants.IAP.monthlyID
    static let yearlyID = AppConstants.IAP.yearlyID
    static let lifetimeID = AppConstants.IAP.lifetimeID

    var isPremium: Bool { !purchasedProductIDs.isEmpty }

    enum FeatureGate {
        case customRules
        case duplicateDetection
        case widgetAccess
        case shortcutsAccess
        case unlimitedUndo
    }

    func canAccess(_ feature: FeatureGate) -> Bool {
        switch feature {
        case .customRules, .duplicateDetection, .widgetAccess, .shortcutsAccess, .unlimitedUndo:
            return isPremium
        }
    }

    func canAddRule(currentCount: Int, defaultCount: Int = 0) -> Bool {
        let customCount = currentCount - defaultCount
        return isPremium || customCount < AppConstants.Limits.freeMaxRules
    }

    func canUndoBatch(freeBatchUsed: Bool) -> Bool {
        return isPremium || !freeBatchUsed
    }

    var freeSortsRemaining: Int {
        if isPremium { return AppConstants.Limits.freeMonthlySorts }
        let (count, _) = currentMonthlyUsage(for: AppConstants.FreeUsage.sortCountKey, monthKey: AppConstants.FreeUsage.sortMonthKey)
        return max(0, AppConstants.Limits.freeMonthlySorts - count)
    }

    var freeDuplicatesRemaining: Int {
        if isPremium { return AppConstants.FreeUsage.freeMonthlyDuplicates }
        let (count, _) = currentMonthlyUsage(for: AppConstants.FreeUsage.duplicateCountKey, monthKey: AppConstants.FreeUsage.duplicateMonthKey)
        return max(0, AppConstants.FreeUsage.freeMonthlyDuplicates - count)
    }

    var freeSortsUsedThisMonth: Int {
        if isPremium { return 0 }
        let (count, _) = currentMonthlyUsage(for: AppConstants.FreeUsage.sortCountKey, monthKey: AppConstants.FreeUsage.sortMonthKey)
        return count
    }

    func canSortFree() -> Bool {
        return isPremium || freeSortsRemaining > 0
    }

    func canDetectDuplicatesFree() -> Bool {
        return isPremium || freeDuplicatesRemaining > 0
    }

    func consumeFreeSort() {
        if isPremium { return }
        let (count, currentMonth) = currentMonthlyUsage(for: AppConstants.FreeUsage.sortCountKey, monthKey: AppConstants.FreeUsage.sortMonthKey)
        UserDefaults.standard.set(count + 1, forKey: AppConstants.FreeUsage.sortCountKey)
        UserDefaults.standard.set(currentMonth, forKey: AppConstants.FreeUsage.sortMonthKey)
    }

    func consumeFreeDuplicateScan() {
        if isPremium { return }
        let (count, currentMonth) = currentMonthlyUsage(for: AppConstants.FreeUsage.duplicateCountKey, monthKey: AppConstants.FreeUsage.duplicateMonthKey)
        UserDefaults.standard.set(count + 1, forKey: AppConstants.FreeUsage.duplicateCountKey)
        UserDefaults.standard.set(currentMonth, forKey: AppConstants.FreeUsage.duplicateMonthKey)
    }

    private func currentMonthlyUsage(for countKey: String, monthKey: String) -> (count: Int, month: String) {
        let currentMonth = monthString()
        let savedMonth = UserDefaults.standard.string(forKey: monthKey) ?? ""
        if savedMonth != currentMonth {
            UserDefaults.standard.set(0, forKey: countKey)
            UserDefaults.standard.set(currentMonth, forKey: monthKey)
            return (0, currentMonth)
        }
        return (UserDefaults.standard.integer(forKey: countKey), currentMonth)
    }

    private func monthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

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
            let storeProducts = try await Product.products(for: AppConstants.IAP.allIDs)
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
                    let transaction = try await self.checkVerified(result)
                    _ = await MainActor.run {
                        self.purchasedProductIDs.insert(transaction.productID)
                    }
                    await transaction.finish()
                } catch {
                    _ = await MainActor.run {
                        self.purchaseError = error.localizedDescription
                    }
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
