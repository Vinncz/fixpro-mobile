import Foundation
import UIKit
import UserNotifications

class NotificationRegistry {
    
    
    /// Constituently a singleton.
    private init() {}
    
    
    /// The one instance of ``NotificationRegistry`` per lifecycle.
    static var global = NotificationRegistry()
    
    
    /// The app's current notification authorization status.
    var authorization: UNAuthorizationStatus { lookupAuthorization() }
    
    
    /// Boolean representation of whether this app can both receive and send out notifications.
    var isSetup: Bool {
        isPermittedToServeNotification
        && sender    != nil
    }
    
    
    /// The object that responds to notifications.
    var responder = NotificationResponder.global
    
    
    /// The object that sends out notifications.
    var sender: NotificationSender?
    
}


/// Handles the administration of delegate object for `UNUserNotificationCenter`.
extension NotificationRegistry {
    
    
    /// 
    func inaugurateNotificationCenterDelegation(candidate: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().delegate = candidate
    }
    
    
    /// 
    func impeachNotificationCenterDelegation() {
        UNUserNotificationCenter.current().delegate = nil
    }
    
}


/// Handles the administration of remote notification registration.
extension NotificationRegistry {
    
    
    /// Boolean representation of the app's current enrollment status for remote notifications.
    /// The value of `true` means this app's instance is enrolled for remote notifications, `false` otherwise.
    var isEnrolledForRemoteNotifications: Bool {
        UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    
    /// Enrolls this app's instance for remote notifications.
    /// 
    /// Upon successful operation, continuation is handled by ``AppDelegate/application(_:didRegisterForRemoteNotificationsWithDeviceToken:)``.\
    /// Upon failure, continuation is handled by ``AppDelegate/application(_:didFailToRegisterForRemoteNotificationsWithError:)``.
    func enrollForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    /// Unenrolls this app's instance for remote notifications.
    func unenrollForRemoteNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
}


/// Extension which handles authorization request for sending out notifications.
extension NotificationRegistry {
    
    
    /// Simplified boolean representation of whether this app is permitted to serve notifications.
    /// The value of `true` means notifications will be delivered (in realtime or in summary), `false` otherwise.
    var isPermittedToServeNotification: Bool {
        switch authorization {
            case .authorized, .provisional:
                return true
            case .denied, .ephemeral, .notDetermined:
                return false
            @unknown default:
                return false
        }
    }
    
    
    /// Prompts a system dialog that requests authorization for notification.
    /// 
    /// In case where request for permission has ever been denied before, no dialog will be shown.
    /// To counteract this, you can invoke ``openNotificationSettings()`` that opens this app's notification settings.
    func requestNotificationPermission(forOptions options: UNAuthorizationOptions, completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { isGranted, error in
            completion(isGranted, error)
        }
    }
    
    
    /// Opens the associated settings screen for this app's notification settings.
    func openNotificationSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
}


fileprivate extension NotificationRegistry {
    
    func lookupAuthorization() -> UNAuthorizationStatus {
        var status: UNAuthorizationStatus = .denied
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            status = settings.authorizationStatus
        }
        
        return status
    }
    
}
