import Foundation

extension FPError {

    static let NO_SUITABLE_CAMERA = FPError(
        code: 0b1100_0010, 
        domain: .CaptureDeviceDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Device has no suitable camera.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("The device has no camera or any compatible camera is in use.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Check whether a camera is present, and make sure its not in use.", comment: "")
        ]
    )
    
    static let NO_SUITABLE_MICROPHONE = FPError(
        code: 0b1100_0001, 
        domain: .CaptureDeviceDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Device has no suitable microphone.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("The device has no microphone or any compatible microphone is in use.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Check whether a microphone is present, and make sure its not in use.", comment: "")
        ]
    )
    
    static let NO_PERMISSION_CAMERA = FPError(
        code: 0b1000_0010, 
        domain: .CaptureDeviceDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("No permission to access the camera.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("The user has denied the permission, disabled the permission, or has yet to grant permission.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Go to settings and enable the camera permission for the app.", comment: "")
        ]
    )
    
    static let NO_PERMISSION_MICROPHONE = FPError(
        code: 0b1000_0001, 
        domain: .CaptureDeviceDomain, 
        userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("No permission to access the microphone.", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("The user has denied the permission, disabled the permission, or has yet to grant permission.", comment: ""),
            NSRecoveryAttempterErrorKey: NSLocalizedString("Go to settings and enable the microphone permission for the app.", comment: "")
        ]
    )
    
}
