import Foundation

/// Implemented by Dev A (MoneyKit, RevenueCat). Used by Dev B for gating.
public protocol EntitlementsProviding: Sendable {
    var isPro: Bool { get async }
    @MainActor func presentPaywall()
}
