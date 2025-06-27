import RIBs



/// A set of properties that are required by `UpdateContributingRIB` to function, 
/// supplied from the scope of its parent.
protocol UpdateContributingDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var networkingClient: FPNetworkingClient { get }
}



/// Concrete implementation of the ``UpdateContributingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``UpdateContributingRouter``.
final class UpdateContributingComponent: Component<UpdateContributingDependency> {
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension UpdateContributingComponent {}



/// Contract adhered to by ``UpdateContributingBuilder``, listing necessary actions to
/// construct a functional `UpdateContributingRIB`.
protocol UpdateContributingBuildable: Buildable {
    
    
    /// Constructs the `UpdateContributingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: UpdateContributingListener, ticketId: String) -> UpdateContributingRouting
    
}



/// The composer of `UpdateContributingRIB`.
final class UpdateContributingBuilder: Builder<UpdateContributingDependency>, UpdateContributingBuildable {
    
    
    /// Creates an instance of ``UpdateContributingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: UpdateContributingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `UpdateContributingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: UpdateContributingListener, ticketId: String) -> UpdateContributingRouting {
        let viewController = UpdateContributingViewController()
        let component  = UpdateContributingComponent(dependency: dependency)
        let interactor = UpdateContributingInteractor(component: component, presenter: viewController, ticketId: ticketId)
        
        interactor.listener = listener
        
        return UpdateContributingRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
