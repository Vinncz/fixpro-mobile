import Foundation
import UserNotifications


/// Handles local notifications.
extension NotificationResponder: UNUserNotificationCenterDelegate {
    
    
    /// Handles what happens when a notification is tapped on.
    /// 
    /// Use this method to optionally deeplink the given notification 
    /// with a screen from your view hierarchy.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationPayload = response.notification.request.content.userInfo
        FPLogger.log(notificationPayload)
        
        // TODO: Implement deeplinking
        completionHandler()
    }
    
    
    /// Decides whether to show the given notification (as an alert) or to suppress it.
    /// 
    /// Use this method to determine the degree of importance of the given notification,
    /// then return the appropriate level of presentation based on your assessment.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        FPLogger.log(notification.request.content.userInfo)
        
        // TODO: Implement determination function
        completionHandler([.banner, .badge, .sound])
    }
    
}
