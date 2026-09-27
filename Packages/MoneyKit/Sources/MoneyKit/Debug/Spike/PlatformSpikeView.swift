import AlarmKit
import RevenueCat
import SharedKit
import SwiftUI

/// A0: one screen to exercise AlarmKit re-arm, a local notification, and a Test Store purchase.
public struct PlatformSpikeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var alarmAuth = "unknown"
    @State private var alarmLog: [String] = []
    @State private var notificationStatus = ""
    @State private var purchaseStatus = ""
    @State private var decidedAt: Date?

    public init() {}

    public var body: some View {
        List {
            Section {
                LabeledContent("Authorization", value: alarmAuth)
                Button("Start alarm chain (rings in 60 s)") {
                    Task { await startAlarm() }
                }
                Button("Cancel all alarms", role: .destructive) {
                    SpikeAlarm.cancelAll()
                    refresh()
                }
                if let decidedAt {
                    Label("Decide opened the app at \(decidedAt.formatted(date: .omitted, time: .standard))", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            } header: {
                Text("1 · AlarmKit: Stop re-arms")
            } footer: {
                Text("Lock the phone. When it rings, tap Stop: it should ring again 60 s later (max \(SpikeAlarm.maxRearms)). Then tap Decide: it should open this screen and stop.")
            }

            Section("Alarm log") {
                if alarmLog.isEmpty {
                    Text("Nothing yet").foregroundStyle(.secondary)
                }
                ForEach(Array(alarmLog.enumerated().reversed()), id: \.offset) { _, line in
                    Text(line).font(.caption.monospaced())
                }
                Button("Clear log") {
                    SpikeAlarm.clearLog()
                    refresh()
                }
            }

            Section {
                Button("Schedule notification in 10 s") {
                    Task { await scheduleNotification() }
                }
                if !notificationStatus.isEmpty { Text(notificationStatus) }
            } header: {
                Text("2 · Local notification")
            }

            Section {
                Button("Buy first package of current offering") {
                    Task { await purchase() }
                }
                if !purchaseStatus.isEmpty { Text(purchaseStatus) }
            } header: {
                Text("3 · RevenueCat Test Store")
            } footer: {
                Text(RevenueCatBootstrap.isConfigured
                     ? "Configured with the Debug key."
                     : "Not configured: add REVENUECAT_API_KEY to Config/Secrets.xcconfig and rebuild.")
            }
        }
        .navigationTitle("Platform spike")
        .onAppear(perform: refresh)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() }
        }
    }

    private func refresh() {
        alarmAuth = String(describing: SpikeAlarm.authorizationState)
        alarmLog = SpikeAlarm.logLines
        let ts = AppGroup.defaults.double(forKey: SpikeAlarm.decideRequestedKey)
        decidedAt = ts > 0 ? Date(timeIntervalSince1970: ts) : nil
    }

    private func startAlarm() async {
        do {
            if SpikeAlarm.authorizationState != .authorized {
                _ = try await SpikeAlarm.requestAuthorization()
            }
            try await SpikeAlarm.start()
        } catch {
            SpikeAlarm.log("Error: \(error)")
        }
        refresh()
    }

    private func scheduleNotification() async {
        do {
            let granted = try await SpikeNotification.requestAndSchedule()
            notificationStatus = granted ? "Scheduled for \(Date.now.addingTimeInterval(10).formatted(date: .omitted, time: .standard))" : "Permission denied"
        } catch {
            notificationStatus = "Error: \(error.localizedDescription)"
        }
    }

    private func purchase() async {
        guard RevenueCatBootstrap.isConfigured else {
            purchaseStatus = "RevenueCat isn't configured."
            return
        }
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let package = offerings.current?.availablePackages.first else {
                purchaseStatus = "No current offering with packages. Check the dashboard's Offerings tab."
                return
            }
            purchaseStatus = "Buying \(package.storeProduct.productIdentifier)…"
            let result = try await Purchases.shared.purchase(package: package)
            let active = result.customerInfo.entitlements.active.keys.sorted()
            purchaseStatus = result.userCancelled
                ? "Cancelled by user."
                : "Purchased. Active entitlements: \(active.isEmpty ? "none" : active.joined(separator: ", "))"
        } catch {
            purchaseStatus = "Error: \(error.localizedDescription)"
        }
    }
}
