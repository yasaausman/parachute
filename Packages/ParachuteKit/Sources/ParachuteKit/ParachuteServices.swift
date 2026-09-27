import SharedKit
import SwiftUI
import WidgetKit

/// Everything ParachuteKit's screens need, injected once by the app:
/// `.environment(\.parachute, ParachuteServices(...))`.
public struct ParachuteServices: Sendable {
    public var engine: UnfreezeEngine
    public var ledger: any CompletionLedger
    /// Dev A's `EscalationScheduling` (B5). Nil in previews.
    public var scheduler: (any EscalationScheduling)?
    public var entitlements: any EntitlementsProviding

    public init(
        engine: UnfreezeEngine,
        ledger: any CompletionLedger,
        scheduler: (any EscalationScheduling)?,
        entitlements: any EntitlementsProviding
    ) {
        self.engine = engine
        self.ledger = ledger
        self.scheduler = scheduler
        self.entitlements = entitlements
    }

    /// Fakes for previews: Pro unlocked, nothing persisted.
    public static let preview = ParachuteServices(
        engine: UnfreezeEngine(),
        ledger: InMemoryLedger(),
        scheduler: nil,
        entitlements: FakeEntitlements(isPro: true)
    )

    public var reminders: TaskReminderService? { scheduler.map(TaskReminderService.init) }
}

public extension EnvironmentValues {
    @Entry var parachute: ParachuteServices = .preview
}

enum WidgetRefresh {
    /// Widgets read the App Group store; poke them after anything they show changes (B8).
    static func now() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
