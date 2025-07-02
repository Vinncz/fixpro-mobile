import Foundation



enum FPCapability: String, CaseIterable, Codable, Equatable, Hashable, Identifiable, Sendable {
    
    
    case InvitePeopleToTicket = "InvitePeopleToTicket"
    
    
    case IssueSupervisorApproval = "IssueSupervisorApproval"
    
    
    var id: Self { self }
    
    
    var displayName: String {
        switch self {
            case .InvitePeopleToTicket: return "Invite People to Ticket"
            case .IssueSupervisorApproval: return "Issue Supervisor Approval"
        }
    }
    
}
