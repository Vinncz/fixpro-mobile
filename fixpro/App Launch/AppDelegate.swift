import FirebaseCore
import FirebaseMessaging
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// An override point for customization after application launch.
    func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {
        return true
    }
    
}


/// Handles what happens when a remote notification is received.
extension AppDelegate {
    
    
    /// Invoked by the system to notify that a silent remote notification has arrived, and there are data to be fetched.
    /// 
    /// Use this method to determine whether the notification signals for any fetching of data.
    /// If applicable, perform the fetching operation--otherwise, invoke the completionHandler 
    /// with `.newData`, `.noData`, or `.failed` to inform the system of your resolve.
    func application(_ application: UIApplication, didReceiveRemoteNotification notificationPayload: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationResponder.global.respond(to: notificationPayload, fetchCompletionHandler: completionHandler)
    }
    
    
    /// Invoked by the system to notify that a non-silent remote notification has arrived while the app is in foreground (running).
    /// 
    /// This method doesn't cover silent notification
    func application(_ application: UIApplication, didReceiveRemoteNotification notificationPayload: [AnyHashable: Any]) {
        NotificationResponder.global.respond(to: notificationPayload)
    }
    
}


/// Handles the outcome of registering for remote notifications.
extension AppDelegate {
    
    
    /// Pairs Firebase's Messaging instance with the supplied Apple Push Notification (APN) token.
    /// 
    /// Upon sucessful invoke of `application.registerForRemoteNotification()`, this method is called to supply
    /// this application's instance with the pairing token.
    /// > Important: Refrain from invoking this method manually. Leave the system to solely call this method.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceAPNToken: Data) {
        FirebaseRegistry.global.configureAPNToken(deviceAPNToken)
    }
    
    
    /// Handles errors associated with invoking `application.registerForRemoteNotification()`.
    /// 
    /// This method is called to inform a given application instance about why it failed.
    /// > Important: Refrain from invoking this method manually. Leave the system to solely call this method.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        FPLogger.log(tag: .error, "Did fail to register for remote notifications due to", error)
    }
    
}


/// Handles the lifecycle of UISceneSession.
extension AppDelegate {
    
    
    /// Called when a new scene session is being created.
    /// Use this method to select a configuration to create the new scene with.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    
    /// Called when the user discards a scene session.
    /// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    /// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
}
