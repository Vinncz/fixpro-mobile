import RIBs


/// Collection of types whose instances are necessary for `CrewScopedRIB` to function.
/// 
/// This protocol may be used externally of `CrewScopedRIB`.
/// 
/// When you intend for `CrewScopedRIB` to bear descendant(s), 
/// you **MUST** conform either ``CrewScopedDependency`` 
/// or ``CrewScopedComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``CrewScopedBuilder`` uses a concrete implementation of
/// this protocol--usually the ``CrewScopedComponent``.
protocol CrewScopedDependency: Dependency {
    var sessionService: FPSessionCredentialsStorageService { get }
}


/// Concrete implementation of ``CrewScopedDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``CrewScopedBuilder`` is responsible to make an instance of ``CrewScopedComponent``
/// which then populates the properties of ``CrewScopedDependency``.
final class CrewScopedComponent: Component<CrewScopedDependency> {
    var sessionService: FPSessionCredentialsStorageService { dependency.sessionService }
}


/// Collection of methods who defines what it takes to construct `CrewScopedRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `CrewScopedRIB` if given the required dependencies.
protocol CrewScopedBuildable: Buildable {
    /// Constructs and initializes the `CrewScopedRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: CrewScopedListener) -> CrewScopedRouting
}


/// Constructs and assembles the `CrewScopedRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``CrewScopedBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class CrewScopedBuilder: Builder<CrewScopedDependency>, CrewScopedBuildable {

    override init (dependency: CrewScopedDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: CrewScopedListener) -> CrewScopedRouting {
        let component      = CrewScopedComponent(dependency: dependency)
        let viewController = CrewScopedViewController()
        let interactor     = CrewScopedInteractor(presenter: viewController)
            interactor.listener = listener
        
        return CrewScopedRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
