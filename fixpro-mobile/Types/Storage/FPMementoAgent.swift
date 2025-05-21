import Foundation
import VinUtility



/// Type that triggers taking, saving, and restoring snapshots.
/// It binds an object to be observed with the storage of where snapshots of itself will be preserved.
final class FPMementoAgent<Target, TargetSnapshot> where Target: VUMementoSnapshotable, TargetSnapshot: VUMementoSnapshot {
    
    
    var storage: any FPTextStorageServicing
    var target: Target
    var targetStorageKey: String
    
    
    init(storage: any FPTextStorageServicing, target: Target, storageKey: String) {
        self.storage = storage
        self.target = target
        self.targetStorageKey = storageKey
    }
    
    
    @discardableResult func snap() async -> Result<TargetSnapshot, FPError> {
        switch await target.captureSnapshot() {
            case .success(let snapshot):
                let encoder = JSONEncoder()
                
                guard 
                    let snp = snapshot as? TargetSnapshot,
                    let stringSnapshot = try? encoder.encode(snp)
                else { 
                    return .failure(.TYPE_MISMATCH) 
                }
                
                do {
                    storage.remove(for: targetStorageKey)
                    _ = try storage.place(for: targetStorageKey, data: stringSnapshot.base64EncodedString()).get()
                } catch {
                    VULogger.log("Did fail to save snapshot: \(error)")
                }
                return .success(snp)
                
            case .failure(let error):
                VULogger.log("Did fail to snap: \(error)")
                return .failure(error as! FPError)
        }
    }

    
    func cold<BootableType>(restore type: BootableType.Type) async -> Result<BootableType, FPError> where BootableType: VUMementoSnapshotBootable {
        switch storage.retrieve(for: targetStorageKey, limit: 1) {
            case .success(let stringSnapshot):
                let decoder = JSONDecoder()
                
                guard let snp = try? decoder.decode(TargetSnapshot.self, from: Data(base64Encoded: stringSnapshot)!) else {
                    return .failure(.TYPE_MISMATCH)
                }
                
                return .success(type.boot(fromSnapshot: snp as! BootableType.BootSnapshotType) as! BootableType)

            case .failure(let error):
                return .failure(error)
        }
    }
    
}


func decode<ResultingType>(_ encodedSomething: Data, to resultingType: ResultingType.Type) -> Result<ResultingType, Error> where ResultingType: Decodable {
    let decoder = JSONDecoder()
    
    do {
        let decodedObject = try decoder.decode(resultingType.self, from: encodedSomething)
        return .success(decodedObject)
        
    } catch {
        return .failure(error)
        
    }
}
