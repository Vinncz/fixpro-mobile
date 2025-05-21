import Foundation
import SwiftData



@Model final class FPLightweightIssueTicket: Hashable, Identifiable, @unchecked Sendable {
    
    
    var id: String
    
    
    var issueTypes: [FPIssueType]
    
    
    var raisedOn: String
    
    
    var responseLevel: FPIssueTicketResponseLevel
    
    
    var status: FPIssueTicketStatus
    
    
    var executiveSummary: String?
    
    
    var closedOn: String?
    
    
    init(id: String, issueTypes: [FPIssueType], raisedOn: String, responseLevel: FPIssueTicketResponseLevel, status: FPIssueTicketStatus, executiveSummary: String?, closedOn: String? = nil) {
        self.id = id
        self.issueTypes = issueTypes
        self.raisedOn = raisedOn
        self.responseLevel = responseLevel
        self.status = status
        self.executiveSummary = executiveSummary
        self.closedOn = closedOn
    }
    
}
