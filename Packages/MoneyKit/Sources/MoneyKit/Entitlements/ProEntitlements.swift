import Foundation
import Observation
import RevenueCat
import SharedKit
import UserNotifications

/// What Pro unlocks on the money side (PLAN §6). One place to change the deal.
public enum ProFeatures {
    /// Free users can track this many open trials at once.
    public static let freeTrialLimit = 5
    /// The final-day alarm that keeps coming back is Pro; reminders stay free.
    public static let finalDayAlarmIsPro = true
    /// The last known Pro state, in the App Group, for the share extension (it can't reach RevenueCat).
    public static let cachedProKey = "pro.cached"
}

/// A8: the real `EntitlementsProviding`, backed by RevenueCat's `parachute_pro` entitlement.
/// Also reminds you 24 h before Untax's *own* trial ends (the ironic banner, kept honest).
@MainActor
@Observable
public final class ProEntitlements: EntitlementsProviding {
    public static let entitlementID = "parachute_pro"
    static let forceProKey = "debug.forcePro"
    static let overrideKey = "debug.proOverride"
    static let trialReminderID = "parachute.pro.trial"

    /// Debug builds can pretend either way, to test and film both tiers on a phone that already bought Pro.
    public enum DebugOverride: String, CaseIterable, Sendable {
        case real, pro, free
    }

    /// For views: the latest known state (after any Debug override).
    public private(set) var isProNow = false
    /// What RevenueCat says, before any Debug override.
    public private(set) var hasRealPro = false
    /// When the current Pro period is a free trial, when it ends.
    public private(set) var trialEnds: Date?
    public var isPaywallPresented = false

    public init() {
        isProNow = Self.resolve(real: false, override: Self.debugOverride)
    }

    /// Pro as the app should treat it.
    nonisolated static func resolve(real: Bool, override: DebugOverride) -> Bool {
        switch override {
        case .real: real
        case .pro: true
        case .free: false
        }
    }

    // MARK: EntitlementsProviding

    public var isPro: Bool {
        get async { isProNow }
    }

    public func presentPaywall() {
        isPaywallPresented = true
    }

    // MARK: RevenueCat

    /// Follows RevenueCat's customer info for the life of the app.
    public func start() async {
        guard RevenueCatBootstrap.isConfigured else { return }
        for await info in Purchases.shared.customerInfoStream {
            apply(info)
        }
    }

    public func apply(_ info: CustomerInfo) {
        let entitlement = info.entitlements[Self.entitlementID]
        hasRealPro = entitlement?.isActive == true
        refresh()
        if let entitlement, entitlement.isActive, entitlement.periodType == .trial, entitlement.willRenew,
           let ends = entitlement.expirationDate {
            trialEnds = ends
            Task { await Self.scheduleTrialReminder(endsAt: ends) }
        } else {
            trialEnds = nil
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.trialReminderID])
        }
    }

    public func restore() async throws {
        apply(try await Purchases.shared.restorePurchases())
    }

    // MARK: Our own trial

    /// "We'll remind you 24 hrs before THIS trial ends too." Fires a day before (or in a minute if
    /// that's already past), and never for a trial that won't renew.
    public static func scheduleTrialReminder(endsAt ends: Date, now: Date = .now) async {
        let fire = ends.addingTimeInterval(-24 * 60 * 60)
        guard ends > now else { return }
        let content = UNMutableNotificationContent()
        content.title = "Untax Pro: your trial ends tomorrow"
        content.body = "As promised. Keep Pro or cancel it before it charges: your call, no hard feelings."
        content.sound = .default
        let delay = max(60, fire.timeIntervalSince(now))
        let request = UNNotificationRequest(identifier: trialReminderID, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false))
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: Debug

    private func refresh() {
        isProNow = Self.resolve(real: hasRealPro, override: Self.debugOverride)
        AppGroup.defaults.set(isProNow, forKey: ProFeatures.cachedProKey)
    }

    public static var debugOverride: DebugOverride {
        #if DEBUG
        if let raw = AppGroup.defaults.string(forKey: overrideKey), let value = DebugOverride(rawValue: raw) {
            return value
        }
        // Older builds had a single "Force Pro" switch.
        return AppGroup.defaults.bool(forKey: forceProKey) ? .pro : .real
        #else
        return .real
        #endif
    }

    /// Debug only: Real (RevenueCat decides), Force Pro (no purchase needed), or Pretend free
    /// (ignore a purchase this phone already made).
    public func setDebugOverride(_ value: DebugOverride) {
        #if DEBUG
        AppGroup.defaults.set(value.rawValue, forKey: Self.overrideKey)
        AppGroup.defaults.removeObject(forKey: Self.forceProKey)
        refresh()
        #endif
    }

    /// After a purchase on the paywall, "Pretend free" steps aside so the purchase visibly unlocks Pro.
    public func purchaseCompleted() {
        if Self.debugOverride == .free {
            setDebugOverride(.real)
        }
    }
}
