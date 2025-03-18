import Foundation
import UIKit
import UserNotifications


/// Sends and schedules local notifications.
/// 
/// Use the ``NotificationSender`` as a centralized point where you send
class NotificationSender {
    
    func scheduleLocalNotification(title: String, body: String, delay: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendings in
            UNUserNotificationCenter.current().setBadgeCount(pendings.count + 1)
        }
    }
    
}
