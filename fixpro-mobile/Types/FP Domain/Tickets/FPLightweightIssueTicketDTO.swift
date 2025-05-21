import Foundation



struct FPLightweightIssueTicketDTO: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var issueTypes: [FPIssueType]
    
    
    var raisedOn: String
    
    
    var responseLevel: FPIssueTicketResponseLevel
    
    
    var status: FPIssueTicketStatus
    
    
    var executiveSummary: String?
    
    
    var closedOn: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case issueTypes = "issue_types"
        case responseLevel = "response_level"
        case status
        case raisedOn = "raised_on"
        case executiveSummary = "executive_summary"
        case closedOn = "closed_on"
    }
    
    
    func toDomainModel() -> FPLightweightIssueTicket {
        .init(id: self.id, 
              issueTypes: self.issueTypes, 
              raisedOn: self.raisedOn, 
              responseLevel: self.responseLevel, 
              status: self.status, 
              executiveSummary: self.executiveSummary, 
              closedOn: self.closedOn)
    }
    
}
