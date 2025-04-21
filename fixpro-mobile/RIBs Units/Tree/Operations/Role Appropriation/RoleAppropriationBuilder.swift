import Foundation
import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `RoleAppropriationRIB` does not require any dependencies from its parent scope.
protocol RoleAppropriationDependency: Dependency {
    
    
    var keychainStorageServicing: any FPTextStorageServicing { get }
    
    
    var networkingClient: FPNetworkingClient { get }
    
    
    var sessionIdentityService: FPSessionIdentityServicing { get }
    
    
//    var sessionIdentityServiceMementoAgent: FPSessionIdetityServiceMementoAgent { get }
    
}



/// Concrete implementation of the ``RoleAppropriationDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``RoleAppropriationRouter``.
final class RoleAppropriationComponent: Component<RoleAppropriationDependency> {
    
    
    /// Constructs a singleton instance of ``RoleAppropriationViewController``.
    var roleAppropriationViewController: RoleAppropriationViewControllable & RoleAppropriationPresentable {
        shared { DispatchQueue.main.sync {
            RoleAppropriationViewController()
        }}
    }
    
    
    var keychainStorageServicing: any FPTextStorageServicing { 
        dependency.keychainStorageServicing 
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
    
    var sessionIdentityService: FPSessionIdentityServicing {
        dependency.sessionIdentityService
    }
    
    
//    var sessionIdentityServiceMementoAgent: FPSessionIdetityServiceMementoAgent {
//        dependency.sessionIdentityServiceMementoAgent
//    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension RoleAppropriationComponent: MemberRoleScopingDependency, CrewRoleScopingDependency, ManagementRoleScopingDependency {}



/// Contract adhered to by ``RoleAppropriationBuilder``, listing necessary actions to
/// construct a functional `RoleAppropriationRIB`.
protocol RoleAppropriationBuildable: Buildable {
    
    
    /// Constructs the `RoleAppropriationRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: RoleAppropriationListener) -> RoleAppropriationRouting
    
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
    func build(withListener listener: RoleAppropriationListener) -> RoleAppropriationRouting {
        let component  = RoleAppropriationComponent(dependency: dependency)
        let interactor = RoleAppropriationInteractor(component: component)
            interactor.listener = listener
        
        return RoleAppropriationRouter(
            interactor: interactor, 
            viewController: component.roleAppropriationViewController
        )
    }
    
}
