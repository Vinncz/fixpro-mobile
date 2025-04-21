import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `LocationDetailFromTicketDetailRIB` does not require any dependencies from its parent scope.
protocol LocationDetailFromTicketDetailDependency: Dependency {}



/// Concrete implementation of the ``LocationDetailFromTicketDetailDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``LocationDetailFromTicketDetailRouter``.
final class LocationDetailFromTicketDetailComponent: Component<LocationDetailFromTicketDetailDependency> {
    
    
    /// Constructs a singleton instance of ``LocationDetailFromTicketDetailViewController``.
    var locationDetailFromTicketDetailViewController: LocationDetailFromTicketDetailViewControllable & LocationDetailFromTicketDetailPresentable {
        shared { LocationDetailFromTicketDetailViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension LocationDetailFromTicketDetailComponent {}



/// Contract adhered to by ``LocationDetailFromTicketDetailBuilder``, listing necessary actions to
/// construct a functional `LocationDetailFromTicketDetailRIB`.
protocol LocationDetailFromTicketDetailBuildable: Buildable {
    
    
    /// Constructs the `LocationDetailFromTicketDetailRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: LocationDetailFromTicketDetailListener) -> LocationDetailFromTicketDetailRouting
    
}



/// The composer of `LocationDetailFromTicketDetailRIB`.
final class LocationDetailFromTicketDetailBuilder: Builder<LocationDetailFromTicketDetailDependency>, LocationDetailFromTicketDetailBuildable {
    
    
    /// Creates an instance of ``LocationDetailFromTicketDetailBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: LocationDetailFromTicketDetailDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `LocationDetailFromTicketDetailRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: LocationDetailFromTicketDetailListener) -> LocationDetailFromTicketDetailRouting {
        let component  = LocationDetailFromTicketDetailComponent(dependency: dependency)
        let interactor = LocationDetailFromTicketDetailInteractor(component: component)
            interactor.listener = listener
        
        return LocationDetailFromTicketDetailRouter(
            interactor: interactor, 
            viewController: component.locationDetailFromTicketDetailViewController
        )
    }
    
}
