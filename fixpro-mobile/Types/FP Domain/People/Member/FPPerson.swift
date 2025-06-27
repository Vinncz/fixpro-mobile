import Foundation



struct FPPerson: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var name: String
    
    
    var role: FPTokenRole
    
    
    var title: String?
    
    
    var specialties: [FPIssueType]
    
    
    var capabilities: [FPCapability]
    
    
    var memberSince: String
    
    
    var memberUntil: String?
    
    
    var extras: [String: String] = [:]
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case specialties
        case capabilities
        case title
        case memberSince = "member_since"
        case memberUntil = "member_until"
    }
    
}



extension FPPerson {
    
    
    var specialtiesName: String {
        specialties.map { $0.name }.coalesce()
    }
    
}
