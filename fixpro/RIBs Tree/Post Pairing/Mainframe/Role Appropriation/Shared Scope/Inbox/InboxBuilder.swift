import RIBs


/// Collection of types whose instances are necessary for `InboxRIB` to function.
/// 
/// This protocol may be used externally of `InboxRIB`.
/// 
/// When you intend for `InboxRIB` to bear descendant(s), 
/// you **MUST** conform either ``InboxDependency`` 
/// or ``InboxComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``InboxBuilder`` uses a concrete implementation of
/// this protocol--usually the ``InboxComponent``.
protocol InboxDependency: Dependency {}


/// Concrete implementation of ``InboxDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``InboxBuilder`` is responsible to make an instance of ``InboxComponent``
/// which then populates the properties of ``InboxDependency``.
final class InboxComponent: Component<InboxDependency> {}


/// Collection of methods who defines what it takes to construct `InboxRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `InboxRIB` if given the required dependencies.
protocol InboxBuildable: Buildable {
    /// Constructs and initializes the `InboxRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: InboxListener) -> InboxRouting
}


/// Constructs and assembles the `InboxRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``InboxBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class InboxBuilder: Builder<InboxDependency>, InboxBuildable {

    override init (dependency: InboxDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: InboxListener) -> InboxRouting {
        let component      = InboxComponent(dependency: dependency)
        let viewController = InboxViewController()
        let interactor     = InboxInteractor(presenter: viewController)
            interactor.listener = listener
        
        return InboxRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
