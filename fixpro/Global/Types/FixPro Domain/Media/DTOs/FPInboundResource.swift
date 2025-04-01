import Foundation


/// FixPro Backend's comprehension of a resource.
struct FPInboundResource: Decodable {
    
    
    /// The server's identifier of this resource.
    var id: String
    
    
    /// Mime type of this resource.
    var type: String
    
    
    /// Name of the resource.
    var name: String
    
    
    /// Size of the resource in bytes.
    var size: String?
    
    
    /// URL that points to where the resource is hosted on.
    var previewableOn: URL?
    
}
