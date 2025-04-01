import Foundation

extension FPError {    
    
    static let NO_NETWORK = FPError(
        code: 0b1000_0000,
        domain: .NetworkDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    /// 
    static let UNAUTHENTICATED = FPError(
        code: 1341, 
        domain: .NetworkDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let FORBIDDEN = FPError(
        code: 1342, 
        domain: .NetworkDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
}
