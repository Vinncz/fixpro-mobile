import Foundation
import Observation



/// Bridges between ``ManageMembershipsSwiftUIView`` and the ``ManageMembershipsInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class ManageMembershipsSwiftUIViewModel {
    
    
    var applicants: [FPEntryApplication] = []
    
    
    var members: [FPPerson] = []
    
    
    var didRefresh: (()async->Void)?
    
    
    var didTapApplicant: ((FPEntryApplication)->Void)?
    
    
    var didTapMember: ((FPPerson)->Void)?
    
}
