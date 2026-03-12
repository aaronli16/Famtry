//
//  NotificationManager.swift
//  famtry
//
//  Created by Katharina Cheng on 3/12/26.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        print("Notification permission granted: \(granted)")
    }

    func scheduleExpirationNotification(for item: PantryItem) async {
        guard let expirationDate = item.expirationDate else { return }
        
        var calendar = Calendar.current
        let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: expirationDate)!

        var components = calendar.dateComponents([.year, .month, .day], from: oneDayBefore)
        components.hour = 9
        components.minute = 0

        guard let triggerDate = calendar.date(from: components) else { return }

        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Item expiring soon"
        content.body = "\(item.name) will expire in 1 day."
        content.sound = .default

        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: notificationID(for: item.id),
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled notification for \(item.name)")
        } catch {
            print("Failed to schedule notification: \(error.localizedDescription)")
        }
    }

    func removeExpirationNotification(for itemId: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID(for: itemId)])
    }

    func rescheduleExpirationNotification(for item: PantryItem) async {
        removeExpirationNotification(for: item.id)
        await scheduleExpirationNotification(for: item)
    }

    private func notificationID(for itemId: String) -> String {
        "item-expiration-\(itemId)"
    }
}
