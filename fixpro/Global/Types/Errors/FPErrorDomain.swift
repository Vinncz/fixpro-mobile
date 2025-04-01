import Foundation

enum FPErrorDomain: UInt16 {
    
    case CaptureDeviceDomain = 0b0001

    case CodableDomain = 0b0010
    
    case CoreDataDomain = 0b0011
    
    case CoreLocationDomain = 0b0100
    
    case DataStorageDomain = 0b0101
    
    case FileManagerDomain = 0b0110
    
    case KeychainDomain = 0b0111
    
    case MiscellaneousDomain = 0b1000
    
    case NetworkDomain = 0b1001
    
    case SecurityDomain = 0b1010
    
    case UIKitDomain = 0b1011
    
    case UserDefaultsDomain = 0b1100
    
    case UserActivityDomain = 0b1101
    
    case ValidationDomain = 0b1110
    
    case WebKitDomain = 0b1111
    
}
