import SharedKit
import SwiftData
import SwiftUI

/// The Tasks tab: active tasks to pick back up, then finished ones. Tap to resume; swipe to let one go.
public struct TaskListView: View {
    @Query(sort: \FrozenTask.createdAt, order: .reverse) private var tasks: [FrozenTask]
    @Environment(\.modelContext) private var context
    @Environment(\.parachute) private var services
    @State private var showingEntry = false
    @State private var playing: FrozenTask?

    public init() {}

    private var active: [FrozenTask] { tasks.filter { $0.status == .active } }
    private var finished: [FrozenTask] { tasks.filter { $0.status == .done } }

    public var body: some View {
        NavigationStack {
            Group {
                if active.isEmpty && finished.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing frozen right now", systemImage: "snowflake")
                    } description: {
                        Text("When something feels too big to start, tap Get unstuck.")
                    } actions: {
                        frozenButton
                    }
                    .untaxScreen()
                } else {
                    List {
                        if !active.isEmpty {
                            Section("Pick up where you left off") {
                                ForEach(active) { task in
                                    Button { playing = task } label: { TaskRow(task: task) }
                                        .buttonStyle(.plain)
                                        .swipeActions {
                                            Button("Let it go", systemImage: "leaf") { letGo(task) }
                                                .tint(Theme.inkMuted)
                                        }
                                        .accessibilityHint("Resumes this task")
                                }
                            }
                        }
                        if !finished.isEmpty {
                            Section("Unfrozen") {
                                ForEach(finished) { TaskRow(task: $0) }
                                    .onDelete { offsets in
                                        offsets.map { finished[$0] }.forEach(context.delete)
                                        try? context.save()
                                    }
                            }
                        }
                    }
                    .untaxScreen()
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Get unstuck", systemImage: "plus") { showingEntry = true }
                }
            }
            .sheet(isPresented: $showingEntry) { FrozenTaskEntryView() }
            .fullScreenCover(item: $playing) { task in
                TaskPlayerView(task: task) { playing = nil }
            }
        }
        .tint(Palette.frozenInk)
    }

    private var frozenButton: some View {
        Button("Get unstuck", systemImage: "snowflake") { showingEntry = true }
            .buttonStyle(.untaxFrozen)
            .padding(.horizontal, Theme.screenPadding * 2)
    }

    /// No shame: the task just leaves the list and its reminders stop.
    private func letGo(_ task: FrozenTask) {
        let id = task.id
        let services = services
        TaskStore.setStatus(.abandoned, for: task, in: context)
        Task { await services.reminders?.resolve(taskID: id) }
    }
}

struct TaskRow: View {
    let task: FrozenTask

    var body: some View {
        let total = task.steps.count
        let done = task.steps.filter { $0.doneAt != nil }.count
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(task.title)
                    .font(Theme.headline(.headline))
                    .foregroundStyle(Theme.ink)
                Spacer()
                if task.status == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Palette.moneyInk)
                        .accessibilityLabel("Done")
                }
            }
            if task.status == .active {
                HStack(spacing: 6) {
                    if total > 0 { Text("\(done) of \(total) done") }
                    // Only upcoming deadlines: a past one would read as "you're late" (CLAUDE.md rule 10).
                    if let due = task.dueDate, due > .now {
                        Text("·")
                        Label(due.formatted(.relative(presentation: .named)), systemImage: "clock")
                    }
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(Theme.inkMuted)
            }
            if total > 0, task.status == .active {
                StepTicks(done: done, total: total)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
