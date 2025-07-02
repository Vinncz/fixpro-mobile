import Foundation



enum FPAreaJoinPolicy: String, CaseIterable, Identifiable {
    
    
    case OPEN
    
    
    case APPROVAL_NEEDED = "APPROVAL-NEEDED"
    
    
    case CLOSED
    
    
    var id: Self { self }
    
}
