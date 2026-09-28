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
                        Text("When something feels too big to start, tap I'm frozen.")
                    } actions: {
                        frozenButton
                    }
                } else {
                    List {
                        if !active.isEmpty {
                            Section("Pick up where you left off") {
                                ForEach(active) { task in
                                    Button { playing = task } label: { TaskRow(task: task) }
                                        .buttonStyle(.plain)
                                        .swipeActions {
                                            Button("Let it go", systemImage: "leaf") { letGo(task) }
                                                .tint(.gray)
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
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("I'm frozen", systemImage: "plus") { showingEntry = true }
                }
            }
            .sheet(isPresented: $showingEntry) { FrozenTaskEntryView() }
            .fullScreenCover(item: $playing) { task in
                TaskPlayerView(task: task) { playing = nil }
            }
        }
    }

    private var frozenButton: some View {
        Button("I'm frozen", systemImage: "snowflake") { showingEntry = true }
            .buttonStyle(.borderedProminent)
            .tint(Palette.frozenFill)
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
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                if task.status == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Palette.moneyInk)
                        .accessibilityLabel("Done")
                }
            }
            if let due = task.dueDate, task.status == .active {
                Label(due.formatted(.relative(presentation: .named)), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if total > 0, task.status == .active {
                ProgressView(value: Double(done), total: Double(total))
                    .tint(Palette.frozenFill)
                Text("Step \(min(done + 1, total)) of \(total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
