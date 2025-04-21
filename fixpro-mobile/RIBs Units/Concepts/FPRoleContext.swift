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
