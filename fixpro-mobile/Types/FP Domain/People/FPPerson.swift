import Foundation



struct FPPerson: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var name: String
    
    
    var role: FPTokenRole
    
    
    var speciality: [FPIssueType]
    
    
    var title: String?
    
    
    var memberSince: Date
    
    
    var memberUntil: Date?
    
    
    var moreInformation: [String: String] = [:]
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case speciality
        case title
        case memberSince = "member_since"
        case memberUntil = "member_until"
    }
    
}
