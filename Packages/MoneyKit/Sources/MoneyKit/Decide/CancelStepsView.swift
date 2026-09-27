import SharedKit
import SwiftUI

/// "Cancel it": every step on one screen, for when you're ready to act.
/// (Frozen? The Unfreeze player shows the same steps one at a time.)
struct CancelStepsView: View {
    @Environment(\.openURL) private var openURL
    let deadline: MoneyDeadline
    let onDone: () -> Void
    let onFrozen: () -> Void

    private var curated: CancelStepsFile.Service? {
        guard let id = deadline.serviceID else { return nil }
        return CuratedServices.load().first { $0.id == id }
    }

    var body: some View {
        List {
            if let curated {
                Section {
                    ForEach(Array(curated.steps.enumerated()), id: \.offset) { index, step in
                        StepRow(number: index + 1, step: step) { url in openURL(url) }
                    }
                } header: {
                    Text("Cancel \(deadline.serviceName)")
                } footer: {
                    Text("Checked by hand on \(curated.verifiedOn).")
                }
            } else if deadline.billedByApple {
                Section {
                    // The generic Apple path (seen end to end with Apple One, docs/cancel-steps-verification.md).
                    StepRow(number: 1, step: PlanStep(text: "Open Settings. Tap your name at the top, then 'Subscriptions'.", seconds: 20)) { _ in }
                    StepRow(number: 2, step: PlanStep(text: "Tap '\(deadline.serviceName)'.", seconds: 10)) { _ in }
                    StepRow(number: 3, step: PlanStep(text: "Tap 'Cancel Subscription' (or 'Cancel Free Trial'), then confirm.", seconds: 20)) { _ in }
                } header: {
                    Text("Cancel through Apple")
                } footer: {
                    Text("Apple needs this at least a day before the charge. Cancelling a free trial may end it right away.")
                }
            } else {
                Section {
                    Text("There are no saved steps for \(deadline.serviceName) yet. Look for Account, Billing, or Subscription in its app or website.")
                } footer: {
                    Text("Stuck? \"I'm frozen\" walks you through it one step at a time.")
                }
            }

            Section {
                Button {
                    onDone()
                } label: {
                    Label("Done, it's cancelled", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                }
                Button {
                    onFrozen()
                } label: {
                    Label("I'm stuck", systemImage: "snowflake")
                }
            }
        }
        .navigationTitle("Cancel it")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StepRow: View {
    let number: Int
    let step: PlanStep
    let open: (URL) -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(number)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 6) {
                Text(step.text)
                if let url = step.url {
                    Button("Open link") { open(url) }
                        .font(.subheadline)
                }
            }
        }
    }
}
