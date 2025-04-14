import Foundation
import RIBs



/// A set of properties that are required by `RoleAppropriationRIB` to function, 
/// supplied from the scope of its parent.
protocol RoleAppropriationDependency: Dependency {}



/// Concrete implementation of the ``RoleAppropriationDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``RoleAppropriationRouter``.
final class RoleAppropriationComponent: Component<RoleAppropriationDependency> {
    
    
    /// Constructs a singleton instance of ``RoleAppropriationViewController``.
    var roleAppropriationViewController: RoleAppropriationViewControllable & RoleAppropriationPresentable {
        shared { DispatchQueue.main.sync {
            RoleAppropriationViewController()
        }}
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension RoleAppropriationComponent {}



/// Contract adhered to by ``RoleAppropriationBuilder``, listing necessary actions to
/// construct a functional `RoleAppropriationRIB`.
protocol RoleAppropriationBuildable: Buildable {
    
    
    /// Constructs the `RoleAppropriationRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: RoleAppropriationListener) -> RoleAppropriationRouting
    
}



/// The composer of `RoleAppropriationRIB`.
final class RoleAppropriationBuilder: Builder<RoleAppropriationDependency>, RoleAppropriationBuildable {
    
    
    /// Creates an instance of ``RoleAppropriationBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: RoleAppropriationDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `RoleAppropriationRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: RoleAppropriationListener) -> RoleAppropriationRouting {
        let component  = RoleAppropriationComponent(dependency: dependency)
        let interactor = RoleAppropriationInteractor(component: component)
            interactor.listener = listener
        
        return RoleAppropriationRouter(
            interactor: interactor, 
            viewController: component.roleAppropriationViewController
        )
    }
    
}
