import SwiftUI



struct FPIssueType: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var name: String
    
    
    var serviceLevelAgreementDurationHour: String
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case serviceLevelAgreementDurationHour = "service_level_agreement_duration_hour"
    }
    
    
    static let unselected = FPIssueType(id: "Select--", name: "Select", serviceLevelAgreementDurationHour: "-1")
    
}
