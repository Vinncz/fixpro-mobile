import Foundation
import Security

protocol PlacerQuerist {
    
    associatedtype Subject
    
    /// Places the given data into the keychain for the given subject.
    func place ( for subject: Subject, data: Data ) 
        -> Result<Bool, FPError> 
    
}
