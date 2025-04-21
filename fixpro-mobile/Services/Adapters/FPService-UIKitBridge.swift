import Combine
import Foundation
import VinUtility



/// Bridges between the independent lifecycle of RIBs and UIKit so they can coordinate.
final class FPRIBService_UIKitBridge {
    
    
    /// One instance per lifecycle.
    static var global = FPRIBService_UIKitBridge()
    
    
    /// Constituently a singleton.
    private init() {}
    
    
    /// Object that responds to remote notifications; i.e. manages what happens when notification is received, tapped upon, etc.
    var notificationResponder: FPRemoteNotificationResponding = FPRemoteNotificationResponder()
    
    
    /// 
    var apnTokenAwaiter: any VUAwaiter<Data> = VUAwaiterObject()
    
}
