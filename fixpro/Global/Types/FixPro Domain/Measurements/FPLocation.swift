import Foundation

struct FPLocation {
    var statedLocation: String
    var gpsLocation: FPLocationGPSLocation
}

struct FPLocationGPSLocation: Codable {
    var latitude: Double
    var longitude: Double
}

extension FPLocation: Codable {
    
    enum CodingKeys: String, CodingKey {
        case statedLocation = "stated_location"
        case gpsLocation = "gps_location"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statedLocation, forKey: .statedLocation)
        try container.encode(gpsLocation, forKey: .gpsLocation)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statedLocation = try container.decode(String.self, forKey: .statedLocation)
        self.gpsLocation = try container.decode(FPLocationGPSLocation.self, forKey: .gpsLocation)
    }
    
}
