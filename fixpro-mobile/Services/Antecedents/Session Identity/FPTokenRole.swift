import Foundation



/// Three large demographic groups that FixPro accomodates.
enum FPTokenRole: String, Codable {
    
    
    /// What most users are. Empowers them to do most basic things.
    case Member
    
    
    /// Users that uses FixPro to document and fulfill their work obligations.
    case Crew
    
    
    /// Users that manages Tickets, coordinates ``Crew``, and their Area.
    case Management
    
}
