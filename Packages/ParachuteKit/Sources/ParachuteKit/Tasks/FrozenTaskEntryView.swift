import SharedKit
import SwiftData
import SwiftUI

/// B4: "I'm frozen" → "What's overwhelming you?" (+ optional due time) → atomizer → player.
/// Present in a sheet; it closes itself when the player finishes.
public struct FrozenTaskEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.parachute) private var services

    @State private var title = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date.now.addingTimeInterval(3 * 3600)
    @State private var isWorking = false
    @State private var task: FrozenTask?
    @FocusState private var focused: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init() {}

    private var startButton: some View {
        Button(action: start) {
            Group {
                if isWorking {
                    HStack { ProgressView(); Text("Finding your first step…") }
                } else {
                    Label("Help me start", systemImage: "arrow.right.circle.fill")
                }
            }
            .font(.title3.bold())
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Palette.frozenFill)
        .disabled(trimmed.isEmpty || isWorking)
    }

    private var trimmed: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g. 8-page history essay", text: $title, axis: .vertical)
                        .lineLimit(2...5)
                        .focused($focused)
                        .submitLabel(.go)
                } header: {
                    Text("What's overwhelming you?")
                } footer: {
                    Text("Messy is fine. We'll make the first step tiny.")
                }

                Section {
                    Toggle("It has a deadline", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                    }
                } footer: {
                    if hasDueDate {
                        Text("Parachute will nudge you before it's due.")
                    }
                }

                // At accessibility sizes the pinned button would cover the form, so it scrolls with it.
                if dynamicTypeSize.isAccessibilitySize {
                    Section { startButton }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !dynamicTypeSize.isAccessibilitySize {
                    startButton
                        .padding()
                        .background(.bar)
                }
            }
            .navigationTitle("I'm frozen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                }
            }
            .navigationDestination(item: $task) { task in
                TaskPlayerView(task: task) { dismiss() }
            }
            .onAppear { focused = true }
        }
        .interactiveDismissDisabled(task != nil)
        .tint(Palette.frozenFill)
    }

    private func start() {
        guard !trimmed.isEmpty else { return }
        let title = trimmed
        let due = hasDueDate ? dueDate : nil
        let services = services
        isWorking = true
        Task {
            let plan = (try? await services.engine.plan(for: .task(title: title, dueDate: due)))
                ?? UnfreezePlan(steps: Fallbacks.task(title), source: .ai, isSuggested: true)
            let task = TaskStore.create(title: title, dueDate: due, plan: plan, in: context)
            if let due {
                try? await services.reminders?.schedule(taskID: task.id, title: title, due: due)
            }
            isWorking = false
            self.task = task
        }
    }
}

#Preview {
    FrozenTaskEntryView()
        .modelContainer(for: [FrozenTask.self, MicroStep.self], inMemory: true)
}
