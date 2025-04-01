import Foundation
import Security

protocol KeychainFabricatorQuerist<Subject, FabricatorReturnValue, Err> {
    
    associatedtype Subject
    associatedtype FabricatorReturnValue
    associatedtype Err: Error
    
    /// Produces a keychain item for the given subject and data. You, as the caller, are responsible to call ``convertToExternalRepresentation(from:)`` to represent the object.
    func fabricate ( for subject: Subject, _ arguments: [String: Any]? ) 
        -> Result<FabricatorReturnValue, Err> 
    
}
