import RIBs


/// Collection of types whose instances are necessary for `ManagementScopedRIB` to function.
/// 
/// This protocol may be used externally of `ManagementScopedRIB`.
/// 
/// When you intend for `ManagementScopedRIB` to bear descendant(s), 
/// you **MUST** conform either ``ManagementScopedDependency`` 
/// or ``ManagementScopedComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``ManagementScopedBuilder`` uses a concrete implementation of
/// this protocol--usually the ``ManagementScopedComponent``.
protocol ManagementScopedDependency: Dependency {
    var identitySessionService: FPIdentitySessionServicing { get }
}


/// Concrete implementation of ``ManagementScopedDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``ManagementScopedBuilder`` is responsible to make an instance of ``ManagementScopedComponent``
/// which then populates the properties of ``ManagementScopedDependency``.
final class ManagementScopedComponent: Component<ManagementScopedDependency> {
    var identitySessionService: FPIdentitySessionServicing { dependency.identitySessionService }
}


/// Collection of methods who defines what it takes to construct `ManagementScopedRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `ManagementScopedRIB` if given the required dependencies.
protocol ManagementScopedBuildable: Buildable {
    /// Constructs and initializes the `ManagementScopedRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: ManagementScopedListener) -> ManagementScopedRouting
}


/// Constructs and assembles the `ManagementScopedRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``ManagementScopedBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class ManagementScopedBuilder: Builder<ManagementScopedDependency>, ManagementScopedBuildable {

    override init (dependency: ManagementScopedDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: ManagementScopedListener) -> ManagementScopedRouting {
        let component      = ManagementScopedComponent(dependency: dependency)
        let viewController = ManagementScopedViewController()
        let interactor     = ManagementScopedInteractor(presenter: viewController)
            interactor.listener = listener
        
        return ManagementScopedRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
