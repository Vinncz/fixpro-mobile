import RIBs



/// A set of properties that are required by `CrewDelegatingRIB` to function, 
/// supplied from the scope of its parent.
protocol CrewDelegatingDependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
}



/// Concrete implementation of the ``CrewDelegatingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``CrewDelegatingRouter``.
final class CrewDelegatingComponent: Component<CrewDelegatingDependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension CrewDelegatingComponent {}



/// Contract adhered to by ``CrewDelegatingBuilder``, listing necessary actions to
/// construct a functional `CrewDelegatingRIB`.
protocol CrewDelegatingBuildable: Buildable {
    
    
    /// Constructs the `CrewDelegatingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewDelegatingListener, ticket: FPTicketDetail) -> CrewDelegatingRouting
    
}



/// The composer of `CrewDelegatingRIB`.
final class CrewDelegatingBuilder: Builder<CrewDelegatingDependency>, CrewDelegatingBuildable {
    
    
    /// Creates an instance of ``CrewDelegatingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: CrewDelegatingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `CrewDelegatingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewDelegatingListener, ticket: FPTicketDetail) -> CrewDelegatingRouting {
        let viewController = CrewDelegatingViewController()
        let component  = CrewDelegatingComponent(dependency: dependency)
        let interactor = CrewDelegatingInteractor(component: component, presenter: viewController, ticket: ticket)
        
        interactor.listener = listener
        
        return CrewDelegatingRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
