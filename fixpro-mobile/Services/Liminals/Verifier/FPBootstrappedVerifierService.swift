import Foundation
import VinUtility



class FPBootstrapedVerifierService: FPBootstrappedVerifierServicing {
    
    
    var storage: any FPTextStorageServicing
    init(storage: any FPTextStorageServicing) {
        self.storage = storage
    }
    
    
    func verifyBootstrapped() -> Result<(endpoint: URL, refreshToken: String), FPError> {
        do {
            let decoder = JSONDecoder()
            
            let savedSnapshot = try storage.retrieve(for: .KEYCHAIN_KEY_FOR_FPSESSION_IDENTITY_MEMENTO_SNAPSHOT, limit: 1).get()
            guard let dataToDecode = Data(base64Encoded: savedSnapshot) else {
                throw FPError.INVALID_ENTRY
            }
            
            let snapshot = try decoder.decode(FPSessionIdentityServiceSnapshot.self, from: dataToDecode)
            
            return .success((snapshot.endpoint, snapshot.refreshToken))
            
        } catch let error as FPError {
            return .failure(error)
            
        } catch {
            VULogger.log(tag: .error, error)
            return .failure(.DECODE_FAILURE)
            
        }
    }
    
}
