import SharedKit
import SwiftUI

/// Decide → 🧊 "Get unstuck" (Dev A): fetches the plan and plays it. Present it full screen:
///
///     .fullScreenCover(item: $frozen) { request in
///         UnfreezeFlowView(request: request, win: .money(cents: deadline.amountCents)) { outcome in ... }
///     }
///
/// The caller records the decision (e.g. `.completed` on a cancel → mark cancelled + ledger `.moneyCancelled`).
public struct UnfreezeFlowView: View {
    let request: UnfreezeRequest
    let win: CelebrationView.Win?
    let onFinish: (UnfreezeOutcome) -> Void

    @Environment(\.parachute) private var services
    @State private var plan: UnfreezePlan?

    public init(request: UnfreezeRequest, win: CelebrationView.Win? = nil, onFinish: @escaping (UnfreezeOutcome) -> Void) {
        self.request = request
        self.win = win
        self.onFinish = onFinish
    }

    public var body: some View {
        if let plan {
            UnfreezeView(plan: plan, goal: request.goal, win: win, onFinish: onFinish)
        } else {
            ProgressView("Finding your first step…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task {
                    let services = services
                    plan = (try? await services.engine.plan(for: request)) ?? Self.fallback(for: request)
                }
        }
    }

    static func fallback(for request: UnfreezeRequest) -> UnfreezePlan {
        switch request {
        case .cancel(_, let name, _): UnfreezePlan(steps: Fallbacks.cancel(name), source: .ai, isSuggested: true)
        case .task(let title, _): UnfreezePlan(steps: Fallbacks.task(title), source: .ai, isSuggested: true)
        }
    }
}
