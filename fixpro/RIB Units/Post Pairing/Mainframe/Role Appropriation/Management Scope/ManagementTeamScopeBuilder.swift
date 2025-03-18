import RIBs


/// Collection of types whose instances are necessary for `ManagementTeamScopeRIB` to function.
/// 
/// This protocol may be used externally of `ManagementTeamScopeRIB`.
/// 
/// When you intend for `ManagementTeamScopeRIB` to bear descendant(s), 
/// you **MUST** conform either ``ManagementTeamScopeDependency`` 
/// or ``ManagementTeamScopeComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``ManagementTeamScopeBuilder`` uses a concrete implementation of
/// this protocol--usually the ``ManagementTeamScopeComponent``.
protocol ManagementTeamScopeDependency: Dependency {}


/// Concrete implementation of ``ManagementTeamScopeDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``ManagementTeamScopeBuilder`` is responsible to make an instance of ``ManagementTeamScopeComponent``
/// which then populates the properties of ``ManagementTeamScopeDependency``.
final class ManagementTeamScopeComponent: Component<ManagementTeamScopeDependency> {}


/// Collection of methods who defines what it takes to construct `ManagementTeamScopeRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `ManagementTeamScopeRIB` if given the required dependencies.
protocol ManagementTeamScopeBuildable: Buildable {
    /// Constructs and initializes the `ManagementTeamScopeRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: ManagementTeamScopeListener) -> ManagementTeamScopeRouting
}


/// Constructs and assembles the `ManagementTeamScopeRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``ManagementTeamScopeBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class ManagementTeamScopeBuilder: Builder<ManagementTeamScopeDependency>, ManagementTeamScopeBuildable {

    override init (dependency: ManagementTeamScopeDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: ManagementTeamScopeListener) -> ManagementTeamScopeRouting {
        let component      = ManagementTeamScopeComponent(dependency: dependency)
        let viewController = ManagementTeamScopeViewController()
        let interactor     = ManagementTeamScopeInteractor(presenter: viewController)
            interactor.listener = listener
        
        return ManagementTeamScopeRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
