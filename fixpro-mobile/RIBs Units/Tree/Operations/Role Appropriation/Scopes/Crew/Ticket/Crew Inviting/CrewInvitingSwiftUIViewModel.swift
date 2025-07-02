import Foundation
import Observation



/// Bridges between ``CrewInvitingSwiftUIView`` and the ``CrewInvitingInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class CrewInvitingSwiftUIViewModel {
    
    
    var ticket: FPTicketDetail
    
    
    init(ticket: FPTicketDetail, authContext: FPRoleContext) {
        self.ticket = ticket
        let filtered = ticket.issueTypes.filter { authContext.specialties.map({ $0.id }).contains($0.id) }
        self.crewInvitingDetails = filtered.map { issueType in
            CrewInvitingDetail(issueType: issueType, workDirective: "", personnel: [])
        }
    }
    
    
    var crewInvitingDetails: [CrewInvitingDetail]
    
    
    var availablePersonnel: [FPPerson] = []
    
    
    var supportiveDocuments: [URL] = []
    
    
    var didIntendToRefreshMemberList: (() async throws -> Void)?
    
    
    var didIntendToCancel: (() -> Void)?
    
    
    var didIntendToInvite: (() async throws -> Void)?
    
}



struct CrewInvitingDetail {
    
    
    var issueType: FPIssueType
    
    
    var workDirective: String
    
    
    var personnel: [FPPerson]
    
}
