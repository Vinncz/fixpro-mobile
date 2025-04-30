import Foundation
import SwiftData
import VinUtility



extension FPError {
    
    
    static func SWIFT_DATA_DID_FAIL_TO_SAVE(_ underlyingError: Error?) -> FPError {
        FPError(name: "SWIFT_DATA_DID_FAIL_TO_SAVE", 
                code: 0b1010_0101, 
                domain: .DataStorage, 
                userInfo: [
                    .UNDERLYING_ERROR: underlyingError as Any
                ])
    }
    
}


protocol SwiftDataQueristServicing: AnyObject {
    
    
    associatedtype Entity: PersistentModel & Identifiable
    
    
    func merge(entities: [Entity], preserveLeftovers: Bool, matchBy: (Entity, Entity) -> Bool) async -> Result<Void, FPError>
    
}



@MainActor
final class SwiftDataQueristService<Entity: PersistentModel & Identifiable & VUMergable>: SwiftDataQueristServicing {
    
    
    private let context: ModelContext
    
    
    init(context: ModelContext) {
        self.context = context
    }
    
    
    func merge(entities: [Entity], preserveLeftovers: Bool = true, matchBy: (Entity, Entity) -> Bool) async -> Result<Void, FPError> {
        do {
            let local = try context.fetch(FetchDescriptor<Entity>())
            var table = Dictionary(uniqueKeysWithValues: local.map { ($0.id, $0) })
            
            for remote in entities {
                if let local = table[remote.id] {
                    local.merge(with: remote)
                    table.removeValue(forKey: remote.id)
                    
                } else {
                    context.insert(remote)
                    
                }
            }
            
            if !preserveLeftovers {
                for (_, leftoverLocals) in table {
                    context.delete(leftoverLocals)
                }
            }
            
            return await save()
            
        } catch {
            return .failure(.SWIFT_DATA_DID_FAIL_TO_SAVE(error))
            
        }
    }
    
    
    private func save() async -> Result<Void, FPError> {
        do { try context.save() } 
        catch { return .failure(.SWIFT_DATA_DID_FAIL_TO_SAVE(error)) }
        
        return .success(())
    }
    
}
