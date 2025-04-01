import Foundation

extension FPError {    
    
    static let DERIVATION_FAILURE = FPError(
        code: 1001,
        domain: .CodableDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    static let MALFORMED = FPError(
        code: 1001,
        domain: .CodableDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    static let TYPE_MISMATCH = FPError(
        code: 1001,
        domain: .CodableDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
}
