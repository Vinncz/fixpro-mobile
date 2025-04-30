import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `TicketDetailRIB` does not require any dependencies from its parent scope.
protocol TicketDetailDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var networkingClient: FPNetworkingClient { get }
}



/// Concrete implementation of the ``TicketDetailDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``TicketDetailRouter``.
final class TicketDetailComponent: Component<TicketDetailDependency> {
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension TicketDetailComponent: CrewNewWorkLogDependency, CrewDelegatingDependency, WorkEvaluatingDependency, TicketReportDependency {}



/// Contract adhered to by ``TicketDetailBuilder``, listing necessary actions to
/// construct a functional `TicketDetailRIB`.
protocol TicketDetailBuildable: Buildable {
    
    
    /// Constructs the `TicketDetailRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketDetailListener, ticket: FPTicketDetail?, ticketId: String?) -> TicketDetailRouting
    
}



/// The composer of `TicketDetailRIB`.
final class TicketDetailBuilder: Builder<TicketDetailDependency>, TicketDetailBuildable {
    
    
    /// Creates an instance of ``TicketDetailBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: TicketDetailDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `TicketDetailRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketDetailListener, ticket: FPTicketDetail?, ticketId: String?) -> TicketDetailRouting {
        let viewController = TicketDetailViewController()
        let component  = TicketDetailComponent(dependency: dependency)
        let interactor = TicketDetailInteractor(component: component, presenter: viewController, ticket: ticket, ticketId: ticketId)
            interactor.listener = listener
        
        return TicketDetailRouter(
            interactor: interactor, 
            viewController: viewController,
            crewNewWorkLogBuilder: CrewNewWorkLogBuilder(dependency: component),
            crewDelegatingBuilder: CrewDelegatingBuilder(dependency: component),
            workEvaluatingBuilder: WorkEvaluatingBuilder(dependency: component),
            ticketReportBuilder: TicketReportBuilder(dependency: component)
        )
    }
    
}
