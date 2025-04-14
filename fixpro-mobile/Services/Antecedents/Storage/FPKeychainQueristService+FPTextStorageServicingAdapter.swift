import Foundation
import VinUtility



class FPKeychainQueristServiceFPTextStorageServicingAdapter {
    
    
    var underlayingService: FPKeychainQueristService
    
    
    init(_ underlayingService: FPKeychainQueristService) {
        self.underlayingService = underlayingService
    }
    
}



extension FPKeychainQueristServiceFPTextStorageServicingAdapter: VUPlacerQuerist {
    
    
    @discardableResult func place(for subject: String, data: String) -> Result<Bool, FPError> {
        guard let datafiedString = data.data(using: .utf8) else { return .failure(.TYPE_MISMATCH) }
        return underlayingService.place(for: subject, data: datafiedString)
    }
    
}



extension FPKeychainQueristServiceFPTextStorageServicingAdapter: VURemoverQuerist {
    
    
    @discardableResult func remove(for subject: String) -> Result<Bool, FPError> {
        underlayingService.remove(for: subject)
    }
    
}



extension FPKeychainQueristServiceFPTextStorageServicingAdapter: VURetrieverQuerist {
    
    
    func retrieve(for subject: String, limit: Int) -> Result<String, FPError> {
        underlayingService.retrieve(for: subject)
    }
    
    
    func check(for subject: String) -> Result<Bool, FPError> {
        underlayingService.check(for: subject)
    }
    
}
