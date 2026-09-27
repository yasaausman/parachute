import SharedKit
import SwiftUI

public extension EnvironmentValues {
    /// Injected by the app; nil in previews, where nothing gets scheduled.
    @Entry var moneyEscalation: EscalationScheduler?
    /// Injected by the app (A8); nil in previews and the share extension.
    @Entry var proEntitlements: ProEntitlements?
}

extension EscalationScheduler {
    /// Brings every open deadline's reminders in line with the store (after launch, edits, or a time-travel toggle).
    @MainActor
    public func resync(_ deadlines: [MoneyDeadline]) async {
        let snapshots = deadlines.map(MoneyDeadlineSnapshot.init)
        for snapshot in snapshots {
            try? await schedule(deadline: snapshot)
        }
    }
}
