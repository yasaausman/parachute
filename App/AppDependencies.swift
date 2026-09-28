import MoneyKit
import Observation
import ParachuteKit
import SharedKit
import SwiftData

/// The composition root: every cross-package protocol is injected here (docs/interfaces.md).
@Observable
final class AppDependencies {
    /// MoneyKit's concrete scheduler; `escalation` is the same object behind the shared protocol.
    let moneyEscalation: EscalationScheduler
    var escalation: any EscalationScheduling { moneyEscalation }
    /// ParachuteKit's engine; `unfreeze` is the same object behind the shared protocol.
    let unfreezeEngine: UnfreezeEngine
    var unfreeze: any UnfreezeProviding { unfreezeEngine }
    /// MoneyKit's RevenueCat-backed entitlements; `entitlements` is the same object for B's gating.
    let pro: ProEntitlements
    var entitlements: any EntitlementsProviding { pro }
    let ledger: any CompletionLedger

    init(
        moneyEscalation: EscalationScheduler,
        unfreezeEngine: UnfreezeEngine,
        pro: ProEntitlements,
        ledger: any CompletionLedger
    ) {
        self.moneyEscalation = moneyEscalation
        self.unfreezeEngine = unfreezeEngine
        self.pro = pro
        self.ledger = ledger
    }

    @MainActor
    static func live(container: ModelContainer) -> AppDependencies {
        let pro = ProEntitlements()                                  // real since A8 (RevenueCat)
        let alarmIsPro = ProFeatures.finalDayAlarmIsPro
        return AppDependencies(
            moneyEscalation: EscalationScheduler(alarmsAllowed: { alarmIsPro ? await pro.isPro : true }), // A2 + A4
            unfreezeEngine: UnfreezeEngine(),                        // real since B3
            pro: pro,
            ledger: SwiftDataLedger(modelContainer: container)       // real since B6
        )
    }

    /// What ParachuteKit's screens read from `\.parachute`.
    var parachute: ParachuteServices {
        ParachuteServices(engine: unfreezeEngine, ledger: ledger, scheduler: escalation, entitlements: entitlements)
    }
}
