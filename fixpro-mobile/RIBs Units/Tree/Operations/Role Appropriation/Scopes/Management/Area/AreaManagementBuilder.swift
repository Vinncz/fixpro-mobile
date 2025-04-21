import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `AreaManagementRIB` does not require any dependencies from its parent scope.
protocol AreaManagementDependency: Dependency {}



/// Concrete implementation of the ``AreaManagementDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaManagementRouter``.
final class AreaManagementComponent: Component<AreaManagementDependency> {
    
    
    /// Constructs a singleton instance of ``AreaManagementViewController``.
    var areaManagementViewController: AreaManagementViewControllable & AreaManagementPresentable {
        shared { AreaManagementViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaManagementComponent {}



/// Contract adhered to by ``AreaManagementBuilder``, listing necessary actions to
/// construct a functional `AreaManagementRIB`.
protocol AreaManagementBuildable: Buildable {
    
    
    /// Constructs the `AreaManagementRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagementListener) -> AreaManagementRouting
    
}



/// The composer of `AreaManagementRIB`.
final class AreaManagementBuilder: Builder<AreaManagementDependency>, AreaManagementBuildable {
    
    
    /// Creates an instance of ``AreaManagementBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaManagementDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaManagementRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagementListener) -> AreaManagementRouting {
        let component  = AreaManagementComponent(dependency: dependency)
        let interactor = AreaManagementInteractor(component: component)
            interactor.listener = listener
        
        return AreaManagementRouter(
            interactor: interactor, 
            viewController: component.areaManagementViewController
        )
    }
    
}
