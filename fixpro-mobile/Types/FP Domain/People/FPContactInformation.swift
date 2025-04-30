import Foundation



struct FPContactInformation: Codable, Hashable, Identifiable {
    
    
    var id: String { name }
    
    
    var name: String
    
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    
    var additionalInformation: [String: String] = [:]
    
}
