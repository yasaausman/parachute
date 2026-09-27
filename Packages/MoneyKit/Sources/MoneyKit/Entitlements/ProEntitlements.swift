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
}

/// A8: the real `EntitlementsProviding`, backed by RevenueCat's `parachute_pro` entitlement.
/// Also reminds you 24 h before Parachute's *own* trial ends (the ironic banner, kept honest).
@MainActor
@Observable
public final class ProEntitlements: EntitlementsProviding {
    public static let entitlementID = "parachute_pro"
    static let forceProKey = "debug.forcePro"
    static let trialReminderID = "parachute.pro.trial"

    /// For views: the latest known state.
    public private(set) var isProNow = false
    /// When the current Pro period is a free trial, when it ends.
    public private(set) var trialEnds: Date?
    public var isPaywallPresented = false

    public init() {
        isProNow = Self.forcedPro
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
        isProNow = entitlement?.isActive == true || Self.forcedPro
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
        content.title = "Parachute Pro: your trial ends tomorrow"
        content.body = "As promised. Keep Pro or cancel it before it charges: your call, no hard feelings."
        content.sound = .default
        let delay = max(60, fire.timeIntervalSince(now))
        let request = UNNotificationRequest(identifier: trialReminderID, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false))
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: Debug

    static var forcedPro: Bool {
        #if DEBUG
        AppGroup.defaults.bool(forKey: forceProKey)
        #else
        false
        #endif
    }

    /// Debug only: pretend to be Pro without a purchase.
    public func setForcedPro(_ on: Bool) {
        #if DEBUG
        AppGroup.defaults.set(on, forKey: Self.forceProKey)
        if on {
            isProNow = true
            return
        }
        Task {
            if RevenueCatBootstrap.isConfigured, let info = try? await Purchases.shared.customerInfo() {
                apply(info)
            } else {
                isProNow = false
            }
        }
        #endif
    }
}
