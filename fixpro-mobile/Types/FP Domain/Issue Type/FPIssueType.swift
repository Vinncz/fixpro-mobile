import SwiftUI



enum FPIssueType: String, CaseIterable, Codable, Hashable, Identifiable {
    
    
    case select = "Select--"
    
    
    case engineering = "Engineering"
    
    
    case facility = "Facility"
    
    
    case housekeeping = "Housekeeping"
    
    
    case plumbing = "Plumbing"
    
    
    case security = "Security"
    
    
    case social = "Social"
    
    
    var id: Self { self }
    
    
    var color: Color {
        switch self {
            case .select:       return .clear
            case .engineering:  return .orange
            case .facility:     return .pink
            case .housekeeping: return .gray
            case .plumbing:     return .blue
            case .security:     return .indigo
            case .social:       return .green
        }
    }
    
    
    var icon: String {
        switch self {
            case .select:       return "hand"
            case .engineering:  return "wrench.and.screwdriver.fill"
            case .facility:     return "circle.hexagonpath"
            case .housekeeping: return "bubbles.and.sparkles.fill"
            case .plumbing:     return "spigot.fill"
            case .security:     return "shield.lefthalf.filled"
            case .social:       return "person.3.fill"
        }
    }
    
}
