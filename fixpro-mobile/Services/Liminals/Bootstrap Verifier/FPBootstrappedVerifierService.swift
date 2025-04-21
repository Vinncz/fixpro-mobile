import Foundation
import VinUtility



class FPBootstrapedVerifierService: FPBootstrappedVerifierServicing {
    
    
    var storage: any FPTextStorageServicing
    init(storage: any FPTextStorageServicing) {
        self.storage = storage
    }
    
    
    func verifyBootstrapped() -> Result<(sessionIdentity: FPSessionIdentityServiceSnapshot, networkingClient: FPNetworkingClientSnapshot), FPError> {
        do {
            let decoder = JSONDecoder()
            
            let savedSessionIdentitySnapshot = try storage.retrieve(for: .KEYCHAIN_KEY_FOR_FPSESSION_IDENTITY_MEMENTO_SNAPSHOT, limit: 1).get()
            guard let dataToDecode = Data(base64Encoded: savedSessionIdentitySnapshot) else {
                throw FPError.INVALID_ENTRY
            }
            
            let sessionIdentitySnapshot = try decoder.decode(FPSessionIdentityServiceSnapshot.self, from: dataToDecode)
            
            let savedNetworkingClientSnapshot = try storage.retrieve(for: .KEYCHAIN_KEY_FOR_NETWORKING_CLIENT_MEMENTO_SNAPSHOT, limit: 1).get()
            guard let dataToDecode = Data(base64Encoded: savedNetworkingClientSnapshot) else {
                throw FPError.INVALID_ENTRY
            }
            
            let networkingClientSnapshot = try decoder.decode(FPNetworkingClientSnapshot.self, from: dataToDecode)
            
            return .success((sessionIdentitySnapshot, networkingClientSnapshot))
            
        } catch let error as FPError {
            return .failure(error)
            
        } catch {
            VULogger.log(tag: .error, error)
            return .failure(.DECODE_FAILURE)
            
        }
    }
    
}
