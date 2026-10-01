import OSLog
import RevenueCat
import SharedKit
import SwiftUI

/// A8: Untax Pro. Prices come from the current RevenueCat offering; lifetime is the headline.
public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let entitlements: ProEntitlements

    @State private var packages: [Package] = []
    @State private var selected: Package?
    @State private var status: Status = .loading
    @State private var working = false
    @State private var message: String?

    enum Status: Equatable { case loading, ready, unavailable }

    public init(entitlements: ProEntitlements) {
        self.entitlements = entitlements
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing * 1.25) {
                    header
                    features
                    switch status {
                    case .loading:
                        ProgressView().padding()
                    case .unavailable:
                        // Friendly on screen; the real RevenueCat error goes to the log.
                        VStack(spacing: 12) {
                            Text("Plans didn't load just now. Everything free still works.")
                                .foregroundStyle(Theme.inkMuted)
                                .multilineTextAlignment(.center)
                            if RevenueCatBootstrap.isConfigured {
                                Button("Try again") {
                                    status = .loading
                                    Task { await load() }
                                }
                                .buttonStyle(.untaxQuiet)
                            }
                        }
                    case .ready:
                        plans
                        buyButton
                        if selectedHasTrial {
                            ironicBanner
                        }
                    }
                    if let message {
                        Text(message).font(.subheadline).foregroundStyle(Theme.inkMuted).multilineTextAlignment(.center)
                    }
                    footer
                }
                .padding(Theme.screenPadding)
            }
            .untaxScreen()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                }
            }
        }
        .tint(Theme.accentText)
        .task { await load() }
    }

    // MARK: Sections

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .imageScale(.large)
                .accessibilityHidden(true)
                .foregroundStyle(Theme.accent)
            Text("Untax Pro")
                .font(Theme.display())
                .foregroundStyle(Theme.ink)
            Text("Get your ADHD tax back. Every deadline your brain tries to drop.")
                .foregroundStyle(Theme.inkMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 10) {
            FeatureRow(systemImage: "alarm.waves.left.and.right.fill", text: "The final-day alarm that keeps coming back until you decide")
            FeatureRow(systemImage: "infinity", text: "Track every trial, not just \(ProFeatures.freeTrialLimit)")
            FeatureRow(systemImage: "snowflake", text: "Step-by-step help for any service and any task")
            FeatureRow(systemImage: "gift", text: "Always free: reminders, hand-checked cancel steps, and your first step")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var plans: some View {
        VStack(spacing: 10) {
            ForEach(packages, id: \.identifier) { package in
                Button {
                    selected = package
                } label: {
                    PlanRow(package: package, isSelected: selected?.identifier == package.identifier)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var buyButton: some View {
        Button {
            Task { await buy() }
        } label: {
            Group {
                if working {
                    ProgressView()
                } else {
                    Text(buyTitle)
                }
            }
            .tint(.white)
        }
        .buttonStyle(.untax)
        .disabled(selected == nil || working)
    }

    private var ironicBanner: some View {
        Label("We'll remind you 24 hours before this trial ends too. Because that would be pretty ironic. 😉", systemImage: "bell.fill")
            .font(.subheadline)
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .untaxCard()
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Text("We'd never charge a subscription to fix your follow-through. Lifetime is one payment: no trial to forget.")
                .font(.footnote)
                .foregroundStyle(Theme.inkMuted)
                .multilineTextAlignment(.center)
            Button("Restore purchases") { Task { await restore() } }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.accentText)
                .frame(minHeight: 44)
            #if DEBUG
            Text("Debug build: purchases use RevenueCat's Test Store (simulated, no real money).")
                .font(.caption2)
                .foregroundStyle(Theme.inkMuted)
            #endif
        }
    }

    // MARK: Logic

    private var selectedHasTrial: Bool {
        selected.map(Self.hasTrial) ?? false
    }

    static func hasTrial(_ package: Package) -> Bool {
        package.storeProduct.introductoryDiscount?.paymentMode == .freeTrial
    }


    private var buyTitle: String {
        guard let selected else { return "Choose a plan" }
        if selectedHasTrial, let discount = selected.storeProduct.introductoryDiscount {
            return "Start \(PlanRow.describe(discount.subscriptionPeriod)) free trial"
        }
        if selected.packageType == .lifetime { return "Get Pro for \(selected.storeProduct.localizedPriceString)" }
        return "Subscribe for \(selected.storeProduct.localizedPriceString)"
    }

    private func load() async {
        guard RevenueCatBootstrap.isConfigured else {
            status = .unavailable
            return
        }
        do {
            let offering = try await Purchases.shared.offerings().current
            packages = (offering?.availablePackages ?? []).sorted { Self.rank($0) < Self.rank($1) }
            selected = packages.first
            status = packages.isEmpty ? .unavailable : .ready
        } catch {
            status = .unavailable
            Logger(subsystem: "Untax", category: "Paywall").error("Offerings failed: \(String(describing: error), privacy: .public)")
        }
    }

    /// Lifetime first (the headline), then yearly, then monthly.
    static func rank(_ package: Package) -> Int {
        switch package.packageType {
        case .lifetime: 0
        case .annual: 1
        case .monthly: 2
        default: 3
        }
    }

    private func buy() async {
        guard let selected else { return }
        working = true
        defer { working = false }
        do {
            let result = try await Purchases.shared.purchase(package: selected)
            guard !result.userCancelled else { return }
            entitlements.purchaseCompleted()
            entitlements.apply(result.customerInfo)
            if entitlements.isProNow {
                message = "You're Pro. Your ADHD tax is officially on notice."
                try? await Task.sleep(for: .seconds(1))
                dismiss()
            }
        } catch {
            message = "The purchase didn't go through. Nothing was charged."
        }
    }

    private func restore() async {
        working = true
        defer { working = false }
        do {
            try await entitlements.restore()
            message = entitlements.isProNow ? "Restored. You're Pro." : "No Pro purchase found on this account."
        } catch {
            message = "Couldn't restore right now. Try again in a moment."
        }
    }
}

private struct FeatureRow: View {
    let systemImage: String
    let text: String
    /// One icon column so every line of text starts at the same edge.
    @ScaledMetric(relativeTo: .body) private var iconWidth: CGFloat = 30

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Theme.accentText)
                .frame(width: iconWidth)
                .accessibilityHidden(true)
            Text(text).foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PlanRow: View {
    let package: Package
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title).font(Theme.headline(.headline)).foregroundStyle(Theme.ink)
                    if package.packageType == .lifetime {
                        Text("BEST").font(.caption2.bold())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Theme.accentFill, in: .capsule)
                            .foregroundStyle(.white)
                    }
                }
                Text(subtitle).font(.subheadline).foregroundStyle(Theme.inkMuted)
            }
            Spacer()
            Text(package.storeProduct.localizedPriceString)
                .font(Theme.number(.headline))
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Theme.accentText : Theme.inkMuted)
        }
        .frame(minHeight: 44)
        .untaxCard()
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .strokeBorder(isSelected ? Theme.accentText : .clear, lineWidth: 2)
        }
        .contentShape(.rect(cornerRadius: Theme.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var title: String {
        switch package.packageType {
        case .lifetime: "Lifetime"
        case .annual: "Yearly"
        case .monthly: "Monthly"
        default: package.storeProduct.localizedTitle
        }
    }

    private var subtitle: String {
        let product = package.storeProduct
        if let discount = product.introductoryDiscount, discount.paymentMode == .freeTrial {
            return "\(Self.describe(discount.subscriptionPeriod)) free, then \(product.localizedPriceString)\(Self.perPeriod(product.subscriptionPeriod))"
        }
        return package.packageType == .lifetime ? "Pay once. Yours forever." : "Cancel anytime"
    }

    /// "1 week", "7 days", "1 month".
    static func describe(_ period: SubscriptionPeriod) -> String {
        let unit = switch period.unit {
        case .day: "day"
        case .week: "week"
        case .month: "month"
        case .year: "year"
        @unknown default: "period"
        }
        return "\(period.value) \(unit)\(period.value == 1 ? "" : "s")"
    }

    /// "/yr", "/mo", or "" for non-subscriptions.
    static func perPeriod(_ period: SubscriptionPeriod?) -> String {
        guard let period, period.value == 1 else { return "" }
        return switch period.unit {
        case .year: "/yr"
        case .month: "/mo"
        case .week: "/wk"
        default: ""
        }
    }
}
