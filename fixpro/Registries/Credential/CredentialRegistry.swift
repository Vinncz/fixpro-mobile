import Foundation
import Security


class CredentialRegistry {
    
    
    /// Constituently a singleton
    private init() {}
    
    
    /// The one instance of ``CredentialRegistry`` per lifecycle.
    static let global = CredentialRegistry()
    
    
    /// 
    private(set) var apiKey: String?
    
    
    /// 
    private(set) var referralTrackingToken: String?
    
}


/// 
extension CredentialRegistry {
    
    
    /// Loads all important information, such as ``apiKey`` and ``referralTrackingToken``, into memory.
    func unlock() {
        switch FPKeychainQuerist.global.retrieve(for: .apiKey, limit: 1) {
            case .success(let apiKey):
                self.apiKey = apiKey
            case .failure(let error):
                break
        }
        switch FPKeychainQuerist.global.retrieve(for: .referralTrackingToken, limit: 1) {
            case .success(let referralTrackingToken):
                self.referralTrackingToken = referralTrackingToken
            case .failure(let error):
                break
        }
    }
    
    
    /// Unloads important information from memory.
    func lock() {
        apiKey = nil
        referralTrackingToken = nil
    }
    
}
