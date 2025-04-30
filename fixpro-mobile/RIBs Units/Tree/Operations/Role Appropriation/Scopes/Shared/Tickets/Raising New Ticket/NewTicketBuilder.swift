import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `NewTicketRIB` does not require any dependencies from its parent scope.
protocol NewTicketDependency: Dependency {
    var locationBeacon: VULocationBeacon { get }
    var networkingClient: FPNetworkingClient { get }
}



/// Concrete implementation of the ``NewTicketDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``NewTicketRouter``.
final class NewTicketComponent: Component<NewTicketDependency> {
    
    
    /// Constructs a singleton instance of ``NewTicketViewController``.
    var newTicketViewController: NewTicketViewControllable & NewTicketPresentable {
        shared { NewTicketViewController() }
    }
    
    
    var locationBeacon: VULocationBeacon {
        dependency.locationBeacon
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension NewTicketComponent {}



/// Contract adhered to by ``NewTicketBuilder``, listing necessary actions to
/// construct a functional `NewTicketRIB`.
protocol NewTicketBuildable: Buildable {
    
    
    /// Constructs the `NewTicketRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: NewTicketListener) -> NewTicketRouting
    
}



/// The composer of `NewTicketRIB`.
final class NewTicketBuilder: Builder<NewTicketDependency>, NewTicketBuildable {
    
    
    /// Creates an instance of ``NewTicketBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: NewTicketDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `NewTicketRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: NewTicketListener) -> NewTicketRouting {
        let component  = NewTicketComponent(dependency: dependency)
        let interactor = NewTicketInteractor(component: component)
            interactor.listener = listener
        
        return NewTicketRouter(
            interactor: interactor, 
            viewController: component.newTicketViewController
        )
    }
    
}
