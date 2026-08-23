import Foundation
import UserNotifications

extension Notification.Name {
    static let openQuickAddExpense = Notification.Name("openQuickAddExpense")
}

enum NotificationManager {
    static let reminderIdentifier = "daily-expense-reminder"

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    static func currentAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    static func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = L.reminderNotificationTitle
        content.body = L.reminderNotificationBody
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    static func sendExpenseAlert(percent: Int) {
        let content = UNMutableNotificationContent()
        content.title = L.expenseAlertTitle
        content.body = L.expenseAlertBody(percent: percent)
        content.sound = .default
        let request = UNNotificationRequest(identifier: "expense-alert-\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    static func sendLevelUpAlert(level: Int) {
        let content = UNMutableNotificationContent()
        content.title = L.levelUpTitle
        content.body = L.levelUpBody(level: level)
        content.sound = .default
        let request = UNNotificationRequest(identifier: "level-up-\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
