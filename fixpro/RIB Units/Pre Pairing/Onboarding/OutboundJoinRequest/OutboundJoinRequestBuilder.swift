import RIBs


/// Collection of types whose instances are necessary for `OutboundJoinRequestRIB` to function.
/// 
/// This protocol may be used externally of `OutboundJoinRequestRIB`.
/// 
/// When you intend for `OutboundJoinRequestRIB` to bear descendant(s), 
/// you **MUST** conform either ``OutboundJoinRequestDependency`` 
/// or ``OutboundJoinRequestComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``OutboundJoinRequestBuilder`` uses a concrete implementation of
/// this protocol--usually the ``OutboundJoinRequestComponent``.
protocol OutboundJoinRequestDependency: Dependency {}


/// Concrete implementation of ``OutboundJoinRequestDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``OutboundJoinRequestBuilder`` is responsible to make an instance of ``OutboundJoinRequestComponent``
/// which then populates the properties of ``OutboundJoinRequestDependency``.
final class OutboundJoinRequestComponent: Component<OutboundJoinRequestDependency> {}


/// Collection of methods who defines what it takes to construct `OutboundJoinRequestRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `OutboundJoinRequestRIB` if given the required dependencies.
protocol OutboundJoinRequestBuildable: Buildable {
    /// Constructs and initializes the `OutboundJoinRequestRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: OutboundJoinRequestListener) -> OutboundJoinRequestRouting
}


/// Constructs and assembles the `OutboundJoinRequestRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``OutboundJoinRequestBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class OutboundJoinRequestBuilder: Builder<OutboundJoinRequestDependency>, OutboundJoinRequestBuildable {

    override init (dependency: OutboundJoinRequestDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: OutboundJoinRequestListener) -> OutboundJoinRequestRouting {
        let component      = OutboundJoinRequestComponent(dependency: dependency)
        let viewController = OutboundJoinRequestViewController()
        let interactor     = OutboundJoinRequestInteractor(presenter: viewController)
            interactor.listener = listener
        
        return OutboundJoinRequestRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
