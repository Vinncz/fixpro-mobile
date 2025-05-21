import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `WorkEvaluatingRIB` does not require any dependencies from its parent scope.
protocol WorkEvaluatingDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var networkingClient: FPNetworkingClient { get }
}



/// Concrete implementation of the ``WorkEvaluatingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``WorkEvaluatingRouter``.
final class WorkEvaluatingComponent: Component<WorkEvaluatingDependency> {
    
    
    /// Constructs a singleton instance of ``WorkEvaluatingViewController``.
    var workEvaluatingViewController: WorkEvaluatingViewControllable & WorkEvaluatingPresentable {
        shared { WorkEvaluatingViewController() }
    }
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
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
    func build(withListener listener: WorkEvaluatingListener, workLogs: [FPTicketLog]) -> WorkEvaluatingRouting
    
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
    func build(withListener listener: WorkEvaluatingListener, workLogs: [FPTicketLog]) -> WorkEvaluatingRouting {
        let component  = WorkEvaluatingComponent(dependency: dependency)
        let interactor = WorkEvaluatingInteractor(component: component, workLogs: workLogs)
            interactor.listener = listener
        
        return WorkEvaluatingRouter(
            interactor: interactor, 
            viewController: component.workEvaluatingViewController
        )
    }
    
}
