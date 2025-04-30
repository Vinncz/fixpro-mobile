import Foundation



enum FPAreaJoinPolicy: String, CaseIterable, Identifiable {
    
    
    case OPEN
    
    
    case APPROVAL_NEEDED
    
    
    case CLOSED
    
    
    init?(rawValue: String) {
        if rawValue == "OPEN" {
            self = .OPEN
        } else if rawValue == "APPROVAL-NEEDED" {
            self = .APPROVAL_NEEDED
        } else if rawValue == "CLOSED" {
            self = .CLOSED
        }
        
        return nil
    }
    
    
    var id: Self { self }
}
