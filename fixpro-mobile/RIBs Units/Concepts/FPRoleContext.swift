import Foundation



struct FPRoleContext {
    
    
    /// 
    let role: FPTokenRole
    
    
    /// 
    let capabilities: Set<FPCapability>
    
    
    /// 
    let specialties: Set<FPIssueType>
    
    
    /// 
    let featureFlags: Set<FPFeatureFlag>
    
    
    /// 
    let environment: FPAppEnvironment
    
    
    
    init(role: FPTokenRole, capabilities: Set<FPCapability>, specialties: Set<FPIssueType>, featureFlags: Set<FPFeatureFlag>, environment: FPAppEnvironment) {
        self.role = role
        self.capabilities = capabilities
        self.specialties = specialties
        self.featureFlags = featureFlags
        self.environment = environment
    }
    
}



extension FPRoleContext {
    
    
    init(role: FPTokenRole, capabilities: [FPCapability], specialties: [FPIssueType]) {
        self.role = role
        
        switch role {
        case .member:
            self.capabilities = Set(capabilities)
            self.specialties = Set(specialties)
            self.featureFlags = []
            self.environment = AppConfig.environment
            
        case .crew:
            self.capabilities = Set(capabilities)
            self.specialties = Set(specialties)
            self.featureFlags = []
            self.environment = AppConfig.environment
            
        case .management:
            self.capabilities = Set(capabilities)
            self.specialties = Set(specialties)
            self.featureFlags = []
            self.environment = AppConfig.environment
            
        }
    }
    
}



enum FPRolePermission: Hashable {
    case closeTicket
    case raiseTicket
    case readTicket
}



enum FPFeatureFlag: Hashable {
    
}



enum FPAppEnvironment {
    
    
    /// 
    case production
    
    
    /// 
    case staging
    
    
    /// 
    case sandbox(String)
    
    
    /// 
    case preview
    
}
