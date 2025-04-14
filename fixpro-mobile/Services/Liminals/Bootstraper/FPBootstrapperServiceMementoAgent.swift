import Foundation
import VinUtility



class FPBootstrapperServiceMementoAgent: FPMementoAgent, VURemoverQuerist {
    
    init(storage: any FPTextStorageServicing, target: VUMementoSnapshotable) {
        super.init(storage: storage, target: target, storageKey: .KEYCHAIN_KEY_FOR_FPBOOTSTRAPPER_MEMENTO_SNAPSHOT)
    }
    
    @discardableResult func remove(for key: String = .KEYCHAIN_KEY_FOR_FPBOOTSTRAPPER_MEMENTO_SNAPSHOT) -> Result<Bool, FPError> {
        storage.remove(for: key)
    }

}
