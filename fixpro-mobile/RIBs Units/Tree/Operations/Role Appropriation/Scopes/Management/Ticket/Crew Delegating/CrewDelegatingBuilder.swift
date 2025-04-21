import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `CrewDelegatingRIB` does not require any dependencies from its parent scope.
protocol CrewDelegatingDependency: Dependency {}



/// Concrete implementation of the ``CrewDelegatingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``CrewDelegatingRouter``.
final class CrewDelegatingComponent: Component<CrewDelegatingDependency> {
    
    
    /// Constructs a singleton instance of ``CrewDelegatingViewController``.
    var crewDelegatingViewController: CrewDelegatingViewControllable & CrewDelegatingPresentable {
        shared { CrewDelegatingViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension CrewDelegatingComponent {}



/// Contract adhered to by ``CrewDelegatingBuilder``, listing necessary actions to
/// construct a functional `CrewDelegatingRIB`.
protocol CrewDelegatingBuildable: Buildable {
    
    
    /// Constructs the `CrewDelegatingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewDelegatingListener) -> CrewDelegatingRouting
    
}



/// The composer of `CrewDelegatingRIB`.
final class CrewDelegatingBuilder: Builder<CrewDelegatingDependency>, CrewDelegatingBuildable {
    
    
    /// Creates an instance of ``CrewDelegatingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: CrewDelegatingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `CrewDelegatingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewDelegatingListener) -> CrewDelegatingRouting {
        let component  = CrewDelegatingComponent(dependency: dependency)
        let interactor = CrewDelegatingInteractor(component: component)
            interactor.listener = listener
        
        return CrewDelegatingRouter(
            interactor: interactor, 
            viewController: component.crewDelegatingViewController
        )
    }
    
}
