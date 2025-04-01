import Foundation
import Security

protocol KeychainRemoverQuerist<Subject, RemoverReturnValue, Err> {
    
    associatedtype Subject
    associatedtype RemoverReturnValue
    associatedtype Err: Error
    
    /// Removes the keychain entry for the given subject.
    func remove ( for subject: Subject ) 
        -> Result<RemoverReturnValue, Err>
    
}
