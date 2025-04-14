import RIBs
import VinUtility



/// A set of properties that are required by `OperationsRIB` to function, 
/// supplied from the scope of its parent.
protocol OperationsDependency: Dependency {
    
    
    /// A `UIViewController` that can be controlled by `OperationsRIB`.
    var operationsViewController: OperationsViewControllable { get }
    
    
    var networkingClientProxy: any VUProxy<FPNetworkingClient> { get }
    
    
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> { get }
    
    
    var sessionIdentityServiceMementoAgentProxy: any VUProxy<FPSessionIdetityServiceMementoAgent> { get }
    
}



/// Concrete implementation of the ``OperationsDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``OperationsRouter``.
final class OperationsComponent: Component<OperationsDependency> {
    
    
    var operationsViewController: OperationsViewControllable {
        return dependency.operationsViewController
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClientProxy.backing!
    }
    
    
    var sessionIdentityService: FPSessionIdentityServicing {
        dependency.sessionIdentityServiceProxy.backing!
    }
    
    
    var sessionIdentityServiceMementoAgent: FPSessionIdetityServiceMementoAgent {
        dependency.sessionIdentityServiceMementoAgentProxy.backing!
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension OperationsComponent: RoleAppropriationDependency {}



/// Contract adhered to by ``OperationsBuilder``, listing necessary actions to
/// construct a functional `OperationsRIB`.
protocol OperationsBuildable: Buildable {
    
    
    /// Constructs the `OperationsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: OperationsListener) -> OperationsRouting
    
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
    func build(withListener listener: OperationsListener) -> OperationsRouting {
        let component  = OperationsComponent(dependency: dependency)
        let interactor = OperationsInteractor(component: component)
            interactor.listener = listener
            
        return OperationsRouter(
            interactor: interactor, 
            viewController: component.operationsViewController,
            roleAppropriationBuilder: RoleAppropriationBuilder(dependency: component)
        )
    }
    
}
