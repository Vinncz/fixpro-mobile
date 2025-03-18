import Foundation
import Security

protocol RetrieverQuerist {
    
    associatedtype Subject
    associatedtype ReturnValue
    
    /// Performs a lookup to test the presence of a key for a given subject.
    func check ( for subject: Subject ) 
        -> Result<Bool, FPError> 
    
    /// Performs a lookup and retrieve the data associated with a given subject.
    func retrieve ( for subject: Subject, limit: Int ) 
        -> Result<ReturnValue, FPError> 
    
}
