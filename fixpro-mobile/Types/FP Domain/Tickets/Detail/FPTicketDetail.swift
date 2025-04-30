import Foundation



struct FPTicketDetail: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var issueType: FPIssueType
    
    
    var responseLevel: FPIssueTicketResponseLevel
    
    
    var raisedOn: Date
    
    
    var status: FPIssueTicketStatus
    
    
    var executiveSummary: String?
    
    
    var statedIssue: String
    
    
    var location: FPLocation
    
    
    var supportiveDocuments: [FPSupportiveDocument]
    
    
    var issuer: FPContactInformation
    
    
    var logs: [FPTicketLog]
    
    
    var handlers: [FPContactInformation]
    
    
    var closedOn: Date?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "ticket_id"
        case issueType = "issue_type"
        case responseLevel = "response_level"
        case raisedOn = "raised_on"
        case status
        case executiveSummary = "executive_summary"
        case statedIssue = "stated_issue"
        case location
        case supportiveDocuments = "supportive_documents"
        case issuer
        case logs
        case handlers
        case closedOn = "closed_on"
    }
    
}
