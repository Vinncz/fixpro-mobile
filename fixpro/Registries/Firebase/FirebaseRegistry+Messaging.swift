import Foundation
import FirebaseCore
import FirebaseMessaging
import UIKit


/// Extension which handles Firebase's messaging services.
extension FirebaseRegistry: MessagingDelegate {
    
    
    /// The source of truth for Firebase messaging service's initialization status.
    /// 
    /// Instantiaion of this registry does not reflect whether Firebase messaging service is up and running.
    /// This attribute checks for all the necessary conditions to determine if the shared instance of Firebase messaging service is initialized.
    var isMessagingServiceEnabled: Bool {
        Messaging.messaging().delegate != nil
        && Messaging.messaging().fcmToken != nil
        && Messaging.messaging().apnsToken != nil
    }
    
    
    
    // MARK: -- Facade
    
    /// Configures the Firebase messaging service with the given options.
    func configureMessagingService() {
        NotificationRegistry.global.enrollForRemoteNotifications()
        NotificationRegistry.global.inaugurateNotificationCenterDelegation(candidate: NotificationResponder.global)
        inaugurateMessagingServiceDelegation(candidate: self)
        FirebaseRegistry.global.configure()
    }
    
    
    
    // MARK: -- Delegation Administration
    
    /// Inaugurates the given candidate as Firebase messaging service's delegation.
    /// 
    /// Candidate must conform to ``MessagingDelegate`` and implement `messaging(_:didReceiveRegistrationToken:)` and `messaging(_:didReceiveMessage:)`.
    func inaugurateMessagingServiceDelegation(candidate: MessagingDelegate) {
        Messaging.messaging().delegate = candidate
    }
    
    
    /// Impeaches the current Firebase messaging service's delegation and sets it vacant.
    func impeachMessagingServiceDelegation() {
        Messaging.messaging().delegate = nil
    }
    
    
    
    // MARK: -- APN Token Administration
    
    /// Configures the APN token for Firebase messaging service.
    /// Without this configuration, Firebase messaging service will not send notifications to this app's instance.
    func configureAPNToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }
    
    
    
    // MARK: -- FCM Token Administration
    
    /// Handles FCM token refresh, assignment, or revokation.
    /// 
    /// ## Usage
    /// Whenever Firebase assigns or refreshes a device’s unique FCM token, take the necessary actions here.
    /// 
    /// ## Discussion
    /// An FCM token is a unique identifier that Firebase assigns to a device+app instance, 
    /// allowing Firebase Cloud Messaging to send notifications to one specific app on one device.
    /// 
    /// FCM token is NOT permanent; it refreshes periodically for many reasons including:
    /// app reinstall, app update, token expiration, and/or manual/automated revokation.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        FPLogger.log("didReceiveRegistrationToken: \(fcmToken ?? "")")
        
        // TODO: Communicate to backend
    }
    
    
    
    // MARK: -- Analytics Administration
    
    /// Informs Firebase messaging service that the app has received a remote notification.
    func letFirebaseMessagingKnow(appDidReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
}
