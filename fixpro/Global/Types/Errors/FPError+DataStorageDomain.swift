import Foundation

extension FPError {    
    
    static let DUPLICATE_ENTRY = FPError(
        code: 0b0001_0001,
        domain: .DataStorageDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Preexisting entry found. Stopped before overwriting.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Refused to overwrite an existing entry.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Check or delete the existing entry before writing a new one.", comment: "")
        ]
    )
    
    static let MISSING_ENTRY = FPError(
        code: 0b0001_0010,
        domain: .DataStorageDomain,
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("No entry found.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("The requested entry does not exist.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Check whether the identifier is correct, and you're looking in the right place.", comment: "")
        ]
    )
    
}
