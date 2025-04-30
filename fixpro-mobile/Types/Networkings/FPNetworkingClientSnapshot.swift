import Foundation
import VinUtility



struct FPNetworkingClientSnapshot: VUMementoSnapshot {
    
    
    var id: UUID
    
    
    var tag: String?
    
    
    var takenOn: Date
    
    
    var version: String?
    
    
    var endpoint: URL
    
    
    init(id: UUID = UUID(), tag: String? = nil, takenOn: Date = .now, version: String? = nil, endpoint: URL) {
        self.id = id
        self.tag = tag
        self.takenOn = takenOn
        self.version = version
        self.endpoint = endpoint
    }
    
}
