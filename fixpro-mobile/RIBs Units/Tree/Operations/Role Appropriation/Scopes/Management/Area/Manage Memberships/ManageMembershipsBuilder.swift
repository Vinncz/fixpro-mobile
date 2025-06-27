import RIBs



/// A set of properties that are required by `ManageMembershipsRIB` to function, 
/// supplied from the scope of its parent.
protocol ManageMembershipsDependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
}



/// Concrete implementation of the ``ManageMembershipsDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``ManageMembershipsRouter``.
final class ManageMembershipsComponent: Component<ManageMembershipsDependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension ManageMembershipsComponent {}



/// Contract adhered to by ``ManageMembershipsBuilder``, listing necessary actions to
/// construct a functional `ManageMembershipsRIB`.
protocol ManageMembershipsBuildable: Buildable {
    
    
    /// Constructs the `ManageMembershipsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ManageMembershipsListener) -> ManageMembershipsRouting
    
}



/// The composer of `ManageMembershipsRIB`.
final class ManageMembershipsBuilder: Builder<ManageMembershipsDependency>, ManageMembershipsBuildable {
    
    
    /// Creates an instance of ``ManageMembershipsBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: ManageMembershipsDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `ManageMembershipsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ManageMembershipsListener) -> ManageMembershipsRouting {
        let viewController = ManageMembershipsViewController()
        let component  = ManageMembershipsComponent(dependency: dependency)
        let interactor = ManageMembershipsInteractor(component: component, presenter: viewController)
        
        interactor.listener = listener
        
        return ManageMembershipsRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
