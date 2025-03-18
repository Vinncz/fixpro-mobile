import Foundation
import Security

struct FPKeychainQuerist {
    
    
    /// Constituently a singleton.
    private init () {}
    
    
    /// The one instance of ``FPKeychainQuerist`` per lifecycle.
    static let global = FPKeychainQuerist()
    
    
    /// Available topic to query or to save into the keychain.
    enum Subject: String {
        case apiKey
        case referralTrackingToken
    }
    
}


extension FPKeychainQuerist: RetrieverQuerist {
    
    func check(for subject: Subject) -> Result<Bool, FPError> {
        FPLogger.log("Checking for \(subject.rawValue)")
        
        let query = SecureQuery()
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject.rawValue)
            .RW_RR_RD_applicationTag(subject.rawValue)
            .OR_returnData()
        
        var keyData: CFTypeRef?
        let status = SecItemCopyMatching(query.unwrapped(), &keyData)
        
        guard status == errSecSuccess else {
            FPLogger.log(tag: .error, SecCopyErrorMessageString(status, nil) as Any)
            return .failure(.MISSING)
        }
        
        return .success(true)
    }
    
    func retrieve(for subject: Subject, limit: Int) -> Result<String, FPError> {
        FPLogger.log("Retrieving for \(subject.rawValue)")
        
        let query = SecureQuery()
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject.rawValue)
            .OR_returnData()
        
        var keyData: CFTypeRef?
        let status = SecItemCopyMatching(query.unwrapped(), &keyData)
        
        guard status == errSecSuccess, let data = keyData as? Data, let val = String(data: data, encoding: .utf8) else {
            FPLogger.log(tag: .error, SecCopyErrorMessageString(status, nil) as Any)
            return .failure(.MISSING)
        }
        
        return .success(val)
    }
    
}


extension FPKeychainQuerist: PlacerQuerist {
    
    @discardableResult
    func place(for subject: Subject, data: Data) -> Result<Bool, FPError> {
        FPLogger.log("Placing for \(subject.rawValue)")
        
        let query = SecureQuery()
            .RW_IR_ID_valueData(data)
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject.rawValue)
            .write(kSecAttrAccessible, kSecAttrAccessibleWhenUnlocked)
        
        let status = SecItemAdd(query.unwrapped(), nil)
        switch status {
            case errSecSuccess:
                return .success(true)
            case errSecDuplicateItem:
                return .failure(.DUPLICATE)
            default:
                break
        }
        
        FPLogger.log(tag: .error, SecCopyErrorMessageString(status, nil) as Any)
        return .failure(.OP_FAIL)
    }
    
}


extension FPKeychainQuerist: RemoverQuerist {
    
    @discardableResult
    func remove(for subject: Subject) -> Result<Bool, FPError> {
        FPLogger.log("Removing for \(subject.rawValue)")
        
        let query = SecureQuery()
            .OW_OR_keyOwner(subject.rawValue)
            .RW_OR_keyClass(.genericPassword)
        
        let status = SecItemDelete(query.unwrapped())
        switch status {
            case errSecSuccess:
                return .success(true)
            default: 
                break
        }
        
        FPLogger.log(tag: .error, SecCopyErrorMessageString(status, nil) as Any)
        return .failure(.OP_FAIL)
    }
    
}
