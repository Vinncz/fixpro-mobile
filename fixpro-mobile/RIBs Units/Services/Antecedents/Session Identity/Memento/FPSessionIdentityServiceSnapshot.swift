import Foundation
import VinUtility



struct FPSessionIdentityServiceSnapshot: VUMementoSnapshot {
    
    
    var id = UUID()
    var tag: String?
    var takenOn: Date = .now
    var version: String?
    
    
    var accessToken: String
    var accessTokenExpirationDate: Date
    var refreshToken: String
    var refreshTokenExpirationDate: Date
    var role: FPTokenRole
    var capabilities: [FPCapability]
    var specialties: [FPIssueType]
    
    
    init(id: UUID = UUID(), 
         tag: String? = nil, 
         takenOn: Date = .now, 
         version: String? = nil, 
         accessToken: String, 
         accessTokenExpirationDate: Date, 
         refreshToken: String, 
         refreshTokenExpirationDate: Date,
         role: FPTokenRole,
         capabilities: [FPCapability],
         specialties: [FPIssueType]
    ) {
        self.id = id
        self.tag = tag
        self.takenOn = takenOn
        self.version = version
        self.accessToken = accessToken
        self.accessTokenExpirationDate = accessTokenExpirationDate
        self.refreshToken = refreshToken
        self.refreshTokenExpirationDate = refreshTokenExpirationDate
        self.role = role
        self.capabilities = capabilities
        self.specialties = specialties
    }
    
}
