import Foundation

extension Result {
    
    /// Returns the success value, or the given default should the outcome is a failure.
    func get(or defaultValue: Success) -> Success {
        switch self {
            case .success(let value):
                return value
            case .failure:
                return defaultValue
        }
    }
    
}
