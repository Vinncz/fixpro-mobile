import Foundation



struct FPLocation: Codable, Hashable, Identifiable {
    
    
    var id: Self { self }
    
    
    var reportedLocation: String
    
    
    var gpsCoordinates: FPGPSLocation
    
    
    enum CodingKeys: String, CodingKey {
        case reportedLocation = "stated_location"
        case gpsCoordinates = "gps_location"
    }
    
}
