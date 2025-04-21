import FirebaseMessaging
import Foundation
import UserNotifications


///
protocol FPRemoteNotificationResponding: FPRIBReadyNotifying, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    
    /// 
    func handle(remoteNotification: [AnyHashable: Any]) -> Result<FPNotificationDigest, FPError>
    
    
    /// 
    func didTap(notification: FPNotificationDigest) 
    
}
