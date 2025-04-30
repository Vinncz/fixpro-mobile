import Foundation
import SwiftUI



enum FPIssueTicketResponseLevel: String, CaseIterable, Codable, Hashable, Identifiable {
    
    
    case select = "Select--"
    
    
    case urgentEmergency = "Urgent Emergency"
    
    
    case urgent = "Urgent"
    
    
    case normal = "Normal"
    
    
    var id: Self { self }
    
    
    var color: Color {
        switch self {
            case .select:
                return .clear
            case .urgentEmergency:
                return .red.opacity(0.8)
            case .urgent:
                return .orange.opacity(0.9)
            case .normal:
                return .clear
        }
    }
    
    
    var shorthandRepresentation: String {
        switch self {
            case .select:
                return "Select--"
            case .urgentEmergency:
                return "Emergency"
            case .urgent:
                return "Urgent"
            case .normal:
                return "Normal"
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case select = "Select--"
        case urgentEmergency = "Urgent, emergency"
        case urgent = "Urgent"
        case normal = "Normal"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case CodingKeys.select.rawValue:
            self = .select
        case CodingKeys.urgentEmergency.rawValue:
            self = .urgentEmergency
        case CodingKeys.urgent.rawValue:
            self = .urgent
        case CodingKeys.normal.rawValue:
            self = .normal
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value for MyEnum: \(rawValue)")
        }
    }
    
}
