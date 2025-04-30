import Foundation
import SwiftData



@Model final class FPLightweightIssueTicket: Hashable, Identifiable, @unchecked Sendable {
    
    
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
    
    
    init(id: String, issueType: FPIssueType, raisedOn: Date, responseLevel: FPIssueTicketResponseLevel, status: FPIssueTicketStatus, executiveSummary: String?, closedOn: Date? = nil) {
        self.id = id
        self.issueType = issueType
        self.raisedOn = raisedOn
        self.responseLevel = responseLevel
        self.status = status
        self.executiveSummary = executiveSummary
        self.closedOn = closedOn
    }
    
}
