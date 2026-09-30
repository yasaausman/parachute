import SharedKit
import SwiftUI

/// "Snooze": a few quick times, none past the last moment to act.
struct SnoozeView: View {
    let deadline: MoneyDeadline
    let onSnooze: (Date) -> Void

    @State private var custom = Date.now.addingTimeInterval(2 * 60 * 60)

    private var lastMoment: Date { deadline.lastMomentToAct }

    var body: some View {
        List {
            let options = SnoozeOptions.options(now: .now, lastMoment: lastMoment)
            if !options.isEmpty {
                Section {
                    ForEach(options) { option in
                        Button {
                            onSnooze(option.date)
                        } label: {
                            LabeledContent(option.label, value: option.date.formatted(date: .omitted, time: .shortened))
                        }
                        .tint(.primary)
                    }
                }
            }

            if lastMoment > .now {
                Section {
                    DatePicker("Pick a time", selection: $custom, in: Date.now...lastMoment)
                    Button("Snooze until then") { onSnooze(custom) }
                } footer: {
                    Text("To skip the charge, decide by \(lastMoment.formatted(date: .abbreviated, time: .shortened)). Untax won't let a snooze go past that.")
                }
            } else {
                Section {
                    Text("The last moment to cancel before the charge has passed. You can still cancel or keep it.")
                }
            }
        }
        .navigationTitle("Snooze")
        .navigationBarTitleDisplayMode(.inline)
    }
}
