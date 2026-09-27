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
    /// MoneyKit's RevenueCat-backed entitlements; `entitlements` is the same object for B's gating.
    let pro: ProEntitlements
    var entitlements: any EntitlementsProviding { pro }
    let ledger: any CompletionLedger

    init(
        moneyEscalation: EscalationScheduler,
        unfreeze: any UnfreezeProviding,
        pro: ProEntitlements,
        ledger: any CompletionLedger
    ) {
        self.moneyEscalation = moneyEscalation
        self.unfreeze = unfreeze
        self.pro = pro
        self.ledger = ledger
    }

    @MainActor
    static var live: AppDependencies {
        let pro = ProEntitlements()                      // real since A8 (RevenueCat)
        let alarmIsPro = ProFeatures.finalDayAlarmIsPro
        return AppDependencies(
            moneyEscalation: EscalationScheduler(alarmsAllowed: { alarmIsPro ? await pro.isPro : true }), // A2 + A4
            unfreeze: FakeUnfreezeProvider(),            // → ParachuteKit UnfreezeEngine (B3)
            pro: pro,
            ledger: InMemoryLedger()                     // → ParachuteKit ledger (B6)
        )
    }
}
