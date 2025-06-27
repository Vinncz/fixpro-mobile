import RIBs



/// A set of properties that are required by `CrewInvitingRIB` to function, 
/// supplied from the scope of its parent.
protocol CrewInvitingDependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
    
    var authorizationContext: FPRoleContext { get }
    
}



/// Concrete implementation of the ``CrewInvitingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``CrewInvitingRouter``.
final class CrewInvitingComponent: Component<CrewInvitingDependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension CrewInvitingComponent {}



/// Contract adhered to by ``CrewInvitingBuilder``, listing necessary actions to
/// construct a functional `CrewInvitingRIB`.
protocol CrewInvitingBuildable: Buildable {
    
    
    /// Constructs the `CrewInvitingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewInvitingListener, ticket: FPTicketDetail) -> CrewInvitingRouting
    
}



/// The composer of `CrewInvitingRIB`.
final class CrewInvitingBuilder: Builder<CrewInvitingDependency>, CrewInvitingBuildable {
    
    
    /// Creates an instance of ``CrewInvitingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: CrewInvitingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `CrewInvitingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewInvitingListener, ticket: FPTicketDetail) -> CrewInvitingRouting {
        let viewController = CrewInvitingViewController()
        let component  = CrewInvitingComponent(dependency: dependency)
        let interactor = CrewInvitingInteractor(component: component, presenter: viewController, ticket: ticket)
        
        interactor.listener = listener
        
        return CrewInvitingRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
