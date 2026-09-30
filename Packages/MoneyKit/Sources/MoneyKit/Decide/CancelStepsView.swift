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
            if deadline.billedByApple {
                Section {
                    Button {
                        openURL(AppleSubscriptions.manageURL)
                    } label: {
                        Label("Open Apple Subscriptions", systemImage: "apple.logo")
                    }
                    .buttonStyle(.untax)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                } footer: {
                    Text("Billed by Apple: cancel at least a day before the charge. Cancelling a free trial may end it right away.")
                }
            }

            if let curated {
                Section {
                    ForEach(Array(curated.steps.enumerated()), id: \.offset) { index, step in
                        StepRow(number: index + 1, step: step) { url in openURL(url) }
                    }
                } header: {
                    Text("Cancel \(deadline.serviceName)")
                        .font(Theme.headline())
                        .foregroundStyle(Theme.ink)
                        .textCase(nil)
                } footer: {
                    Text("Checked by hand on \(curated.verifiedOn).")
                }
            } else if deadline.billedByApple {
                Section {
                    ForEach(Array(AppleSubscriptions.steps(serviceName: deadline.serviceName).enumerated()), id: \.offset) { index, step in
                        StepRow(number: index + 1, step: step) { url in openURL(url) }
                    }
                    Button("Or cancel on Apple's website") { openURL(AppleSubscriptions.webURL) }
                        .font(.subheadline)
                        .foregroundStyle(Theme.accentText)
                        .frame(minHeight: 44)
                } header: {
                    Text("If the button doesn't open it")
                } footer: {
                    Text("Steps from Apple Support, \"Cancel a subscription from Apple\".")
                }
            } else {
                Section {
                    Text("No saved steps for \(deadline.serviceName) yet. Look for Account, Billing, or Subscription in its app or website.")
                        .foregroundStyle(Theme.ink)
                } footer: {
                    Text("Stuck? \"Get unstuck\" walks you through it one step at a time.")
                }
            }

            Section {
                VStack(spacing: 12) {
                    Button {
                        onDone()
                    } label: {
                        Label("Done, it's cancelled", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(.untax)
                    Button {
                        onFrozen()
                    } label: {
                        Label("I'm stuck", systemImage: "snowflake")
                    }
                    .buttonStyle(.untaxFrozen)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
        .listRowBackground(Theme.surface)
        .tint(Theme.accentText)
        .untaxScreen()
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
                .font(Theme.number(.headline))
                .monospacedDigit()
                .foregroundStyle(Theme.accentText)
                .accessibilityLabel("Step \(number)")
            VStack(alignment: .leading, spacing: 6) {
                Text(step.text)
                    .foregroundStyle(Theme.ink)
                if let url = step.url {
                    Button("Open link") { open(url) }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accentText)
                        .frame(minHeight: 44)
                        .buttonStyle(.borderless)
                }
            }
        }
    }
}
