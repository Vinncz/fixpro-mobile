import Foundation
import Observation



/// Bridges between ``ApplicantDetailSwiftUIView`` and the ``ApplicantDetailInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class ApplicantDetailSwiftUIViewModel {
    
    
    var applicant: FPEntryApplication
    
    
    var specialties: [FPIssueType] = []
    
    
    var didIntendToApprove: Bool = false
    
    
    var didIntendToReject: Bool = false
    
    
    var didApprove: ((FPTokenRole, String, [FPIssueType], [FPCapability])->Void)?
    
    
    var didReject: (()->Void)?
    
    
    init(applicant: FPEntryApplication) {
        self.applicant = applicant
    }
    
}
