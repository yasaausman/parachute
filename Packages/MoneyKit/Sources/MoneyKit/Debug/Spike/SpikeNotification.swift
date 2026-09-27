import Foundation
import UserNotifications

// A0 platform spike: a plain local notification (no capability needed on a free Apple ID ⚠️ confirm).
public enum SpikeNotification {
    public static func requestAndSchedule(in seconds: TimeInterval = 10) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        guard try await center.requestAuthorization(options: [.alert, .sound, .badge]) else { return false }
        let content = UNMutableNotificationContent()
        content.title = "Hulu"
        content.body = "$17.99 leaves your account tomorrow."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        try await center.add(UNNotificationRequest(identifier: "spike.notification", content: content, trigger: trigger))
        return true
    }
}
