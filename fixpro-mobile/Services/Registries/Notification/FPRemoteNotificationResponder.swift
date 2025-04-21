import FirebaseMessaging
import Foundation
import UserNotifications
import VinUtility



/// Assesses and manages remote notifications.
final class FPRemoteNotificationResponder: NSObject, FPRemoteNotificationResponding {
    
    
    /// The notification pending to be linked to.
    private var queuedNotification: FPNotificationDigest?
    
    
    /// The router that enables deep-linking to work.
    var rootInteractor: RootInteractable? {
        didSet {
            if let queuedNotification {
                didTap(notification: queuedNotification)
            }
        }
    }
    
    
    /// The client 
    var networkingClient: FPNetworkingClient?
    
    
    /// Transforms abritrary dictionaries taken from userInfo off of a `UNNotification`, to a processed ``FPNotificationDigest``.
    func handle(remoteNotification payload: [AnyHashable: Any]) -> Result<FPNotificationDigest, FPError> {
        VULogger.log("Handling remote notification payload: \(payload)")
        
        if let aps = payload["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let title = alert["title"] as? String,
           let body = alert["body"] as? String
        {
            guard let actionableGenusString = payload["actionable_genus"] as? String,
                  let actionableSpeciesString = payload["actionable_species"] as? String,
                  let actionableGenus = FPRemoteNotificationActionable.Genus(rawValue: actionableGenusString),
                  let actionableSpecies = FPRemoteNotificationActionable.Species(rawValue: actionableSpeciesString)
            else {
                return .failure(.DECODE_FAILURE)
            }
            
            let actionableSegueDestination = payload["actionable_destination"] as? String
            let treatedObject = FPNotificationDigest.init(
                title: title,
                body: body,
                actionable: .init(genus: actionableGenus, 
                                  species: actionableSpecies, 
                                  destination: actionableSegueDestination)
            )
            
            VULogger.log("Success handling \(treatedObject)")
            return .success(treatedObject)
        }
        
        return .failure(.DECODE_FAILURE)
    }
    
    
    /// 
    func didTap(notification: FPNotificationDigest) {
        if let rootInteractor {
            rootInteractor.deeplink(notification: notification)
            queuedNotification = nil
            
            return
        }
        
        queuedNotification = notification
    }
    
}



extension FPRemoteNotificationResponder {
    
    
    /// Handles what happens when a notification is tapped on.
    /// 
    /// Use this method to optionally deeplink the given notification 
    /// with a screen from your view hierarchy.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationPayload = response.notification.request.content.userInfo
        
        switch handle(remoteNotification: notificationPayload) {
            case .success(let remoteNotification):
                didTap(notification: remoteNotification)
                
            case .failure(let error):
                VULogger.log(tag: .error, "Did fail to handle notification: \(error)")
        }
        
        completionHandler()
    }


    /// Decides whether to show the given notification (as an alert) or to suppress it.
    /// 
    /// Use this method to determine the degree of importance of the given notification,
    /// then return the appropriate level of presentation based on your assessment.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        VULogger.log(notification.request.content.userInfo)
        
        // TODO: More comprehensive determination function
        completionHandler([.banner, .badge, .sound])
    }
    
}



extension FPRemoteNotificationResponder {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        VULogger.log("didReceiveRegistrationToken: \(fcmToken ?? "")")
    }
    
}



extension FPRemoteNotificationResponder {
    
    func setRootInteractor(_ interactor: RootInteractable) {
        self.rootInteractor = interactor
    }
    
}



struct FPNotificationDigest {
    
    
    /// Title of the shown notification.
    var title: String
    
    
    /// Body of the shown notification.
    var body: String
    
    
    /// Object that helps in deep-linking a notification to a screen.
    var actionable: FPRemoteNotificationActionable
    
}



struct FPRemoteNotificationActionable {
    
    
    enum Genus: String {
        case SEGUE
        case CONTENT_AVAILABLE
        case INERT
    }
    
    
    enum Species: String {
        case TICKET_LOG
        case TICKET
        case INERT
    }
    
    
    /// 
    var genus: Genus
    
    
    /// 
    var species: Species
    
    
    /// 
    var destination: String?
    
}
