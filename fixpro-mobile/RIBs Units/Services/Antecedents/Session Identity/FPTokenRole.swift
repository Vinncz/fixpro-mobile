import Foundation



/// Three large demographic groups that FixPro accomodates.
enum FPTokenRole: String, CaseIterable, Codable, Hashable, Identifiable {
    
    
    /// What most users are. Empowers them to do most basic things.
    case member = "Member"
    
    
    /// Users that uses FixPro to document and fulfill their work obligations.
    case crew = "Crew"
    
    
    /// Users that manages Tickets, coordinates ``crew``, and their Area.
    case management = "Management"
    
    
    var id: Self { self }
    
}
