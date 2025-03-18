import Foundation
import Security

protocol FabricatorQuerist {
    
    associatedtype Subject
    associatedtype ReturnValue
    
    /// Produces a keychain item for the given subject and data. You, as the caller, are responsible to call ``convertToExternalRepresentation(from:)`` to represent the object.
    func fabricate ( for subject: Subject, _ arguments: [String: Any]? ) 
        -> Result<ReturnValue, FPError> 
    
}
