import Foundation
import Observation



/// Bridges between ``IssueTypesRegistrarSwiftUIView`` and the ``IssueTypesRegistrarInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class IssueTypesRegistrarSwiftUIViewModel {
    
    
    var didRefresh: (()async throws->Void)?
    
    
    var shouldShowSuccessAlert: Bool = false
    
    
    var shouldShowFailureAlert: Bool = false
    
    
    var didIntendToAddIssueTypes: Bool = false
    
    
    var didMakeNewIssueType: ((String, String)->Void)?
    
    
    var didRemoveIssueType: ((FPIssueType)->Void)?
    
    
    var issueTypes: [FPIssueType] = []
    
}
