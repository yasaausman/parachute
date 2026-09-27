import MoneyKit
import Observation
import SharedKit

/// The composition root: every cross-package protocol is injected here.
/// Swap each fake for the real implementation as it lands (docs/interfaces.md §5).
@Observable
final class AppDependencies {
    /// MoneyKit's concrete scheduler; `escalation` is the same object behind the shared protocol.
    let moneyEscalation: EscalationScheduler
    var escalation: any EscalationScheduling { moneyEscalation }
    let unfreeze: any UnfreezeProviding
    let entitlements: any EntitlementsProviding
    let ledger: any CompletionLedger

    init(
        moneyEscalation: EscalationScheduler,
        unfreeze: any UnfreezeProviding,
        entitlements: any EntitlementsProviding,
        ledger: any CompletionLedger
    ) {
        self.moneyEscalation = moneyEscalation
        self.unfreeze = unfreeze
        self.entitlements = entitlements
        self.ledger = ledger
    }

    static var live: AppDependencies {
        AppDependencies(
            moneyEscalation: EscalationScheduler(),       // real since A2; A4 adds the alarm
            unfreeze: FakeUnfreezeProvider(),            // → ParachuteKit UnfreezeEngine (B3)
            entitlements: FakeEntitlements(isPro: false), // → MoneyKit RevenueCat entitlements (A8)
            ledger: InMemoryLedger()                     // → ParachuteKit ledger (B6)
        )
    }
}
