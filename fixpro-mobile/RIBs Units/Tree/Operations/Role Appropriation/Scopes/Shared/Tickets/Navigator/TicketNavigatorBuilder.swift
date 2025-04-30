import RIBs



/// A set of properties that are required by `TicketNavigatorRIB` to function, 
/// supplied from the scope of its parent.
protocol TicketNavigatorDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var networkingClient: FPNetworkingClient { get }
}



/// Concrete implementation of the ``TicketNavigatorDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``TicketNavigatorRouter``.
final class TicketNavigatorComponent: Component<TicketNavigatorDependency> {
    
    
    /// Constructs a singleton instance of ``TicketNavigatorViewController``.
    var ticketNavigatorNavigationController: TicketNavigatorViewControllable & TicketNavigatorPresentable {
        shared { TicketNavigatorNavigationController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension TicketNavigatorComponent: TicketListsDependency, TicketDetailDependency, TicketLogDependency {
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Contract adhered to by ``TicketNavigatorBuilder``, listing necessary actions to
/// construct a functional `TicketNavigatorRIB`.
protocol TicketNavigatorBuildable: Buildable {
    
    
    /// Constructs the `TicketNavigatorRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketNavigatorListener) -> TicketNavigatorRouting
    
}



/// The composer of `TicketNavigatorRIB`.
final class TicketNavigatorBuilder: Builder<TicketNavigatorDependency>, TicketNavigatorBuildable {
    
    
    /// Creates an instance of ``TicketNavigatorBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: TicketNavigatorDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `TicketNavigatorRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketNavigatorListener) -> TicketNavigatorRouting {
        let component  = TicketNavigatorComponent(dependency: dependency)
        let interactor = TicketNavigatorInteractor(component: component)
            interactor.listener = listener
        
        return TicketNavigatorRouter(
            interactor: interactor, 
            viewController: component.ticketNavigatorNavigationController,
            ticketListBuilder: TicketListsBuilder(dependency: component),
            ticketDetailsBuilder: TicketDetailBuilder(dependency: component),
            ticketLogBuilder: TicketLogBuilder(dependency: component)
        )
    }
    
}
