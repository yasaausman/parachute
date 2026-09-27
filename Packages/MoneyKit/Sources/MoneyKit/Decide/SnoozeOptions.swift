import Foundation

/// A5: the quick snooze choices, never past the last moment to act (snoozing past it means paying).
public enum SnoozeOptions {
    public struct Option: Identifiable, Hashable, Sendable {
        public var label: String
        public var date: Date
        public var id: Date { date }
    }

    public static func options(now: Date, lastMoment: Date, calendar: Calendar = .current) -> [Option] {
        var options: [Option] = [Option(label: "In 1 hour", date: now.addingTimeInterval(60 * 60))]
        if let tonight = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now), tonight > now.addingTimeInterval(60 * 60) {
            options.append(Option(label: "Tonight at 8", date: tonight))
        }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)),
           let morning = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) {
            options.append(Option(label: "Tomorrow at 9", date: morning))
        }
        return options.filter { $0.date <= lastMoment }
    }
}
