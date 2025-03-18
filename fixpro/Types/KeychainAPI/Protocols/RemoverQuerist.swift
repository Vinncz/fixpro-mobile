import Foundation
import Security

protocol RemoverQuerist {
    
    associatedtype Subject
    associatedtype RV
    associatedtype E: Error
    
    /// Removes the keychain entry for the given subject.
    func remove ( for subject: Subject ) 
        -> Result<RV, E>
    
}
