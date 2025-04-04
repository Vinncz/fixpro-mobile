import RIBs


/// Collection of types whose instances are necessary for `MainframeRIB` to function.
/// 
/// This protocol may be used externally of `MainframeRIB`.
/// 
/// When you intend for `MainframeRIB` to bear descendant(s), 
/// you **MUST** conform either ``MainframeDependency`` 
/// or ``MainframeComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``MainframeBuilder`` uses a concrete implementation of
/// this protocol--usually the ``MainframeComponent``.
protocol MainframeDependency: Dependency {
    /// The view which `MainframeRIB` will be able to manipulate.
    var mainframeViewController: MainframeViewControllable { get }
    var identitySessionServiceProxy: any Proxy<FPIdentitySessionServicing> { get }
}


/// Concrete implementation of ``MainframeDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``MainframeBuilder`` is responsible to make an instance of ``MainframeComponent``
/// which then populates the properties of ``MainframeDependency``.
final class MainframeComponent: Component<MainframeDependency>,
                                RoleAppropriationDependency
{
    var roleAppropriationViewController: any RoleAppropriationViewControllable { dependency.mainframeViewController }
    var identitySessionService: FPIdentitySessionServicing { dependency.identitySessionServiceProxy.backing! }
    
    // Fileprivate attribute marks dependencies to be provided by self--and not some outside source.
    fileprivate var mainframeViewController: MainframeViewControllable {
        return dependency.mainframeViewController
    }
}


/// Collection of methods who defines what it takes to construct `MainframeRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `MainframeRIB` if given the required dependencies.
protocol MainframeBuildable: Buildable {
    /// Constructs and initializes the `MainframeRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: MainframeListener) -> MainframeRouting
}


/// Constructs and assembles the `MainframeRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``MainframeBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class MainframeBuilder: Builder<MainframeDependency>, MainframeBuildable {

    override init (dependency: MainframeDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: MainframeListener) -> MainframeRouting {
        let component  = MainframeComponent(dependency: dependency)
        let interactor = MainframeInteractor()
            interactor.listener = listener
        
        return MainframeRouter (
            interactor: interactor, 
            viewController: component.mainframeViewController,
            roleAppropriationBuilder: RoleAppropriationBuilder(dependency: component)
        )
    }
    
}
