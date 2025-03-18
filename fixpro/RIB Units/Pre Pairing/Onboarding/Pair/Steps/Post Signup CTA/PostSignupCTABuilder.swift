import RIBs


/// Collection of types whose instances are necessary for `PostSignupCTARIB` to function.
/// 
/// This protocol may be used externally of `PostSignupCTARIB`.
/// 
/// When you intend for `PostSignupCTARIB` to bear descendant(s), 
/// you **MUST** conform either ``PostSignupCTADependency`` 
/// or ``PostSignupCTAComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``PostSignupCTABuilder`` uses a concrete implementation of
/// this protocol--usually the ``PostSignupCTAComponent``.
protocol PostSignupCTADependency: Dependency {}


/// Concrete implementation of ``PostSignupCTADependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``PostSignupCTABuilder`` is responsible to make an instance of ``PostSignupCTAComponent``
/// which then populates the properties of ``PostSignupCTADependency``.
final class PostSignupCTAComponent: Component<PostSignupCTADependency> {}


/// Collection of methods who defines what it takes to construct `PostSignupCTARIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `PostSignupCTARIB` if given the required dependencies.
protocol PostSignupCTABuildable: Buildable {
    /// Constructs and initializes the `PostSignupCTARIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: PostSignupCTAListener, isImmidiatelyAccepted: Bool) -> PostSignupCTARouting
}


/// Constructs and assembles the `PostSignupCTARIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``PostSignupCTABuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class PostSignupCTABuilder: Builder<PostSignupCTADependency>, PostSignupCTABuildable {

    override init (dependency: PostSignupCTADependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: PostSignupCTAListener, isImmidiatelyAccepted: Bool) -> PostSignupCTARouting {
        let component      = PostSignupCTAComponent(dependency: dependency)
        let viewController = PostSignupCTAViewController()
        let interactor     = PostSignupCTAInteractor(presenter: viewController, isImmidiatelyAccepted: isImmidiatelyAccepted)
            interactor.listener = listener
        
        return PostSignupCTARouter (
            interactor    : interactor, 
            viewController: viewController
        )
    }
    
}
