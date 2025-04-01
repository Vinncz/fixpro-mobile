import Foundation
import Security

protocol KeychainPlacerQuerist<Subject, PlacerReturnValue, Err> {
    
    associatedtype Subject
    associatedtype PlacerReturnValue
    associatedtype Err: Error
    
    /// Places the given data into the keychain for the given subject.
    func place ( for subject: Subject, data: Data ) 
        -> Result<PlacerReturnValue, Err> 
    
}
