import Foundation



struct FPSupportiveDocument: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var filename: String
    
    
    var mimetype: String
    
    
    var filesize: Double
    
    
    var hostedOn: URL
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case filename = "resource_name"
        case mimetype = "resource_type"
        case filesize = "resource_size"
        case hostedOn = "previewable_on"
    }
    
}
