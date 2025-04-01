import Foundation

extension FPError {    
    
    
    /// 
    static let EMPTY_ARGUMENT = FPError(
        code: 2001,
        domain: .ValidationDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let ILLEGAL_ARGUMENT = FPError(
        code: 2001,
        domain: .ValidationDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
}
