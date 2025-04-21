import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `TicketListsRIB` does not require any dependencies from its parent scope.
protocol TicketListsDependency: Dependency {}



/// Concrete implementation of the ``TicketListsDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``TicketListsRouter``.
final class TicketListsComponent: Component<TicketListsDependency> {
    
    
    /// Constructs a singleton instance of ``TicketListsViewController``.
    var ticketListsViewController: TicketListsViewControllable & TicketListsPresentable {
        shared { TicketListsViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension TicketListsComponent {}



/// Contract adhered to by ``TicketListsBuilder``, listing necessary actions to
/// construct a functional `TicketListsRIB`.
protocol TicketListsBuildable: Buildable {
    
    
    /// Constructs the `TicketListsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketListsListener) -> TicketListsRouting
    
}



/// The composer of `TicketListsRIB`.
final class TicketListsBuilder: Builder<TicketListsDependency>, TicketListsBuildable {
    
    
    /// Creates an instance of ``TicketListsBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: TicketListsDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `TicketListsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketListsListener) -> TicketListsRouting {
        let component  = TicketListsComponent(dependency: dependency)
        let interactor = TicketListsInteractor(component: component)
            interactor.listener = listener
        
        return TicketListsRouter(
            interactor: interactor, 
            viewController: component.ticketListsViewController
        )
    }
    
}
