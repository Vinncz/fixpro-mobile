import Foundation
import Observation



/// Bridges between ``InboxSwiftUIView`` and the ``InboxInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class InboxSwiftUIViewModel {
    
    
    var notifications: [FPNotificationDigest] = []
    
    
    var didIntendToRefreshMailbox: (() async -> Void)?
    
    
    var didTapNotification: ((FPNotificationDigest) -> Void)?
    
}
