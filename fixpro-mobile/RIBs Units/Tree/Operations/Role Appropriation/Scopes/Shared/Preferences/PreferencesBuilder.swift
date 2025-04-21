import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `PreferencesRIB` does not require any dependencies from its parent scope.
protocol PreferencesDependency: Dependency {}



/// Concrete implementation of the ``PreferencesDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``PreferencesRouter``.
final class PreferencesComponent: Component<PreferencesDependency> {
    
    
    /// Constructs a singleton instance of ``PreferencesViewController``.
    var preferencesViewController: PreferencesViewControllable & PreferencesPresentable {
        shared { PreferencesViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension PreferencesComponent {}



/// Contract adhered to by ``PreferencesBuilder``, listing necessary actions to
/// construct a functional `PreferencesRIB`.
protocol PreferencesBuildable: Buildable {
    
    
    /// Constructs the `PreferencesRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: PreferencesListener) -> PreferencesRouting
    
}



/// The composer of `PreferencesRIB`.
final class PreferencesBuilder: Builder<PreferencesDependency>, PreferencesBuildable {
    
    
    /// Creates an instance of ``PreferencesBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: PreferencesDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `PreferencesRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: PreferencesListener) -> PreferencesRouting {
        let component  = PreferencesComponent(dependency: dependency)
        let interactor = PreferencesInteractor(component: component)
            interactor.listener = listener
        
        return PreferencesRouter(
            interactor: interactor, 
            viewController: component.preferencesViewController
        )
    }
    
}
