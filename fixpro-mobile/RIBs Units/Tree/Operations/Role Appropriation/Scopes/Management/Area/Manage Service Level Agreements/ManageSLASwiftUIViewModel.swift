import Foundation
import Observation



/// Bridges between ``ManageSLASwiftUIView`` and the ``ManageSLAInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class ManageSLASwiftUIViewModel {
    
    
    var respondSLA: String = .EMPTY
    
    
    var autoCloseSLA: String = .EMPTY
    
    
    var issueTypes: [FPIssueType] = []
    
    
    var didSave: (()->Void)?
    
    
    var didRefresh: (()async->Void)?
    
}
