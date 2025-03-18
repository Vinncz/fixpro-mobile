import RIBs


/// Collection of types whose instances are necessary for `MemberScopeRIB` to function.
/// 
/// This protocol may be used externally of `MemberScopeRIB`.
/// 
/// When you intend for `MemberScopeRIB` to bear descendant(s), 
/// you **MUST** conform either ``MemberScopeDependency`` 
/// or ``MemberScopeComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``MemberScopeBuilder`` uses a concrete implementation of
/// this protocol--usually the ``MemberScopeComponent``.
protocol MemberScopeDependency: Dependency {}


/// Concrete implementation of ``MemberScopeDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``MemberScopeBuilder`` is responsible to make an instance of ``MemberScopeComponent``
/// which then populates the properties of ``MemberScopeDependency``.
final class MemberScopeComponent: Component<MemberScopeDependency> {}


/// Collection of methods who defines what it takes to construct `MemberScopeRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `MemberScopeRIB` if given the required dependencies.
protocol MemberScopeBuildable: Buildable {
    /// Constructs and initializes the `MemberScopeRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: MemberScopeListener) -> MemberScopeRouting
}


/// Constructs and assembles the `MemberScopeRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``MemberScopeBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class MemberScopeBuilder: Builder<MemberScopeDependency>, MemberScopeBuildable {

    override init (dependency: MemberScopeDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: MemberScopeListener) -> MemberScopeRouting {
        let component      = MemberScopeComponent(dependency: dependency)
        let viewController = MemberScopeViewController()
        let interactor     = MemberScopeInteractor(presenter: viewController)
            interactor.listener = listener
        
        return MemberScopeRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
