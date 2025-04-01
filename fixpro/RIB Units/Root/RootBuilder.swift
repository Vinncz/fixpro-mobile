import RIBs


extension EmptyComponent: RootDependency {}


/// Collection of types whose instances are necessary for `RootRIB` to function.
/// 
/// This protocol may be used externally of `RootRIB`.
/// 
/// When you intend for `RootRIB` to bear descendant(s), 
/// you **MUST** conform either ``RootDependency`` 
/// or ``RootComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``RootBuilder`` uses a concrete implementation of
/// this protocol--usually the ``RootComponent``.
protocol RootDependency: Dependency {}


/// Concrete implementation of ``RootDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``RootBuilder`` is responsible to make an instance of ``RootComponent``
/// which then populates the properties of ``RootDependency``.
final class RootComponent: Component<RootDependency>, 
                           MainframeDependency,
                           OnboardingDependency 
{
    var mainframeViewController: MainframeViewControllable { 
        rootViewController
    }
    var sessionService: FPSessionCredentialsStorageService { 
        shared { FPSessionCredentialsStorageService(storage: FPKeychainQueristService()) }
    }
    
    fileprivate let rootViewController = RootViewController()
    
    init() { super.init(dependency: EmptyComponent()) }
}


/// Collection of methods who defines what it takes to construct `RootRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `RootRIB` if given the required dependencies.
protocol RootBuildable: Buildable {
    /// Constructs and initializes the `RootRIB`.
    func build () -> LaunchRouting
}


/// Constructs and assembles the `RootRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``RootBuilder``, as the ancestral RIB, should be created inside the `SceneDelegate` or `AppDelegate`.
/// 
/// Whereas children may bear grandchildren, a `Builder` is only responsible for its immediate descendants.
/// Meaning, this `Builder` should supply the `Builder` of a grandchildren, to its children.
final class RootBuilder: Builder<RootDependency>, RootBuildable {
    
    init () {
        super.init(dependency: EmptyComponent())
    }
    
    func build () -> LaunchRouting {
        let component  = RootComponent()
        let interactor = RootInteractor(presenter: component.rootViewController)
        
        return RootRouter (
            interactor       : interactor, 
            viewController   : component.rootViewController,
            mainframeBuilder : MainframeBuilder(dependency: component),
            onboardingBuilder: OnboardingBuilder(dependency: component)
        )
    }
    
}
