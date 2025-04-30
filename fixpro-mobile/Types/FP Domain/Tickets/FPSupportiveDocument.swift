import Foundation



struct FPSupportiveDocument: Codable, Hashable, Identifiable {
    
    
    var filename: String
    
    
    var hostedOn: URL
    
    
    enum CodingKeys: String, CodingKey {
        case filename = "resource_name"
        case hostedOn = "previewable_on"
    }
    
    
    var id: String { filename }
    
}
