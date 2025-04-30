import Foundation
import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `InboxRIB` does not require any dependencies from its parent scope.
protocol InboxDependency: Dependency {
    var networkingClient: FPNetworkingClient { get }
}



/// Concrete implementation of the ``InboxDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``InboxRouter``.
final class InboxComponent: Component<InboxDependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension InboxComponent {}



/// Contract adhered to by ``InboxBuilder``, listing necessary actions to
/// construct a functional `InboxRIB`.
protocol InboxBuildable: Buildable {
    
    
    /// Constructs the `InboxRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: InboxListener) -> InboxRouting
    
}



/// The composer of `InboxRIB`.
final class InboxBuilder: Builder<InboxDependency>, InboxBuildable {
    
    
    /// Creates an instance of ``InboxBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: InboxDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `InboxRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: InboxListener) -> InboxRouting {
        let viewController = InboxViewController()
        let component  = InboxComponent(dependency: dependency)
        let interactor = InboxInteractor(component: component, presenter: viewController)
            interactor.listener = listener
        
        return InboxRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
