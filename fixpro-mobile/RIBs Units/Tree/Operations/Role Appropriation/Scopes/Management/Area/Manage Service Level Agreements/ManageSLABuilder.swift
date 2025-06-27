import RIBs



/// A set of properties that are required by `ManageSLARIB` to function, 
/// supplied from the scope of its parent.
protocol ManageSLADependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
}



/// Concrete implementation of the ``ManageSLADependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``ManageSLARouter``.
final class ManageSLAComponent: Component<ManageSLADependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension ManageSLAComponent {}



/// Contract adhered to by ``ManageSLABuilder``, listing necessary actions to
/// construct a functional `ManageSLARIB`.
protocol ManageSLABuildable: Buildable {
    
    
    /// Constructs the `ManageSLARIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ManageSLAListener) -> ManageSLARouting
    
}



/// The composer of `ManageSLARIB`.
final class ManageSLABuilder: Builder<ManageSLADependency>, ManageSLABuildable {
    
    
    /// Creates an instance of ``ManageSLABuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: ManageSLADependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `ManageSLARIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ManageSLAListener) -> ManageSLARouting {
        let viewController = ManageSLAViewController()
        let component  = ManageSLAComponent(dependency: dependency)
        let interactor = ManageSLAInteractor(component: component, presenter: viewController)
        
        interactor.listener = listener
        
        return ManageSLARouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
