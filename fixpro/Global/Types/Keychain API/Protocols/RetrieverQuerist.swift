import Foundation

protocol RetrieverQuerist<Subject, RetrieverReturnValue, Err> {
    
    associatedtype Subject
    associatedtype RetrieverReturnValue
    associatedtype Err: Error
    
    /// Performs a lookup to test the presence of a key for a given subject.
    func check(for subject: Subject) 
        -> Result<Bool, Err> 
    
    /// Performs a lookup and retrieve the information associated with a given subject.
    func retrieve(for subject: Subject, limit: Int) 
        -> Result<RetrieverReturnValue, Err> 
    
}
