import RevenueCat
import SharedKit
import SwiftUI

/// A8: Parachute Pro. Prices come from the current RevenueCat offering; lifetime is the headline.
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
                        Text("Purchases aren't set up in this build.")
                            .foregroundStyle(.secondary)
                    case .ready:
                        plans
                        buyButton
                        if selectedHasTrial {
                            ironicBanner
                        }
                    }
                    if let message {
                        Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                    footer
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                }
            }
        }
        .tint(Theme.accent)
        .task { await load() }
    }

    // MARK: Sections

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 52))
                .accessibilityHidden(true)
                .foregroundStyle(Theme.accent)
            Text("Parachute Pro")
                .font(.largeTitle.bold())
            Text("For every deadline your brain tries to drop.")
                .foregroundStyle(.secondary)
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
        .padding()
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: Theme.cornerRadius))
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
                    Text(buyTitle).font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(selected == nil || working)
    }

    private var ironicBanner: some View {
        Label("We'll remind you 24 hours before this trial ends too. Because that would be pretty ironic. 😉", systemImage: "bell.fill")
            .font(.subheadline)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accent.opacity(0.15), in: .rect(cornerRadius: Theme.cornerRadius))
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Text("We'd never charge a subscription to fix your follow-through. Lifetime is one payment: no trial to forget.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Restore purchases") { Task { await restore() } }
                .font(.footnote)
            #if DEBUG
            Text("Debug build: purchases use RevenueCat's Test Store (simulated, no real money).")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            #endif
        }
    }

    // MARK: Logic

    private var selectedHasTrial: Bool {
        guard let discount = selected?.storeProduct.introductoryDiscount else { return false }
        return discount.paymentMode == .freeTrial
    }

    private var buyTitle: String {
        guard let selected else { return "Choose a plan" }
        if selectedHasTrial { return "Start free trial" }
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
            message = "Couldn't load plans: \(error.localizedDescription)"
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
            entitlements.apply(result.customerInfo)
            if entitlements.isProNow {
                message = "You're Pro. Pull the cord."
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

    var body: some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: systemImage).foregroundStyle(Theme.accent).accessibilityHidden(true)
        }
    }
}

private struct PlanRow: View {
    let package: Package
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title).font(.headline)
                    if package.packageType == .lifetime {
                        Text("BEST").font(.caption2.bold())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Theme.accent, in: .capsule)
                            .foregroundStyle(.white)
                    }
                }
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text(package.storeProduct.localizedPriceString).font(.headline)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Theme.accent : .secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: Theme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(isSelected ? Theme.accent : .clear, lineWidth: 2)
        }
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
        if let discount = package.storeProduct.introductoryDiscount, discount.paymentMode == .freeTrial {
            return "Free trial, then \(package.storeProduct.localizedPriceString)"
        }
        return package.packageType == .lifetime ? "Pay once. Yours forever." : "Cancel anytime"
    }
}
