import RIBs



/// A set of properties that are required by `WorkEvaluatingRIB` to function, 
/// supplied from the scope of its parent.
protocol WorkEvaluatingDependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
}



/// Concrete implementation of the ``WorkEvaluatingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``WorkEvaluatingRouter``.
final class WorkEvaluatingComponent: Component<WorkEvaluatingDependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension WorkEvaluatingComponent {}



/// Contract adhered to by ``WorkEvaluatingBuilder``, listing necessary actions to
/// construct a functional `WorkEvaluatingRIB`.
protocol WorkEvaluatingBuildable: Buildable {
    
    
    /// Constructs the `WorkEvaluatingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: WorkEvaluatingListener, ticket: FPTicketDetail) -> WorkEvaluatingRouting
    
}



/// The composer of `WorkEvaluatingRIB`.
final class WorkEvaluatingBuilder: Builder<WorkEvaluatingDependency>, WorkEvaluatingBuildable {
    
    
    /// Creates an instance of ``WorkEvaluatingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: WorkEvaluatingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `WorkEvaluatingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: WorkEvaluatingListener, ticket: FPTicketDetail) -> WorkEvaluatingRouting {
        let viewController = WorkEvaluatingViewController()
        let component  = WorkEvaluatingComponent(dependency: dependency)
        let interactor = WorkEvaluatingInteractor(component: component, presenter: viewController, ticket: ticket)
        
        interactor.listener = listener
        
        return WorkEvaluatingRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
