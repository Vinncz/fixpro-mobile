import Foundation



struct FPLightweightIssueTicketDTO: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var issueType: FPIssueType
    
    
    var raisedOn: Date
    
    
    var responseLevel: FPIssueTicketResponseLevel
    
    
    var status: FPIssueTicketStatus
    
    
    var executiveSummary: String?
    
    
    var closedOn: Date?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "ticket_id"
        case issueType = "issue_type"
        case responseLevel = "response_level"
        case status
        case raisedOn = "raised_on"
        case executiveSummary = "executive_summary"
        case closedOn = "closed_on"
    }
    
    
    func toDomainModel() -> FPLightweightIssueTicket {
        .init(id: self.id, 
              issueType: self.issueType, 
              raisedOn: self.raisedOn, 
              responseLevel: self.responseLevel, 
              status: self.status, 
              executiveSummary: self.executiveSummary, 
              closedOn: self.closedOn)
    }
    
}
