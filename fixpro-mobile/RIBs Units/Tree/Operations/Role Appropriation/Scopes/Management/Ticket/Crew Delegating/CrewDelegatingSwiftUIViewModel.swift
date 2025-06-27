import Foundation
import Observation



/// Bridges between ``CrewDelegatingSwiftUIView`` and the ``CrewDelegatingInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class CrewDelegatingSwiftUIViewModel {
    
    
    var ticket: FPTicketDetail
    
    
    var crewDelegatingDetails: [CrewDelegatingDetail]
    
    
    var availablePersonnel: [FPPerson] = []
    
    
    var supportiveDocuments: [URL] = []
    
    
    var didIntendToRefreshMemberList: (() async throws -> Void)?
    
    
    var didIntendToCancel: (() -> Void)?
    
    
    var didIntendToDelegate: (() async throws -> Void)?
    
    
    init(ticket: FPTicketDetail) {
        self.ticket = ticket
        self.crewDelegatingDetails = ticket.issueTypes.map { issueType in
            CrewDelegatingDetail(issueType: issueType, workDirective: "", personnel: [])
        }
    }
    
}



struct CrewDelegatingDetail {
    
    
    var issueType: FPIssueType
    
    
    var workDirective: String
    
    
    var personnel: [FPPerson]
    
}
