import Foundation
import Observation



/// Bridges between ``TicketDetailSwiftUIView`` and the ``TicketDetailInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class TicketDetailSwiftUIViewModel {
    
    
    var id: String?
    
    
    var issueTypes: [FPIssueType] = []
    
    
    var responseLevel: FPIssueTicketResponseLevel?
    
    
    var raisedOn: String?
    
    
    var status: FPIssueTicketStatus?
    
    
    var executiveSummary: String?
    
    
    var statedIssue: String?
    
    
    var location: FPLocation?
    
    
    var supportiveDocuments: [FPSupportiveDocument] = []
    
    
    var issuer: FPContactInformation?
    
    
    var logs: [FPTicketLog] = []
    
    
    var handlers: [FPPerson] = []
    
    
    var closedOn: String?
    
    
    init(role: FPTokenRole) {
        self.role = role
    }
    
    
    var rejectionReason: String = .EMPTY
    
    
    var role: FPTokenRole
    
    
    var didIntedToRefresh: (() async -> Void)?
    
    
    var didTapTicketLog: ((_ log: FPTicketLog)->Void)?
    
}
