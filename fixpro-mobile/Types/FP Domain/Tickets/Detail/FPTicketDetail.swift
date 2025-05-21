import Foundation
import VinUtility



struct FPTicketDetail: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var issueTypes: [FPIssueType]
    
    
    var responseLevel: FPIssueTicketResponseLevel
    
    
    var raisedOn: String
    
    
    var status: FPIssueTicketStatus
    
    
    var executiveSummary: String?
    
    
    var statedIssue: String
    
    
    var location: FPLocation
    
    
    var supportiveDocuments: [FPSupportiveDocument]
    
    
    var issuer: VUExtrasPreservingDecodable<FPPerson>
    
    
    var logs: [FPTicketLog]
    
    
    var handlers: [VUExtrasPreservingDecodable<FPPerson>]
    
    
    var closedOn: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case issueTypes = "issue_types"
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
    
    
    static func == (lhs: FPTicketDetail, rhs: FPTicketDetail) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
