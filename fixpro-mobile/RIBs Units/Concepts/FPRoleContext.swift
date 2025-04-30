import Foundation



struct FPRoleContext {
    
    
    /// 
    let role: FPTokenRole
    
    
    /// 
    let permissions: Set<FPRolePermission>
    
    
    /// 
    let featureFlags: Set<FPFeatureFlag>
    
    
    /// 
    let environment: FPAppEnvironment
    
    
    init(role: FPTokenRole, permissions: Set<FPRolePermission>, featureFlags: Set<FPFeatureFlag>, environment: FPAppEnvironment) {
        self.role = role
        self.permissions = permissions
        self.featureFlags = featureFlags
        self.environment = environment
    }
    
}



extension FPRoleContext {
    
    
    init(role: FPTokenRole) {
        self.role = role
        
        switch role {
        case .member:
            self.permissions = []
            self.featureFlags = []
            self.environment = AppConfig.environment
            
        case .crew:
            self.permissions = []
            self.featureFlags = []
            self.environment = AppConfig.environment
            
        case .management:
            self.permissions = []
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
