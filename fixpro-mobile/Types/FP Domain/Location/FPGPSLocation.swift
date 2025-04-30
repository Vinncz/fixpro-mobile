import Foundation



struct FPGPSLocation: Codable, Hashable, Identifiable {
    
    
    var latitude: Double
    
    
    var longitude: Double
    
    
    var id: String { "\(latitude + longitude)" }
    
}
