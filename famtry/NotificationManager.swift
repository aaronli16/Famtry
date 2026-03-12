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
        guard let expirationDate = item.expirationDate else {
            print("No expiration date for \(item.name)")
            return
        }

        let calendar = Calendar.current
        
        // Normalize to local start of day for the selected expiration date
        let expirationDayStart = calendar.startOfDay(for: expirationDate)
        
        guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: expirationDayStart) else {
            print("Could not calculate day before expiration")
            return
        }

        guard let triggerDate = calendar.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: dayBefore
        ) else {
            print("Could not create trigger date")
            return
        }

        print("Now: \(Date())")
        print("Expiration raw: \(expirationDate)")
        print("Expiration day start: \(expirationDayStart)")
        print("Trigger: \(triggerDate)")

        guard triggerDate > Date() else {
            print("Trigger already passed, not scheduling")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Item expiring soon"
        content.body = "\(item.name) will expire in 1 day."
        content.sound = .default

        let triggerComponents = calendar.dateComponents(
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

//    func scheduleTestNotification() async {
//        let content = UNMutableNotificationContent()
//        content.title = "Test notification"
//        content.body = "This should appear in 1 minute."
//        content.sound = .default
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
//
//        let request = UNNotificationRequest(
//            identifier: "test-notification",
//            content: content,
//            trigger: trigger
//        )
//
//        do {
//            try await UNUserNotificationCenter.current().add(request)
//            print("Scheduled test notification")
//        } catch {
//            print("Failed to schedule test notification: \(error.localizedDescription)")
//        }
//    }
    
    private func notificationID(for itemId: String) -> String {
        "item-expiration-\(itemId)"
    }
}
