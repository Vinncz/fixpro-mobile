import Foundation
import VinUtility



/// Type that triggers taking, saving, and restoring snapshots.
class FPMementoAgent: VUMementoAgent {
    
    
    /// Datastore to be written and read.
    var storage: any FPTextStorageServicing
    var target: VUMementoSnapshotable?
    var storageKey: String
    
    
    /// Initializes an instace of ``FPMementoAgent``.
    init(storage: any FPTextStorageServicing, target: VUMementoSnapshotable?, storageKey: String) {
        self.target = target
        self.storage = storage
        self.storageKey = storageKey
    }
    
    
    /// Attempts to persists the current state of the object.
    @discardableResult func takeSnapshot(tag: String?) -> Result<any VUMementoSnapshot, FPError> {
        do {
            switch target?.captureSnapshot() {
                case .success(var snapshot):
                    snapshot.tag = tag
                    VULogger.log("Snapped \(snapshot)")
                    
                    let encoder = JSONEncoder()
                    let encodedValue = try encoder.encode(snapshot)
                    
                    switch storage.place(for: storageKey, data: encodedValue.base64EncodedString()) {
                        case .success:
                            return .success(snapshot)
                            
                        case .failure(let error):
                            VULogger.log(tag: .error, error)
                            return .failure(error)
                    }
                    
                case .failure(let error):
                    VULogger.log(tag: .error, error)
                    return .failure(error)
                    
                case .none:
                    return .failure(.UNLOADED_ENTRY)
            }
            
        } catch {
            VULogger.log(tag: .error, error)
            return .failure(.ENCODE_FAILURE)
            
        }
    }
    
    
    /// Attempts to restore the object to a previous state.
    func restore<T: VUMementoSnapshot>(to type: T.Type) -> Result<T, FPError> {
        do {
            switch storage.retrieve(for: storageKey, limit: 1) {
                case .success(let encodedValue):
                    
                    guard let encodedData = Data(base64Encoded: encodedValue) else {
                        throw FPError.INVALID_ENTRY
                    }
                    
                    let decoder = JSONDecoder()
                    let decodedValue = try decoder.decode(T.self, from: encodedData)
                    guard let typecastedValue = decodedValue as T? else {
                        throw FPError.TYPE_MISMATCH
                    }
                    
                    switch target?.restore(from: typecastedValue) {
                        case .success:
                            return .success(typecastedValue)
                        case .failure(let error):
                            VULogger.log(tag: .error, error)
                            return .failure(error)
                        case .none:
                            return .failure(.UNLOADED_ENTRY)
                    }
                    
                    
                case .failure(let error):
                    VULogger.log(tag: .error, error)
                    return .failure(error)
            }
            
        } catch {
            VULogger.log(tag: .error, error)
            return .failure(.DECODE_FAILURE)
            
        }
    }
    
}
