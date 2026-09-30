import SharedKit
import SwiftData
import SwiftUI
import WidgetKit

// Widgets read the shared App Group store and immediately copy what they need into plain
// Sendable value snapshots. @Model objects never leave the fetch helper: they are not Sendable
// and become invalid once their ModelContext goes away.

// MARK: - Snapshots

struct DeadlineSnapshot: Sendable, Hashable, Identifiable {
    let id: UUID
    let serviceName: String
    let amountCents: Int
    let currencyCode: String
    let dueDate: Date
}

struct TaskSnapshot: Sendable, Hashable, Identifiable {
    let id: UUID
    let title: String
    /// 1-based index of the next step to do (equals `totalSteps` when everything is done).
    let stepIndex: Int
    let totalSteps: Int
    /// Nil when there are no steps yet or every step is done.
    let nextStepText: String?
}

// MARK: - Fetching

enum WidgetStore {
    static func upcomingDeadlines(now: Date = .now, limit: Int = 3) -> [DeadlineSnapshot] {
        guard let container = try? SharedStore.makeContainer() else { return [] }
        let context = ModelContext(container)

        let tracking = DeadlineStatus.tracking.rawValue
        // Keep ones due today or yesterday; skip anything more than a day past due.
        let cutoff = now.addingTimeInterval(-24 * 60 * 60)
        var descriptor = FetchDescriptor<MoneyDeadline>(
            predicate: #Predicate<MoneyDeadline> { $0.statusRaw == tracking && $0.dueDate >= cutoff },
            sortBy: [SortDescriptor(\MoneyDeadline.dueDate, order: .forward)]
        )
        descriptor.fetchLimit = limit

        let deadlines = (try? context.fetch(descriptor)) ?? []
        return deadlines.map {
            DeadlineSnapshot(
                id: $0.id,
                serviceName: $0.serviceName,
                amountCents: $0.amountCents,
                currencyCode: $0.currencyCode,
                dueDate: $0.dueDate
            )
        }
    }

    static func activeTask() -> TaskSnapshot? {
        guard let container = try? SharedStore.makeContainer() else { return nil }
        let context = ModelContext(container)

        let active = TaskStatus.active.rawValue
        var descriptor = FetchDescriptor<FrozenTask>(
            predicate: #Predicate<FrozenTask> { $0.statusRaw == active },
            sortBy: [SortDescriptor(\FrozenTask.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        guard let task = (try? context.fetch(descriptor))?.first else { return nil }

        let steps = task.steps.sorted { $0.order < $1.order }
        let doneCount = steps.filter { $0.doneAt != nil }.count
        let next = steps.first { $0.doneAt == nil }
        return TaskSnapshot(
            id: task.id,
            title: task.title,
            stepIndex: min(doneCount + 1, max(steps.count, 1)),
            totalSteps: steps.count,
            nextStepText: next?.text
        )
    }
}

// MARK: - Countdown helpers

enum Countdown {
    /// Whole calendar days from `reference` to `date` (negative when past).
    static func days(until date: Date, from reference: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: reference)
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    static func text(days: Int) -> String {
        switch days {
        case ..<0: return "due yesterday"
        case 0: return "today"
        case 1: return "tomorrow"
        default: return "in \(days) days"
        }
    }

    static func color(days: Int) -> Color {
        if days <= 1 { return WidgetInk.urgent }
        if days <= 3 { return WidgetInk.soon }
        return WidgetInk.muted
    }
}

/// Contrast-safe text colors from SharedKit's `Theme`.
private enum WidgetInk {
    static let money = Theme.moneyText
    static let frozen = Theme.frozenText
    static let soon = Theme.accentText
    static let urgent = Theme.urgentText
    static let muted = Theme.inkMuted
}

// MARK: - Money Widget

struct MoneyEntry: TimelineEntry {
    let date: Date
    let deadlines: [DeadlineSnapshot]
}

struct MoneyProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoneyEntry {
        MoneyEntry(date: .now, deadlines: MoneyEntry.sampleDeadlines)
    }

    func getSnapshot(in context: Context, completion: @escaping (MoneyEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }
        completion(MoneyEntry(date: .now, deadlines: WidgetStore.upcomingDeadlines()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoneyEntry>) -> Void) {
        let now = Date.now
        let deadlines = WidgetStore.upcomingDeadlines(now: now)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        // One entry now, then one at each of the next 3 midnights so "in 3 days" stays correct.
        var entries = [MoneyEntry(date: now, deadlines: deadlines)]
        for offset in 1...3 {
            if let day = calendar.date(byAdding: .day, value: offset, to: today) {
                entries.append(MoneyEntry(date: day, deadlines: deadlines))
            }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct MoneyWidgetView: View {
    let entry: MoneyEntry
    @Environment(\.widgetFamily) private var family

    /// Re-applies the "more than a day past due" cut against this entry's date.
    private var visible: [DeadlineSnapshot] {
        entry.deadlines.filter { days(for: $0) >= -1 }
    }

    private func days(for deadline: DeadlineSnapshot) -> Int {
        Countdown.days(until: deadline.dueDate, from: entry.date)
    }

    var body: some View {
        content
            .widgetURL(URL(string: "parachute://money"))
            .containerBackground(for: .widget) {
                if family == .accessoryRectangular {
                    Color.clear
                } else {
                    Theme.paper
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryRectangular:
            accessory
        case .systemMedium:
            medium
        default:
            small
        }
    }

    // Lock Screen: one line.
    @ViewBuilder
    private var accessory: some View {
        if let first = visible.first {
            let d = days(for: first)
            ViewThatFits {
                Text("\(first.serviceName) · \(first.amountCents.formattedCents(currencyCode: first.currencyCode)) \(Countdown.text(days: d))")
                Text("\(first.serviceName) · \(Countdown.text(days: d))")
            }
            .font(.headline)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("No trials to watch.")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var small: some View {
        if let first = visible.first {
            let d = days(for: first)
            VStack(alignment: .leading, spacing: 4) {
                Label("Next charge", systemImage: "dollarsign.circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.inkMuted)
                Text(first.serviceName)
                    .font(Theme.headline(.headline))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text(first.amountCents.formattedCents(currencyCode: first.currencyCode))
                    .font(Theme.number().monospacedDigit())
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Spacer(minLength: 0)
                Text(Countdown.text(days: d))
                    .font(Theme.headline(.subheadline))
                    .foregroundStyle(Countdown.color(days: d))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            emptyState
        }
    }

    @ViewBuilder
    private var medium: some View {
        if visible.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Label("Trials to watch", systemImage: "dollarsign.circle")
                    .font(.caption)
                    .foregroundStyle(Theme.inkMuted)
                ForEach(visible.prefix(3)) { deadline in
                    let d = days(for: deadline)
                    HStack(spacing: 8) {
                        Text(deadline.serviceName)
                            .font(Theme.headline(.subheadline))
                            .foregroundStyle(Theme.ink)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode))
                            .font(.system(.subheadline, design: .monospaced).monospacedDigit())
                            .foregroundStyle(Theme.ink)
                        Text(Countdown.text(days: d))
                            .font(Theme.headline(.subheadline))
                            .foregroundStyle(Countdown.color(days: d))
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "dollarsign.circle")
                .foregroundStyle(WidgetInk.soon)
            Text("No trials to watch.")
                .font(Theme.headline(.headline))
                .foregroundStyle(Theme.ink)
            Text("Add one when you sign up for something.")
                .font(.caption)
                .foregroundStyle(Theme.inkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct MoneyWidget: Widget {
    let kind: String = "MoneyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoneyProvider()) { entry in
            MoneyWidgetView(entry: entry)
        }
        .configurationDisplayName("Trial countdown")
        .description("See your next free-trial charge before it happens.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

extension MoneyEntry {
    static let sampleDeadlines: [DeadlineSnapshot] = [
        DeadlineSnapshot(id: UUID(), serviceName: "Hulu", amountCents: 1799, currencyCode: "USD",
                         dueDate: .now.addingTimeInterval(3 * 24 * 60 * 60)),
        DeadlineSnapshot(id: UUID(), serviceName: "Peacock", amountCents: 799, currencyCode: "USD",
                         dueDate: .now.addingTimeInterval(1 * 24 * 60 * 60)),
        DeadlineSnapshot(id: UUID(), serviceName: "Duolingo", amountCents: 1299, currencyCode: "USD",
                         dueDate: .now.addingTimeInterval(9 * 24 * 60 * 60)),
    ].sorted { $0.dueDate < $1.dueDate }
}

// MARK: - Task Widget

struct TaskEntry: TimelineEntry {
    let date: Date
    let task: TaskSnapshot?
}

struct TaskProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: .now, task: TaskEntry.sampleTask)
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }
        completion(TaskEntry(date: .now, task: WidgetStore.activeTask()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let now = Date.now
        let entry = TaskEntry(date: now, task: WidgetStore.activeTask())
        let next = now.addingTimeInterval(30 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct TaskWidgetView: View {
    let entry: TaskEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .widgetURL(URL(string: "parachute://tasks"))
            .containerBackground(for: .widget) {
                if family == .accessoryRectangular {
                    Color.clear
                } else {
                    Theme.paper
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if family == .accessoryRectangular {
            accessory
        } else {
            small
        }
    }

    private func progressText(_ task: TaskSnapshot) -> String {
        if task.totalSteps == 0 { return "Ready when you are" }
        if task.nextStepText == nil { return "All \(task.totalSteps) steps done" }
        return "Step \(task.stepIndex) of \(task.totalSteps)"
    }

    @ViewBuilder
    private var accessory: some View {
        if let task = entry.task {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(task.title) · \(progressText(task))")
                    .font(.headline)
                    .lineLimit(1)
                if let next = task.nextStepText {
                    Text(next)
                        .font(.caption)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("Nothing frozen right now.")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var small: some View {
        if let task = entry.task {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(Theme.headline(.headline))
                    .foregroundStyle(WidgetInk.frozen)
                    .lineLimit(2)
                Text(progressText(task))
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundStyle(Theme.inkMuted)
                Spacer(minLength: 0)
                if let next = task.nextStepText {
                    Text(next)
                        .font(Theme.headline(.subheadline))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(3)
                } else if task.totalSteps == 0 {
                    Text("Open Untax for your first tiny step.")
                        .font(.caption)
                        .lineLimit(3)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "snowflake")
                    .foregroundStyle(WidgetInk.frozen)
                Text("Nothing frozen right now.")
                    .font(Theme.headline(.headline))
                    .foregroundStyle(Theme.ink)
                Text("If something feels stuck, Untax can break it down.")
                    .font(.caption)
                    .foregroundStyle(Theme.inkMuted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct TaskWidget: Widget {
    let kind: String = "TaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskProvider()) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Next tiny step")
        .description("The one small step to take next on your frozen task.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

extension TaskEntry {
    static let sampleTask = TaskSnapshot(
        id: UUID(),
        title: "Essay",
        stepIndex: 3,
        totalSteps: 7,
        nextStepText: "Write one sentence about why the war started."
    )
}

// MARK: - Widget Bundle

@main
struct ParachuteWidgetBundle: WidgetBundle {
    var body: some Widget {
        MoneyWidget()
        TaskWidget()
    }
}

// MARK: - Previews

#Preview("Money small", as: .systemSmall) {
    MoneyWidget()
} timeline: {
    MoneyEntry(date: .now, deadlines: MoneyEntry.sampleDeadlines)
    MoneyEntry(date: .now, deadlines: [])
}

#Preview("Money medium", as: .systemMedium) {
    MoneyWidget()
} timeline: {
    MoneyEntry(date: .now, deadlines: MoneyEntry.sampleDeadlines)
}

#Preview("Task small", as: .systemSmall) {
    TaskWidget()
} timeline: {
    TaskEntry(date: .now, task: TaskEntry.sampleTask)
    TaskEntry(date: .now, task: nil)
}

#Preview("Task lock screen", as: .accessoryRectangular) {
    TaskWidget()
} timeline: {
    TaskEntry(date: .now, task: TaskEntry.sampleTask)
}
