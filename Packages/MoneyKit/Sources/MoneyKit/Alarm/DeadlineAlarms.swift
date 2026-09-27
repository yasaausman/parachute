import AlarmKit
import Foundation
import SharedKit
import SwiftUI

/// What we remember about an item's live alarm, in the App Group so the Stop/Decide intents can
/// continue the chain even when the app was force-quit (proven in A0).
public struct AlarmRecord: Codable, Sendable, Hashable {
    public var itemID: UUID
    /// The AlarmKit alarm currently scheduled for this item.
    public var alarmID: UUID
    public var title: String
    /// The originally planned ring time. Re-planning with the same value keeps an ongoing chain.
    public var planned: Date
    public var rings: Int
}

/// The AlarmKit calls the chain needs, so tests can use a fake.
public protocol AlarmClient: Sendable {
    func requestAuthorizationIfNeeded() async -> Bool
    func schedule(alarmID: UUID, itemID: UUID, title: String, at date: Date) async throws
    func cancel(alarmID: UUID)
}

public struct DeadlineAlarmMetadata: AlarmMetadata {
    public var itemID: UUID
    public init(itemID: UUID) { self.itemID = itemID }
}

public struct AlarmKitClient: AlarmClient {
    public init() {}

    public func requestAuthorizationIfNeeded() async -> Bool {
        switch AlarmManager.shared.authorizationState {
        case .authorized: return true
        case .denied: return false
        case .notDetermined: return (try? await AlarmManager.shared.requestAuthorization()) == .authorized
        @unknown default: return false
        }
    }

    public func schedule(alarmID: UUID, itemID: UUID, title: String, at date: Date) async throws {
        // The unlocked banner shows only the icon, so it has to say "open the app" on its own (A0 finding).
        let decide = AlarmButton(text: "Decide", textColor: .white, systemImageName: "arrow.up.forward.app.fill")
        let titleResource = LocalizedStringResource(stringLiteral: title)
        let alert: AlarmPresentation.Alert
        if #available(iOS 26.1, *) {
            alert = AlarmPresentation.Alert(title: titleResource, secondaryButton: decide, secondaryButtonBehavior: .custom)
        } else {
            alert = AlarmPresentation.Alert(
                title: titleResource,
                stopButton: AlarmButton(text: "Stop", textColor: .white, systemImageName: "stop.fill"),
                secondaryButton: decide,
                secondaryButtonBehavior: .custom
            )
        }
        let attributes = AlarmAttributes<DeadlineAlarmMetadata>(
            presentation: AlarmPresentation(alert: alert),
            metadata: DeadlineAlarmMetadata(itemID: itemID),
            tintColor: Theme.accent
        )
        let configuration = AlarmManager.AlarmConfiguration<DeadlineAlarmMetadata>.alarm(
            schedule: .fixed(date),
            attributes: attributes,
            stopIntent: DeadlineAlarmStopIntent(itemID: itemID.uuidString),
            secondaryIntent: DeadlineAlarmDecideIntent(itemID: itemID.uuidString)
        )
        _ = try await AlarmManager.shared.schedule(id: alarmID, configuration: configuration)
    }

    public func cancel(alarmID: UUID) {
        try? AlarmManager.shared.cancel(id: alarmID)
    }
}

/// A4: the final-day alarm chain. Stop re-arms, Decide opens the app (and still re-arms as a
/// safety net), and only `disarm` (a recorded decision) ends it.
public struct DeadlineAlarms: Sendable {
    static let recordsKey = "alarm.records"

    /// `UserDefaults` isn't Sendable, so keep the suite name and open it on use.
    let suiteName: String?
    let client: any AlarmClient
    let now: @Sendable () -> Date
    let timeTravel: @Sendable () -> Bool

    public init(
        suiteName: String? = AppGroup.identifier,
        client: any AlarmClient = AlarmKitClient(),
        now: @escaping @Sendable () -> Date = { .now },
        timeTravel: @escaping @Sendable () -> Bool = { TimeTravel.isEnabled }
    ) {
        self.suiteName = suiteName
        self.client = client
        self.now = now
        self.timeTravel = timeTravel
    }

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    // MARK: Chain

    /// Schedules the first ring at `planned`. If a chain for the same plan is already running
    /// (e.g. the Money tab resyncs mid-chain), it's left alone.
    public func arm(itemID: UUID, title: String, planned: Date) async throws {
        if let existing = record(for: itemID), existing.planned == planned, existing.title == title {
            return
        }
        guard await client.requestAuthorizationIfNeeded() else { return }
        let fire = DeadlineAlarmPlanner.effectiveFireDate(planned, now: now(), timeTravel: timeTravel())
        try await replace(itemID: itemID, title: title, planned: planned, at: fire, rings: 0)
    }

    /// Stop was tapped: ring again later, unless a decision already ended the chain.
    public func stopTapped(itemID: UUID) async throws {
        guard let current = record(for: itemID) else { return }
        let fire = now().addingTimeInterval(DeadlineAlarmPlanner.rearmDelay(timeTravel: timeTravel()))
        try await replace(itemID: itemID, title: current.title, planned: current.planned, at: fire, rings: current.rings + 1)
    }

    /// Decide was tapped: open the Decide screen. The chain keeps a re-ring queued in case the
    /// user closes the app without deciding; recording a decision disarms it.
    public func decideTapped(itemID: UUID) async throws {
        try await stopTapped(itemID: itemID)
        await MainActor.run { DecideRouter.shared.request(itemID: itemID) }
    }

    /// A decision was recorded (or the item was deleted): end the chain for good.
    public func disarm(itemID: UUID) {
        guard let current = record(for: itemID) else { return }
        client.cancel(alarmID: current.alarmID)
        var all = records()
        all[itemID] = nil
        save(all)
    }

    // MARK: Records

    public func record(for itemID: UUID) -> AlarmRecord? {
        records()[itemID]
    }

    public func records() -> [UUID: AlarmRecord] {
        guard let data = defaults.data(forKey: Self.recordsKey),
              let list = try? JSONDecoder().decode([AlarmRecord].self, from: data)
        else { return [:] }
        return Dictionary(list.map { ($0.itemID, $0) }, uniquingKeysWith: { _, last in last })
    }

    private func save(_ records: [UUID: AlarmRecord]) {
        let data = try? JSONEncoder().encode(Array(records.values))
        defaults.set(data, forKey: Self.recordsKey)
    }

    private func replace(itemID: UUID, title: String, planned: Date, at fire: Date, rings: Int) async throws {
        if let old = record(for: itemID) {
            client.cancel(alarmID: old.alarmID)
        }
        let alarmID = UUID()
        try await client.schedule(alarmID: alarmID, itemID: itemID, title: title, at: fire)
        var all = records()
        all[itemID] = AlarmRecord(itemID: itemID, alarmID: alarmID, title: title, planned: planned, rings: rings)
        save(all)
    }
}
