import Foundation

protocol PlacerQuerist<Subject, PlacerInputValue, PlacerReturnValue, Err> {
    
    associatedtype Subject
    associatedtype PlacerInputValue
    associatedtype PlacerReturnValue
    associatedtype Err: Error
    
    /// Places the given data, keyed by the given subject.
    func place(for subject: Subject, data: PlacerInputValue) 
        -> Result<PlacerReturnValue, Err> 
    
}
