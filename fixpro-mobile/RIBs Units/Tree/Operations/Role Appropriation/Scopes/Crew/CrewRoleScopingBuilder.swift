import RIBs



/// A set of properties that are required by `CrewRoleScopingRIB` to function, 
/// supplied from the scope of its parent.
protocol CrewRoleScopingDependency: Dependency {}



/// Concrete implementation of the ``CrewRoleScopingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``CrewRoleScopingRouter``.
final class CrewRoleScopingComponent: Component<CrewRoleScopingDependency> {
    
    
    /// Constructs a singleton instance of ``CrewRoleScopingViewController``.
    var crewRoleScopingViewController: CrewRoleScopingViewControllable & CrewRoleScopingPresentable {
        shared { CrewRoleScopingViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension CrewRoleScopingComponent: TicketListsDependency, WorkCalendarDependency, NewTicketDependency, InboxDependency, PreferencesDependency {}



/// Contract adhered to by ``CrewRoleScopingBuilder``, listing necessary actions to
/// construct a functional `CrewRoleScopingRIB`.
protocol CrewRoleScopingBuildable: Buildable {
    
    
    /// Constructs the `CrewRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewRoleScopingListener) -> CrewRoleScopingRouting
    
}



/// The composer of `CrewRoleScopingRIB`.
final class CrewRoleScopingBuilder: Builder<CrewRoleScopingDependency>, CrewRoleScopingBuildable {
    
    
    /// Creates an instance of ``CrewRoleScopingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: CrewRoleScopingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `CrewRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewRoleScopingListener) -> CrewRoleScopingRouting {
        let component  = CrewRoleScopingComponent(dependency: dependency)
        let interactor = CrewRoleScopingInteractor(component: component)
            interactor.listener = listener
        
        return CrewRoleScopingRouter(
            interactor: interactor, 
            viewController: component.crewRoleScopingViewController,
            ticketListBuilder: TicketListsBuilder(dependency: component),
            workCalendarBuilder: WorkCalendarBuilder(dependency: component),
            newTicketBuilder: NewTicketBuilder(dependency: component),
            inboxBuilder: InboxBuilder(dependency: component),
            preferencesBuilder: PreferencesBuilder(dependency: component)
        )
    }
    
}
