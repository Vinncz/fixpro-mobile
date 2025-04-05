import Foundation

extension FPError {    
    
    
    /// 
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
    static let UNREACHABLE = FPError(
        code: 0b1000_0001,
        domain: .NetworkDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let TIMEOUT = FPError(
        code: 0b1000_0010,
        domain: .NetworkDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let UNEXPECTED_RESPONSE = FPError(
        code: 0b1000_0011,
        domain: .NetworkDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let SERVER_ERROR = FPError(
        code: 0b1000_0100,
        domain: .NetworkDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let UNAUTHENTICATED = FPError(
        code: 0b1000_0101, 
        domain: .NetworkDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let FORBIDDEN = FPError(
        code: 0b1000_0110, 
        domain: .NetworkDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let NOT_FOUND = FPError(
        code: 0b1000_0111, 
        domain: .NetworkDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    ///
    static let INVALID_ADDRESS = FPError(
        code: 0b1000_1000, 
        domain: .NetworkDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
    
    /// 
    static let BAD_REQUEST = FPError(
        code: 0b1000_1001, 
        domain: .NetworkDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("", comment: "")
        ]
    )
    
}
