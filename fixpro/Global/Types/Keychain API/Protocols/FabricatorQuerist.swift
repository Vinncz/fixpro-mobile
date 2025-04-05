import Foundation

protocol FabricatorQuerist<Subject, FabricatorReturnValue, Err> {
    
    associatedtype Subject
    associatedtype FabricatorReturnValue
    associatedtype Err: Error
    
    /// Produces an instance of something and inserts them keyed by the given subject. 
    func fabricate(for subject: Subject, _ arguments: [String: Any]?) 
        -> Result<FabricatorReturnValue, Err> 
    
}
