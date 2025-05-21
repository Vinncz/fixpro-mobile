import Foundation
import Observation



/// Bridges between ``WorkEvaluatingSwiftUIView`` and the ``WorkEvaluatingInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class WorkEvaluatingSwiftUIViewModel {
    
    
    var validationMessage: String = .EMPTY
    
    
    var rejectionReason: String = .EMPTY {
        didSet {
            validationMessage = .EMPTY
        }
    }
    
    
    var workProgressLogs: [FPTicketLog] = []
    
    
    var didIntendToDismiss: (()->Void)?
    
    
    var didIntendToApprove: (()->Void)?
    
    
    var didIntendToReject: (()->Void)?
    
    
    func reset() {
        validationMessage = .EMPTY
        rejectionReason = .EMPTY
        workProgressLogs = []
    }
    
}
