import Foundation

class FPKeychainQueristServiceAdapterToFPTextStorageServicing {
    
    var underlayingKeychainService: FPKeychainQueristService
    
    init(_ underlayingKeychainService: FPKeychainQueristService) {
        self.underlayingKeychainService = underlayingKeychainService
    }
    
}

extension FPKeychainQueristServiceAdapterToFPTextStorageServicing: PlacerQuerist {
    
    func place(for subject: String, data: String) -> Result<Bool, FPError> {
        guard let datafiedString = data.data(using: .utf8) else { return .failure(.TYPE_MISMATCH) }
        return underlayingKeychainService.place(for: subject, data: datafiedString)
    }
    
}

extension FPKeychainQueristServiceAdapterToFPTextStorageServicing: RemoverQuerist {
    
    func remove(for subject: String) -> Result<Bool, FPError> {
        underlayingKeychainService.remove(for: subject)
    }
    
}

extension FPKeychainQueristServiceAdapterToFPTextStorageServicing: RetrieverQuerist {
    
    func retrieve(for subject: String, limit: Int) -> Result<String, FPError> {
        underlayingKeychainService.retrieve(for: subject)
    }
    
    func check(for subject: String) -> Result<Bool, FPError> {
        underlayingKeychainService.check(for: subject)
    }
    
}
