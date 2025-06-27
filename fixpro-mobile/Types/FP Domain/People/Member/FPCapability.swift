import Foundation



enum FPCapability: String, Codable, Equatable, Hashable, Identifiable, Sendable {
    
    
    case InvitePeopleToTicket
    
    
    case IssueSupervisorApproval
    
    
    var id: Self { self }
    
}
