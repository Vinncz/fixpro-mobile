import Foundation
import VinUtility



struct FPContactInformation: Codable, Hashable, Identifiable {
    
    
    var id: String { name }
    
    
    var name: String
    
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    
    init (name: String, extras: [String: String] = [:]) {
        self.name = name
        self.additionalInformation = extras
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
    }
    
    
    var additionalInformation: [String: String] = [:]
    
}
