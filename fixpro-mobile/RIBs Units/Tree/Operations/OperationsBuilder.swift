import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `OperationsRIB` does not require any dependencies from its parent scope.
protocol OperationsDependency: Dependency {
    var operationsViewController: OperationsViewControllable { get }
    var keychainStorageServicing: any FPTextStorageServicing { get }
    
    var networkingClientProxy: any VUProxy<FPNetworkingClient> { get }
    
    var sessionIdentityService: FPSessionIdentityServicing { get }
    var sessionIdentityServiceMementoAgent: FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot> { get }
    var sessionidentityServiceUpkeeper: FPSessionIdentityUpkeeping { get }
}



/// Concrete implementation of the ``OperationsDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``OperationsRouter``.
final class OperationsComponent: Component<OperationsDependency> {
    
    
    var operationsViewController: OperationsViewControllable & OperationsPresentable {
        shared { OperationsViewController() }
    }
    
    
    var keychainStorageServicing: any FPTextStorageServicing {
        dependency.keychainStorageServicing
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClientProxy.backing!
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
extension OperationsComponent: RoleAppropriationDependency {}



/// Contract adhered to by ``OperationsBuilder``, listing necessary actions to
/// construct a functional `OperationsRIB`.
protocol OperationsBuildable: Buildable {
    
    
    /// Constructs the `OperationsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: OperationsListener, triggerNotification: FPNotificationDigest?) -> OperationsRouting
    
}



/// The composer of `OperationsRIB`.
final class OperationsBuilder: Builder<OperationsDependency>, OperationsBuildable {
    
    
    /// Creates an instance of ``OperationsBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: OperationsDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `OperationsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: OperationsListener, triggerNotification: FPNotificationDigest?) -> OperationsRouting {
        let component  = OperationsComponent(dependency: dependency)
        let interactor = OperationsInteractor(component: component, triggerNotification: triggerNotification)
            interactor.listener = listener
        
        return OperationsRouter(
            interactor: interactor, 
            viewController: component.operationsViewController,
            roleAppropriationBuilder: RoleAppropriationBuilder(dependency: component)
        )
    }
    
}
