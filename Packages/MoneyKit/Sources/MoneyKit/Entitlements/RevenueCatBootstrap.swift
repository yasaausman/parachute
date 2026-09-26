import Foundation
import RevenueCat

/// Configures RevenueCat once at launch. The key comes from Info.plist (`RevenueCatAPIKey`),
/// which is only filled in Debug from the gitignored Config/Secrets.xcconfig (CLAUDE.md rules 4 and 5).
public enum RevenueCatBootstrap {
    public static let infoPlistKey = "RevenueCatAPIKey"

    @MainActor public private(set) static var isConfigured = false

    @MainActor public static func configureIfPossible() {
        #if DEBUG
        guard !isConfigured,
              let key = Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String,
              !key.isEmpty
        else { return }
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: key)
        isConfigured = true
        #endif
    }
}
