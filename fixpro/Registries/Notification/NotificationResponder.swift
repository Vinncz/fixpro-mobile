import Foundation
import FirebaseMessaging
import UIKit
import UserNotifications


/// Reacts to notifications.
/// 
/// Use the ``NotificationResponder`` to take actions when a notification arrives or is interacted with.
class NotificationResponder: NSObject {
    
    
    /// Constituently a singleton.
    private override init() {}
    
    
    /// The one instance of ``NotificationResponder`` per lifecycle.
    static let global = NotificationResponder()
    
}


/// Handles remote notifications.
extension NotificationResponder {
    
    
    /// Handles silent remote notifications that necessitates background fetch.
    /// 
    /// Use this method to determine whether the notification signals for any fetching of data.
    /// If applicable, perform the fetching operation--otherwise, invoke the completionHandler 
    /// with `.newData`, `.noData`, or `.failed` to inform the system of your resolve.
    func respond(to notificationPayload: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        FPLogger.log("Did receive silent remote notification \(notificationPayload)")
        
        // TODO: Handle silent remote notification
        completionHandler(.noData)
    }
    
    
    /// Handles non-silent remote notifications that's received while the app is in the foreground (running).
    func respond(to notificationPayload: [AnyHashable: Any]) {
        FPLogger.log("Did receive non-silent remote notification \(notificationPayload)")
        
        
    }
    
}


extension NotificationResponder {
    
    
    /// Sets the notification badge to the given value.
    /// 
    /// Effective when permission for badges are given.
    func setBadgeCount(to newCount: Int) {
        UNUserNotificationCenter.current().setBadgeCount(newCount)
    }
    
}
