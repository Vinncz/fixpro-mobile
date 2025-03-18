import Foundation

enum FPError: Int, Error {
    
    
//  MARK: -- AUTH
    
    /// 
    case FORBIDDEN = 1
    
    /// 
    case UNAUTHENTICATED = 2
    
    
    
//  MARK: -- CAPTURE DEVICE
    
    /// Represents an error in accessing the camera.
    /// 
    /// Might be thrown when one of the following occurs:
    /// - The camera is not available or in use.
    /// - Device has no camera.
    case NO_CAMERA
    
    /// Represents an error in accessing the microphone.
    /// 
    /// Might be thrown when one of the following occurs:
    /// - The microphone is not available or in use.
    /// - Device has no microphone.
    case NO_MICROPHONE
    
    /// Represents an error in the camera permission process.
    /// 
    /// Might be thrown when one of the following occurs:
    /// - The user has denied the permission.
    /// - The user has disabled the permission.
    /// - The user has yet to grant permission.
    case NO_PERMISSION_CAMERA
    
    /// Represents an error in the microphone permission process.
    /// 
    /// Might be thrown when one of the following occurs:
    /// - The user has denied the permission.
    /// - The user has disabled the permission.
    /// - The user has yet to grant permission.
    case NO_PERMISSION_MICROPHONE
    
    
    
//  MARK: -- ENCODING
    
    /// Represents an error in the encoding process.
    /// 
    /// Might be thrown when one of the following occurs:
    /// - Some encoding key are missing.
    /// - Value has incorrect type.
    case MALFORMED
    
    
    
//  MARK: -- NETWORK & WEB
    
    /// 
    case NETWORK_UNAVAILABLE
    
    
    
//  MARK: -- VALIDATION
    
    /// 
    case EMPTY_ARGUMENT
    
    /// 
    case ILLEGAL_ARGUMENT
    
    
    
//  MARK: -- DATA STORAGE
    
    /// 
    case DUPLICATE
    
    /// 
    case MISSING
    
    
    
//  MARK: -- MISCL.
    
    /// 
    case OP_FAIL
    
}
