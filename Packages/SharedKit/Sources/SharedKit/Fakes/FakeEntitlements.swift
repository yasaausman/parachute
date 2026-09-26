import Foundation

/// Fixed entitlement state. Swap for MoneyKit's RevenueCat implementation once A8 lands.
public struct FakeEntitlements: EntitlementsProviding {
    public let isPro: Bool

    public init(isPro: Bool) {
        self.isPro = isPro
    }

    @MainActor public func presentPaywall() {
        print("[FakeEntitlements] presentPaywall()")
    }
}
