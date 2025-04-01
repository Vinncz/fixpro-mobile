import Foundation


/// 
struct FPOutboundResource {
    
    
    /// URL that points to the resource.
    var url: URL
    
    
    /// Mime type of the resource.
    var type: String { inferMimeType(for: self.url) }
    
    
    /// Name of the resource.
    var name: String { self.url.lastPathComponent }
    
    
    /// Size of the resource in bytes.
    var size: Int { (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0 }
    
}

extension FPOutboundResource: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case type
        case name
        case size
        case content
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(size, forKey: .size)
        
        let filedata = try Data(contentsOf: url)
        let encodedData = filedata.base64EncodedString()
        try container.encode(encodedData, forKey: .content)
    }
    
}
