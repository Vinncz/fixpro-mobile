import Foundation

protocol RemoverQuerist<Subject, RemoverReturnValue, Err> {
    
    associatedtype Subject
    associatedtype RemoverReturnValue
    associatedtype Err: Error
    
    /// Removes the entry for the given subject.
    func remove(for subject: Subject) 
        -> Result<RemoverReturnValue, Err>
    
}
