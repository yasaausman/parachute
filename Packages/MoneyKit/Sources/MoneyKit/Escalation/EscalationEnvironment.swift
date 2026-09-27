import SharedKit
import SwiftUI

public extension EnvironmentValues {
    /// Injected by the app; nil in previews, where nothing gets scheduled.
    @Entry var moneyEscalation: EscalationScheduler?
}

extension EscalationScheduler {
    /// Brings every open deadline's reminders in line with the store (after launch, edits, or a time-travel toggle).
    @MainActor
    func resync(_ deadlines: [MoneyDeadline]) async {
        let snapshots = deadlines.map(MoneyDeadlineSnapshot.init)
        for snapshot in snapshots {
            try? await schedule(deadline: snapshot)
        }
    }
}
