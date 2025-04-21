import RIBs



/// A set of properties that are required by `ManagementRoleScopingRIB` to function, 
/// supplied from the scope of its parent.
protocol ManagementRoleScopingDependency: Dependency {}



/// Concrete implementation of the ``ManagementRoleScopingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``ManagementRoleScopingRouter``.
final class ManagementRoleScopingComponent: Component<ManagementRoleScopingDependency> {
    
    
    /// Constructs a singleton instance of ``ManagementRoleScopingViewController``.
    var managementRoleScopingViewController: ManagementRoleScopingViewControllable & ManagementRoleScopingPresentable {
        shared { ManagementRoleScopingViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension ManagementRoleScopingComponent: TicketListsDependency, WorkCalendarDependency, AreaManagementDependency, InboxDependency, PreferencesDependency {}



/// Contract adhered to by ``ManagementRoleScopingBuilder``, listing necessary actions to
/// construct a functional `ManagementRoleScopingRIB`.
protocol ManagementRoleScopingBuildable: Buildable {
    
    
    /// Constructs the `ManagementRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ManagementRoleScopingListener) -> ManagementRoleScopingRouting
    
}



/// The composer of `ManagementRoleScopingRIB`.
final class ManagementRoleScopingBuilder: Builder<ManagementRoleScopingDependency>, ManagementRoleScopingBuildable {
    
    
    /// Creates an instance of ``ManagementRoleScopingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: ManagementRoleScopingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `ManagementRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ManagementRoleScopingListener) -> ManagementRoleScopingRouting {
        let component  = ManagementRoleScopingComponent(dependency: dependency)
        let interactor = ManagementRoleScopingInteractor(component: component)
            interactor.listener = listener
        
        return ManagementRoleScopingRouter(
            interactor: interactor, 
            viewController: component.managementRoleScopingViewController,
            ticketListBuilder: TicketListsBuilder(dependency: component),
            workCalendarBuilder: WorkCalendarBuilder(dependency: component),
            areaManagementBuilder: AreaManagementBuilder(dependency: component),
            inboxBuilder: InboxBuilder(dependency: component),
            preferencesBuilder: PreferencesBuilder(dependency: component)
        )
    }
    
}
