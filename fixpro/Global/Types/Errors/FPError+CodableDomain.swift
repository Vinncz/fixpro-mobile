import Foundation

extension FPError {    
    
    
    /// 
    static let DERIVATION_FAILURE = FPError(
        code: 0b0100_0000,
        domain: .CodableDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Unsuccessfully derived a value into some type.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("The value could not be derived into the type.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Check the value and the type you are trying to derive it into.", comment: "")
        ]
    )
    
    /// 
    static let MALFORMED = FPError(
        code: 0b0100_0001,
        domain: .CodableDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Keys which were expected or needed, were not found.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Some key-value pairings were not found.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Log the object you are trying to decode, and check the keys you are using.", comment: "")
        ]
    )
    
    /// 
    static let TYPE_MISMATCH = FPError(
        code: 0b0100_0010,
        domain: .CodableDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Type mismatch.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("The type of the value does not match the type of the key.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Check the type of the value and the type of the key.", comment: "")
        ]
    )
    
}
