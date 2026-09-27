import SwiftUI
import WidgetKit
import SwiftData
import SharedKit

// MARK: - Money Widget

struct MoneyEntry: TimelineEntry {
    let date: Date
    let deadlines: [MoneyDeadline]
}

struct MoneyProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoneyEntry {
        MoneyEntry(date: Date(), deadlines: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MoneyEntry) -> Void) {
        let entry = MoneyEntry(date: Date(), deadlines: fetchDeadlines())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MoneyEntry>) -> Void) {
        let entry = MoneyEntry(date: Date(), deadlines: fetchDeadlines())
        
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let startOfNextDay = Calendar.current.startOfDay(for: nextDay)
        let timeline = Timeline(entries: [entry], policy: .after(startOfNextDay))
        completion(timeline)
    }
    
    private func fetchDeadlines() -> [MoneyDeadline] {
        guard let container = try? SharedStore.makeContainer(inMemory: false) else { return [] }
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<MoneyDeadline>(
            predicate: #Predicate { $0.statusRaw == "tracking" },
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )
        descriptor.fetchLimit = 3
        let deadlines = (try? context.fetch(descriptor)) ?? []
        return deadlines
    }
}

struct MoneyWidgetView: View {
    var entry: MoneyProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if entry.deadlines.isEmpty {
                Text("No deadlines")
                    .font(.headline)
                Text("You're all clear! 🌿")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                if family == .systemMedium {
                    ForEach(entry.deadlines) { deadline in
                        deadlineRow(deadline)
                    }
                    Spacer(minLength: 0)
                } else {
                    if let first = entry.deadlines.first {
                        deadlineCard(first)
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
    
    @ViewBuilder
    private func deadlineRow(_ deadline: MoneyDeadline) -> some View {
        HStack {
            Text(deadline.serviceName)
                .font(.subheadline)
                .bold()
            Spacer()
            Text(deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode))
                .font(.subheadline)
            Text("· \(daysString(for: deadline.dueDate))")
                .font(.subheadline)
                .foregroundColor(color(for: deadline.dueDate))
        }
    }
    
    @ViewBuilder
    private func deadlineCard(_ deadline: MoneyDeadline) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(deadline.serviceName)
                .font(.headline)
            Text(deadline.amountCents.formattedCents(currencyCode: deadline.currencyCode))
                .font(.title2)
                .bold()
            Spacer()
            Text(daysString(for: deadline.dueDate))
                .font(.subheadline)
                .foregroundColor(color(for: deadline.dueDate))
                .bold()
        }
    }
    
    private func daysString(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: date))
        let days = components.day ?? 0
        if days < 0 { return "Overdue" }
        if days == 0 { return "Today" }
        if days == 1 { return "In 1 day" }
        return "In \(days) days"
    }
    
    private func color(for date: Date) -> Color {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: date))
        let days = components.day ?? 0
        if days <= 0 { return .red }
        if days <= 3 { return .orange }
        return Theme.money
    }
}

struct MoneyWidget: Widget {
    let kind: String = "MoneyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoneyProvider()) { entry in
            MoneyWidgetView(entry: entry)
        }
        .configurationDisplayName("Money Deadlines")
        .description("Keep track of upcoming subscriptions.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Task Widget

struct TaskEntry: TimelineEntry {
    let date: Date
    let activeTask: FrozenTask?
}

struct TaskProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), activeTask: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        let entry = TaskEntry(date: Date(), activeTask: fetchActiveTask())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let entry = TaskEntry(date: Date(), activeTask: fetchActiveTask())
        let nextUpdate = Date().addingTimeInterval(15 * 60)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchActiveTask() -> FrozenTask? {
        guard let container = try? SharedStore.makeContainer(inMemory: false) else { return nil }
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<FrozenTask>(
            predicate: #Predicate { $0.statusRaw == "active" }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
}

struct TaskWidgetView: View {
    var entry: TaskProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let task = entry.activeTask {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(Theme.frozen)
                
                let steps = task.steps.sorted { $0.order < $1.order }
                let doneCount = steps.filter { $0.doneAt != nil }.count
                let totalCount = steps.count
                
                if totalCount > 0 {
                    Text("Step \(doneCount + 1) of \(totalCount)")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.secondary)
                    
                    if let nextStep = steps.first(where: { $0.doneAt == nil }) {
                        Text(nextStep.text)
                            .font(.caption)
                            .lineLimit(3)
                    }
                } else {
                    Text("No steps yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            } else {
                Text("No active tasks.")
                    .font(.headline)
                Text("You're all caught up! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct TaskWidget: Widget {
    let kind: String = "TaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskProvider()) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Active Task")
        .description("Your current unfrozen task.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Widget Bundle

@main
struct ParachuteWidgetBundle: WidgetBundle {
    var body: some Widget {
        MoneyWidget()
        TaskWidget()
    }
}
