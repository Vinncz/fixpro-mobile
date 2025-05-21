import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `CrewNewWorkLogRIB` does not require any dependencies from its parent scope.
protocol CrewNewWorkLogDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var networkingClient: FPNetworkingClient { get }
}



/// Concrete implementation of the ``CrewNewWorkLogDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``CrewNewWorkLogRouter``.
final class CrewNewWorkLogComponent: Component<CrewNewWorkLogDependency> {
    
    
    /// Constructs a singleton instance of ``CrewNewWorkLogViewController``.
    var crewNewWorkLogViewController: CrewNewWorkLogViewControllable & CrewNewWorkLogPresentable {
        shared { CrewNewWorkLogViewController() }
    }
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension CrewNewWorkLogComponent {}



/// Contract adhered to by ``CrewNewWorkLogBuilder``, listing necessary actions to
/// construct a functional `CrewNewWorkLogRIB`.
protocol CrewNewWorkLogBuildable: Buildable {
    
    
    /// Constructs the `CrewNewWorkLogRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewNewWorkLogListener, ticketId: String) -> CrewNewWorkLogRouting
    
}



/// The composer of `CrewNewWorkLogRIB`.
final class CrewNewWorkLogBuilder: Builder<CrewNewWorkLogDependency>, CrewNewWorkLogBuildable {
    
    
    /// Creates an instance of ``CrewNewWorkLogBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: CrewNewWorkLogDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `CrewNewWorkLogRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewNewWorkLogListener, ticketId: String) -> CrewNewWorkLogRouting {
        let component  = CrewNewWorkLogComponent(dependency: dependency)
        let interactor = CrewNewWorkLogInteractor(component: component, ticketId: ticketId)
            interactor.listener = listener
        
        return CrewNewWorkLogRouter(
            interactor: interactor, 
            viewController: component.crewNewWorkLogViewController
        )
    }
    
}
