import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    var isPro: Bool { ProManager.shared.isPro }
    var isLoading: Bool { ProManager.shared.isLoading }

    let supportURL = URL(string: "https://asunnyboy861.github.io/FileSort/support.html")!
    let privacyURL = URL(string: "https://asunnyboy861.github.io/FileSort/privacy.html")!
    let termsURL = URL(string: "https://asunnyboy861.github.io/FileSort/terms.html")!

    func restorePurchases() async {
        await ProManager.shared.restorePurchases()
    }
}
