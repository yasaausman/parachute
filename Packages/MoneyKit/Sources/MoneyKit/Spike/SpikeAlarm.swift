import AlarmKit
import AppIntents
import Foundation
import SharedKit
import SwiftUI

// A0 platform spike (throwaway; the real alarm is A4).
// Question: can an AlarmKit alarm keep coming back when you tap Stop, until you tap "Decide"?
// Design (CLAUDE.md rule 2): Stop runs `SpikeStopIntent`, which schedules a fresh alarm 60 s later;
// the secondary "Decide" button runs `SpikeDecideIntent`, which opens the app and ends the chain.

public struct SpikeAlarmMetadata: AlarmMetadata {
    public init() {}
}

public enum SpikeAlarm {
    static let decidedKey = "spike.alarm.decided"
    static let rearmCountKey = "spike.alarm.rearmCount"
    static let logKey = "spike.alarm.log"
    public static let decideRequestedKey = "spike.alarm.decideRequestedAt"
    /// Safety valve so a bug can't ring forever during the spike.
    static let maxRearms = 5

    static func nextFireDate(after date: Date) -> Date {
        date.addingTimeInterval(60)
    }

    private static var defaults: UserDefaults { AppGroup.defaults }

    public static var authorizationState: AlarmManager.AuthorizationState {
        AlarmManager.shared.authorizationState
    }

    public static func requestAuthorization() async throws -> AlarmManager.AuthorizationState {
        try await AlarmManager.shared.requestAuthorization()
    }

    /// Starts a fresh chain: first alarm rings in 60 s.
    public static func start() async throws {
        defaults.set(false, forKey: decidedKey)
        defaults.set(0, forKey: rearmCountKey)
        defaults.removeObject(forKey: decideRequestedKey)
        let date = nextFireDate(after: .now)
        let id = try await schedule(at: date)
        log("Scheduled \(short(id)) for \(date.formatted(date: .omitted, time: .standard))")
    }

    /// Called by Stop. Re-arms unless a decision was recorded.
    static func rearm(after alarmID: String) async throws {
        log("Stop tapped on \(alarmID.prefix(4))")
        guard !defaults.bool(forKey: decidedKey) else {
            log("Already decided, not re-arming")
            return
        }
        let count = defaults.integer(forKey: rearmCountKey)
        guard count < maxRearms else {
            log("Hit spike limit of \(maxRearms) re-arms")
            return
        }
        defaults.set(count + 1, forKey: rearmCountKey)
        let date = nextFireDate(after: .now)
        let id = try await schedule(at: date)
        log("Re-armed #\(count + 1): \(short(id)) for \(date.formatted(date: .omitted, time: .standard))")
    }

    /// Called by "Decide". Marks the chain decided so Stop won't re-arm, and clears any pending alarms.
    static func decide(alarmID: String) {
        defaults.set(true, forKey: decidedKey)
        defaults.set(Date.now.timeIntervalSince1970, forKey: decideRequestedKey)
        log("Decide tapped on \(alarmID.prefix(4))")
        cancelAll()
    }

    public static func cancelAll() {
        defaults.set(true, forKey: decidedKey)
        let alarms = (try? AlarmManager.shared.alarms) ?? []
        for alarm in alarms {
            try? AlarmManager.shared.cancel(id: alarm.id)
        }
        if !alarms.isEmpty { log("Cancelled \(alarms.count) alarm(s)") }
    }

    public static var logLines: [String] {
        defaults.stringArray(forKey: logKey) ?? []
    }

    public static func clearLog() {
        defaults.removeObject(forKey: logKey)
    }

    private static func schedule(at date: Date) async throws -> UUID {
        let id = UUID()
        let decideButton = AlarmButton(text: "Decide", textColor: .white, systemImageName: "hand.raised.fill")
        let title: LocalizedStringResource = "Hulu charges $17.99 today"
        let alert: AlarmPresentation.Alert
        if #available(iOS 26.1, *) {
            alert = AlarmPresentation.Alert(title: title, secondaryButton: decideButton, secondaryButtonBehavior: .custom)
        } else {
            alert = AlarmPresentation.Alert(
                title: title,
                stopButton: AlarmButton(text: "Stop", textColor: .white, systemImageName: "stop.fill"),
                secondaryButton: decideButton,
                secondaryButtonBehavior: .custom
            )
        }
        let attributes = AlarmAttributes<SpikeAlarmMetadata>(
            presentation: AlarmPresentation(alert: alert),
            metadata: SpikeAlarmMetadata(),
            tintColor: Theme.accent
        )
        let configuration = AlarmManager.AlarmConfiguration<SpikeAlarmMetadata>.alarm(
            schedule: .fixed(date),
            attributes: attributes,
            stopIntent: SpikeStopIntent(alarmID: id.uuidString),
            secondaryIntent: SpikeDecideIntent(alarmID: id.uuidString)
        )
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        return id
    }

    static func log(_ message: String) {
        let line = "\(Date.now.formatted(date: .omitted, time: .standard))  \(message)"
        print("[SpikeAlarm] \(line)")
        defaults.set(Array((logLines + [line]).suffix(50)), forKey: logKey)
    }

    private static func short(_ id: UUID) -> String {
        String(id.uuidString.prefix(4))
    }
}

public struct SpikeStopIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Stop Spike Alarm"
    public static let isDiscoverable = false

    @Parameter(title: "Alarm ID") public var alarmID: String

    public init() {}

    public init(alarmID: String) {
        self.alarmID = alarmID
    }

    public func perform() async throws -> some IntentResult {
        try await SpikeAlarm.rearm(after: alarmID)
        return .result()
    }
}

public struct SpikeDecideIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Decide"
    public static let isDiscoverable = false
    public static let supportedModes: IntentModes = .foreground

    @Parameter(title: "Alarm ID") public var alarmID: String

    public init() {}

    public init(alarmID: String) {
        self.alarmID = alarmID
    }

    public func perform() async throws -> some IntentResult {
        SpikeAlarm.decide(alarmID: alarmID)
        return .result()
    }
}

/// Lets the app target pick up MoneyKit's intents (App Intents metadata for packages).
public struct MoneyKitIntentsPackage: AppIntentsPackage {}
