# interfaces.md: the contracts between Dev A and Dev B

These live in `Packages/SharedKit`. **Both devs code against these, never against each other's packages.** Change them only with a heads-up and the other's review.

> ⚠️ These are **sketches** to agree on in Phase 0 (S0.2). Compile them, fix whatever the compiler says, and keep the *shape*. Apple framework specifics (SwiftData enum storage, AlarmKit intent types) must be checked against Apple's docs while implementing (CLAUDE.md rule 1).

> ✅ **Compiled in S0.2 (2026-09-25)** in `Packages/SharedKit`, same shape as below, plus: public inits on every type; typed accessors on the models (`status`, `source`, `kind`) wrapping the `…Raw` strings; `Hashable` on the request/plan/outcome types; `Codable` on `PlanStep`; `CancelStepsFile` (the JSON's Codable shape); `SharedStore.makeContainer()` (the App Group SwiftData container) and `AppGroup.defaults`.

## Package dependency rule
```
App (composition root) ──► MoneyKit (A) ──► SharedKit
                       └─► ParachuteKit (B) ──► SharedKit
MoneyKit ✗ ParachuteKit   (never import each other; the App target wires them together)
```

## 1. Models (SwiftData, stored in the App Group container)

```swift
// SharedKit/Models/MoneyDeadline.swift: written by A, read by B (widgets, scoreboard)
@Model public final class MoneyDeadline {
    public var id: UUID
    public var serviceName: String          // "Hulu"
    public var serviceID: String?           // matches CancelSteps.json "id" when known
    public var amountCents: Int             // 1799
    public var currencyCode: String         // "USD"
    public var dueDate: Date                // when the charge happens
    public var billedByApple: Bool          // true → cancel via Apple's subscription settings
    public var statusRaw: String            // DeadlineStatus.rawValue (tracking/cancelled/kept/snoozed)
    public var snoozedUntil: Date?
    public var createdAt: Date
}
public enum DeadlineStatus: String, Codable, Sendable { case tracking, cancelled, kept, snoozed }

// SharedKit/Models/FrozenTask.swift: written by B
@Model public final class FrozenTask {
    public var id: UUID
    public var title: String                // "8-page history essay"
    public var dueDate: Date?
    public var statusRaw: String            // TaskStatus.rawValue
    @Relationship(deleteRule: .cascade) public var steps: [MicroStep]
    public var createdAt: Date
}
public enum TaskStatus: String, Codable, Sendable { case active, done, abandoned }

// SharedKit/Models/MicroStep.swift
@Model public final class MicroStep {
    public var order: Int
    public var text: String                 // "Open a blank doc. Type your name."
    public var seconds: Int                 // ≤ 90
    public var sourceRaw: String            // StepSource.rawValue
    public var doneAt: Date?
}
public enum StepSource: String, Codable, Sendable { case curated, appleSubscriptions, ai }

// SharedKit/Models/CompletionRecord.swift: written by A (money) and B (tasks), read by B (scoreboard)
@Model public final class CompletionRecord {
    public var id: UUID
    public var kindRaw: String              // CompletionKind.rawValue
    public var title: String                // "Cancelled Hulu" / "Wrote history essay"
    public var amountCents: Int?            // only for moneyCancelled (real $ only)
    public var date: Date
}
public enum CompletionKind: String, Codable, Sendable { case moneyCancelled, moneyKept, taskDone }
```

## 2. Protocols (implemented by one dev, injected by the App)

```swift
// Implemented by A (MoneyKit). Used by A and B (task reminders).
public protocol EscalationScheduling: Sendable {
    /// Reminders at −3d, −1d, then the final-day alarm at `due`.
    func schedule(itemID: UUID, title: String, due: Date, kind: EscalationKind) async throws
    func snooze(itemID: UUID, until: Date) async throws
    /// Call when a decision is recorded: stops all reminders and the alarm.
    func resolve(itemID: UUID) async
}
public enum EscalationKind: Sendable { case money(amountCents: Int), task }

// Implemented by B (ParachuteKit). Used by the App when Decide → "I'm frozen".
public protocol UnfreezeProviding: Sendable {
    func plan(for request: UnfreezeRequest) async throws -> UnfreezePlan
}
public enum UnfreezeRequest: Sendable {
    case cancel(serviceID: String?, serviceName: String, billedByApple: Bool)
    case task(title: String, dueDate: Date?)
}
public struct UnfreezePlan: Sendable {
    public var steps: [PlanStep]
    public var source: StepSource           // curated / appleSubscriptions / ai
    public var isSuggested: Bool            // true for AI → UI shows "Suggested steps"
}
public struct PlanStep: Sendable, Hashable {
    public var text: String
    public var seconds: Int                 // ≤ 90
    public var url: URL?                    // curated only; AI must never produce URLs
}
public enum UnfreezeOutcome: Sendable { case completed, gaveUp, snoozed(until: Date) }

// Implemented by A (MoneyKit, RevenueCat). Used by B for gating.
public protocol EntitlementsProviding: Sendable {
    var isPro: Bool { get async }
    @MainActor func presentPaywall()
}

// Implemented by B (ParachuteKit). Written to by A and B.
public protocol CompletionLedger: Sendable {
    func record(kind: CompletionKind, title: String, amountCents: Int?) async
}
```

### `EscalationScheduling` as implemented (A2, 2026-09-26)
- `due` is **the moment to act by**. For `.money` the protocol path uses generic copy (no Apple flag); MoneyKit's own screens call `schedule(deadline:)`, which knows `billedByApple` and moves everything a day earlier for Apple-billed items.
- `.task` (for B5): reminders **1 day before, 1 hour before, and at `due`**, skipping any already past, so a task due in 5 minutes still gets the at-due one. A4 adds the final-day alarm on top.
- Calling `schedule` again for the same `itemID` **replaces** its reminders. `resolve` removes pending and delivered ones. `snooze(until:)` swaps the ladder for one nudge at `until`.
- Notification `userInfo["itemID"]` carries the UUID string; tapping a reminder opens Decide via `DecideRouter`.
- **A4:** `schedule` also arms the AlarmKit chain: money at 9:00 on the last day to act, `.task` at `due` (title "<title> is due now"). `resolve` disarms it; `snooze(until:)` moves it to `until`.

## 3. UI hand-off (App target wires it)
```swift
// A's Decide screen never imports ParachuteKit. It just calls a closure:
DecideView(itemID: id, onFrozen: { request in router.sheet = .unfreeze(request, itemID: id) })   // as built (A5)

// B provides the player:
UnfreezeView(plan: UnfreezePlan, onFinish: (UnfreezeOutcome) -> Void)

// App/SheetRouter.swift + App/UnfreezeHost.swift (built in A5): provider.plan(for:) → player
// → on .completed for a money item: DeadlineDecision.cancelled.apply(…) = status + ledger.record(.moneyCancelled, …) + escalation.resolve(id)
// UnfreezeHost shows a placeholder list until B1: swap in UnfreezeView(plan:onFinish:) there.
// Ledger is also in the environment: @Environment(\.completionLedger) (SharedKit).
```

## 4. `CancelSteps.json` (content by A, loaded by B)
Location: `Packages/SharedKit/Sources/SharedKit/Resources/CancelSteps.json`
```json
{
  "version": 1,
  "services": [
    {
      "id": "example-service",
      "name": "Example Service",
      "verifiedOn": "2026-09-26",
      "verifiedBy": "A",
      "steps": [
        { "text": "Open Safari and go to example.com/account", "seconds": 30, "url": "https://example.com/account" },
        { "text": "Tap 'Membership', then 'Cancel membership'", "seconds": 30 },
        { "text": "Tap 'Finish cancellation'. Screenshot the confirmation.", "seconds": 20 }
      ]
    }
  ]
}
```
Rules (enforced by B's validation test): every service has `verifiedOn` + ≥ 1 step · every step has non-empty `text` and `seconds` ≤ 90 · URLs only where A actually verified them (logged in `docs/cancel-steps-verification.md`) · **placeholder entries like the one above must be replaced before the demo.**

## 5. Fakes (SharedKit/Fakes; for working in parallel)
`FakeEscalationScheduler` (prints and records calls) · `FakeUnfreezeProvider` (returns a fixed 5-step plan) · `FakeEntitlements(isPro: Bool)` · `InMemoryLedger`. Swap them for real implementations in `App/` as each lands.
