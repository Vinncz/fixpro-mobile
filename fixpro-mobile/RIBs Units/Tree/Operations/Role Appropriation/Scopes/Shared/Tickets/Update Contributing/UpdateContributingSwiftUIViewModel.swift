import Foundation
import Observation



/// Bridges between ``UpdateContributingSwiftUIView`` and the ``UpdateContributingInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class UpdateContributingSwiftUIViewModel {
    
    
    var authorizationContext: FPRoleContext?
    
    
    var didIntendToCancel: (() -> Void)?
    
    
    var didIntendToSubmit: ((String, [URL], FPTicketLogType) -> Void)? 
    
}
