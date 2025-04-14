import Foundation
import VinUtility



protocol FPStorage<StorageFacade> {
    
    
    associatedtype StorageFacade
    
    var storage: StorageFacade { get }
    
}
