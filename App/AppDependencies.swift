import Observation
import SharedKit

/// The composition root: every cross-package protocol is injected here.
/// Swap each fake for the real implementation as it lands (docs/interfaces.md §5).
@Observable
final class AppDependencies {
    let escalation: any EscalationScheduling
    let unfreeze: any UnfreezeProviding
    let entitlements: any EntitlementsProviding
    let ledger: any CompletionLedger

    init(
        escalation: any EscalationScheduling,
        unfreeze: any UnfreezeProviding,
        entitlements: any EntitlementsProviding,
        ledger: any CompletionLedger
    ) {
        self.escalation = escalation
        self.unfreeze = unfreeze
        self.entitlements = entitlements
        self.ledger = ledger
    }

    static var fakes: AppDependencies {
        AppDependencies(
            escalation: FakeEscalationScheduler(),       // → MoneyKit EscalationScheduler (A2/A4)
            unfreeze: FakeUnfreezeProvider(),            // → ParachuteKit UnfreezeEngine (B3)
            entitlements: FakeEntitlements(isPro: false), // → MoneyKit RevenueCat entitlements (A8)
            ledger: InMemoryLedger()                     // → ParachuteKit ledger (B6)
        )
    }
}
