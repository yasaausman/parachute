import MoneyKit
import Observation
import ParachuteKit
import SharedKit
import SwiftData

/// The composition root: every cross-package protocol is injected here.
/// Swap each fake for the real implementation as it lands (docs/interfaces.md §5).
@Observable
final class AppDependencies {
    /// MoneyKit's concrete scheduler; `escalation` is the same object behind the shared protocol.
    let moneyEscalation: EscalationScheduler
    var escalation: any EscalationScheduling { moneyEscalation }
    /// ParachuteKit's engine; `unfreeze` is the same object behind the shared protocol.
    let unfreezeEngine: UnfreezeEngine
    var unfreeze: any UnfreezeProviding { unfreezeEngine }
    let entitlements: any EntitlementsProviding
    let ledger: any CompletionLedger

    init(
        moneyEscalation: EscalationScheduler,
        unfreezeEngine: UnfreezeEngine,
        entitlements: any EntitlementsProviding,
        ledger: any CompletionLedger
    ) {
        self.moneyEscalation = moneyEscalation
        self.unfreezeEngine = unfreezeEngine
        self.entitlements = entitlements
        self.ledger = ledger
    }

    static func live(container: ModelContainer) -> AppDependencies {
        AppDependencies(
            moneyEscalation: EscalationScheduler(),                 // real since A2; A4 adds the alarm
            unfreezeEngine: UnfreezeEngine(),                       // real since B3
            entitlements: FakeEntitlements(isPro: false),           // → MoneyKit RevenueCat entitlements (A8)
            ledger: SwiftDataLedger(modelContainer: container)      // real since B6
        )
    }

    /// What ParachuteKit's screens read from `\.parachute`.
    var parachute: ParachuteServices {
        ParachuteServices(engine: unfreezeEngine, ledger: ledger, scheduler: escalation, entitlements: entitlements)
    }
}
