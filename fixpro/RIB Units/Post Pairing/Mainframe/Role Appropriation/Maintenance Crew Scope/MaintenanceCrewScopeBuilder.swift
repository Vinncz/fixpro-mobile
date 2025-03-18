import RIBs


/// Collection of types whose instances are necessary for `MaintenanceCrewScopeRIB` to function.
/// 
/// This protocol may be used externally of `MaintenanceCrewScopeRIB`.
/// 
/// When you intend for `MaintenanceCrewScopeRIB` to bear descendant(s), 
/// you **MUST** conform either ``MaintenanceCrewScopeDependency`` 
/// or ``MaintenanceCrewScopeComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``MaintenanceCrewScopeBuilder`` uses a concrete implementation of
/// this protocol--usually the ``MaintenanceCrewScopeComponent``.
protocol MaintenanceCrewScopeDependency: Dependency {}


/// Concrete implementation of ``MaintenanceCrewScopeDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``MaintenanceCrewScopeBuilder`` is responsible to make an instance of ``MaintenanceCrewScopeComponent``
/// which then populates the properties of ``MaintenanceCrewScopeDependency``.
final class MaintenanceCrewScopeComponent: Component<MaintenanceCrewScopeDependency> {}


/// Collection of methods who defines what it takes to construct `MaintenanceCrewScopeRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `MaintenanceCrewScopeRIB` if given the required dependencies.
protocol MaintenanceCrewScopeBuildable: Buildable {
    /// Constructs and initializes the `MaintenanceCrewScopeRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: MaintenanceCrewScopeListener) -> MaintenanceCrewScopeRouting
}


/// Constructs and assembles the `MaintenanceCrewScopeRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``MaintenanceCrewScopeBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class MaintenanceCrewScopeBuilder: Builder<MaintenanceCrewScopeDependency>, MaintenanceCrewScopeBuildable {

    override init (dependency: MaintenanceCrewScopeDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: MaintenanceCrewScopeListener) -> MaintenanceCrewScopeRouting {
        let component      = MaintenanceCrewScopeComponent(dependency: dependency)
        let viewController = MaintenanceCrewScopeViewController()
        let interactor     = MaintenanceCrewScopeInteractor(presenter: viewController)
            interactor.listener = listener
        
        return MaintenanceCrewScopeRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
