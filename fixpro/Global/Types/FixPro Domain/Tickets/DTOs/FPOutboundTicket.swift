import Foundation


struct FPOutboundTicket {
    
    
    /// Type of issue this ticket represents.
    var type: FPTicketType
    
    
    /// Degree of priority for this ticket.
    var responseLevel: FPResponseLevel
    
    
    /// Claimed statement of the issue represented by this ticket.
    var statedIssue: String
    
    
    /// Where the issue is reported to be.
    var location: FPLocation
    
    
    /// Documents that backs the claim made by this ticket.
    var supportiveDocuments: [FPOutboundResource]
    
}

extension FPOutboundTicket: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case issue_type
        case response_level
        case stated_issue
        case location
        case supportive_documents
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type.rawValue, forKey: .issue_type)
        try container.encode(responseLevel.rawValue, forKey: .response_level)
        try container.encode(statedIssue, forKey: .stated_issue)
        try container.encode(location, forKey: .location)
        try container.encode(supportiveDocuments, forKey: .supportive_documents)
    }
    
}
