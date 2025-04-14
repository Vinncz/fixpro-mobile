import Foundation
import VinUtility



struct FPBootstrapperServiceSnapshot: VUMementoSnapshot {
    
    
    var id = UUID()
    var tag: String?
    var takenOn: Date = .now
    var version: String?
    
    var areaName: String
    var applicationId: String
    var applicationSubmissionDate: Date
    var applicationIdExpiryDate: Date
    var endpoint: String
    
    
    init(id: UUID = UUID(), 
         tag: String? = nil, 
         takenOn: Date = .now, 
         version: String? = nil, 
         areaName: String,
         applicationId: String, 
         applicationSubmissionDate: Date, 
         applicationIdExpiryDate: Date,
         endpoint: String
    ) {
        self.id = id
        self.tag = tag
        self.takenOn = takenOn
        self.version = version
        self.areaName = areaName
        self.applicationId = applicationId
        self.applicationSubmissionDate = applicationSubmissionDate
        self.applicationIdExpiryDate = applicationIdExpiryDate
        self.endpoint = endpoint
    }
    
}
