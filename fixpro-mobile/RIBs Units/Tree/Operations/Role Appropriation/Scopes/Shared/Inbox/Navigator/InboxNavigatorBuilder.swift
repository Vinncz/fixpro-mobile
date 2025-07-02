import RIBs



/// A set of properties that are required by `InboxNavigatorRIB` to function, 
/// supplied from the scope of its parent.
protocol InboxNavigatorDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var networkingClient: FPNetworkingClient { get }
    var identityService: FPSessionIdentityServicing { get }
}



/// Concrete implementation of the ``InboxNavigatorDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``InboxNavigatorRouter``.
final class InboxNavigatorComponent: Component<InboxNavigatorDependency> {
    
    
    /// Constructs a singleton instance of ``InboxNavigatorViewController``.
    var inboxNavigatorNavigationController: InboxNavigatorViewControllable & InboxNavigatorPresentable {
        shared { InboxNavigatorNavigationController() }
    }
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension InboxNavigatorComponent: InboxDependency, TicketDetailDependency, TicketLogDependency {
    
    
    var identityService: FPSessionIdentityServicing {
        dependency.identityService
    }
    
}



/// Contract adhered to by ``InboxNavigatorBuilder``, listing necessary actions to
/// construct a functional `InboxNavigatorRIB`.
protocol InboxNavigatorBuildable: Buildable {
    
    
    /// Constructs the `InboxNavigatorRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: InboxNavigatorListener) -> InboxNavigatorRouting
    
}



/// The composer of `InboxNavigatorRIB`.
final class InboxNavigatorBuilder: Builder<InboxNavigatorDependency>, InboxNavigatorBuildable {
    
    
    /// Creates an instance of ``InboxNavigatorBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: InboxNavigatorDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `InboxNavigatorRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: InboxNavigatorListener) -> InboxNavigatorRouting {
        let component  = InboxNavigatorComponent(dependency: dependency)
        let interactor = InboxNavigatorInteractor(component: component)
            interactor.listener = listener
        
        return InboxNavigatorRouter(
            interactor: interactor, 
            viewController: component.inboxNavigatorNavigationController,
            inboxBuilder: InboxBuilder(dependency: component), 
            ticketDetailBuilder: TicketDetailBuilder(dependency: component),
            ticketLogBuilder: TicketLogBuilder(dependency: component)
        )
    }
    
}
