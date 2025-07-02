import Foundation
import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `RoleAppropriationRIB` does not require any dependencies from its parent scope.
protocol RoleAppropriationDependency: Dependency {
    var keychainStorageServicing: any FPTextStorageServicing { get }
    
    var locationBeacon: VULocationBeacon { get }
    var networkingClient: FPNetworkingClient { get }
    
    var sessionIdentityService: FPSessionIdentityServicing { get }
    var sessionIdentityServiceMementoAgent: FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot> { get }
    var sessionidentityServiceUpkeeper: FPSessionIdentityUpkeeping { get }
}



/// Concrete implementation of the ``RoleAppropriationDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``RoleAppropriationRouter``.
final class RoleAppropriationComponent: Component<RoleAppropriationDependency> {
    
    
    var authorizationContextProxy: any VUProxy<FPRoleContext> {
        shared { VUProxyObject() }
    }
    
    
    var keychainStorageServicing: any FPTextStorageServicing { 
        dependency.keychainStorageServicing 
    }
    
    
    var locationBeacon: VULocationBeacon {
        dependency.locationBeacon
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
    
    var sessionIdentityService: FPSessionIdentityServicing {
        dependency.sessionIdentityService
    }
    
    
    var sessionIdentityServiceMementoAgent: FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot> {
        dependency.sessionIdentityServiceMementoAgent
    }
    
    
    var sessionidentityServiceUpkeeper: FPSessionIdentityUpkeeping {
        dependency.sessionidentityServiceUpkeeper
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension RoleAppropriationComponent: MemberRoleScopingDependency, CrewRoleScopingDependency, ManagementRoleScopingDependency {
    
    
    var authorizationContext: FPRoleContext {
        authorizationContextProxy.backing!
    }
    
    
    var identityService: FPSessionIdentityServicing {
        dependency.sessionIdentityService
    }
    
}



/// Contract adhered to by ``RoleAppropriationBuilder``, listing necessary actions to
/// construct a functional `RoleAppropriationRIB`.
protocol RoleAppropriationBuildable: Buildable {
    
    
    /// Constructs the `RoleAppropriationRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: RoleAppropriationListener, triggerNotification: FPNotificationDigest?) -> RoleAppropriationRouting
    
}



/// The composer of `RoleAppropriationRIB`.
final class RoleAppropriationBuilder: Builder<RoleAppropriationDependency>, RoleAppropriationBuildable {
    
    
    /// Creates an instance of ``RoleAppropriationBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: RoleAppropriationDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `RoleAppropriationRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: RoleAppropriationListener, triggerNotification: FPNotificationDigest?) -> RoleAppropriationRouting {
        let viewController = RoleAppropriationViewController()
        let component = RoleAppropriationComponent(dependency: dependency)
        let interactor = RoleAppropriationInteractor(component: component, presenter: viewController, triggerNotification: triggerNotification)
        
        interactor.listener = listener
        
        return RoleAppropriationRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
