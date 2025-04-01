import RIBs


/// Collection of types whose instances are necessary for `MemberScopedRIB` to function.
/// 
/// This protocol may be used externally of `MemberScopedRIB`.
/// 
/// When you intend for `MemberScopedRIB` to bear descendant(s), 
/// you **MUST** conform either ``MemberScopedDependency`` 
/// or ``MemberScopedComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``MemberScopedBuilder`` uses a concrete implementation of
/// this protocol--usually the ``MemberScopedComponent``.
protocol MemberScopedDependency: Dependency {
    var sessionService: FPSessionCredentialsStorageService { get }
}


/// Concrete implementation of ``MemberScopedDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``MemberScopedBuilder`` is responsible to make an instance of ``MemberScopedComponent``
/// which then populates the properties of ``MemberScopedDependency``.
final class MemberScopedComponent: Component<MemberScopedDependency> {
    var sessionService: FPSessionCredentialsStorageService { shared { dependency.sessionService } }
}


/// Collection of methods who defines what it takes to construct `MemberScopedRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `MemberScopedRIB` if given the required dependencies.
protocol MemberScopedBuildable: Buildable {
    /// Constructs and initializes the `MemberScopedRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: MemberScopedListener) -> MemberScopedRouting
}


/// Constructs and assembles the `MemberScopedRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``MemberScopedBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class MemberScopedBuilder: Builder<MemberScopedDependency>, MemberScopedBuildable {

    override init (dependency: MemberScopedDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: MemberScopedListener) -> MemberScopedRouting {
        let component      = MemberScopedComponent(dependency: dependency)
        let viewController = MemberScopedViewController()
        let interactor     = MemberScopedInteractor(presenter: viewController)
            interactor.listener = listener
        
        return MemberScopedRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
