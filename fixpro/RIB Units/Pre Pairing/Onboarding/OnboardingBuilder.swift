import RIBs


/// Collection of types whose instances are necessary for `OnboardingRIB` to function.
/// 
/// This protocol may be used externally of `OnboardingRIB`.
/// 
/// When you intend for `OnboardingRIB` to bear descendant(s), 
/// you **MUST** conform either ``OnboardingDependency`` 
/// or ``OnboardingComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``OnboardingBuilder`` uses a concrete implementation of
/// this protocol--usually the ``OnboardingComponent``.
protocol OnboardingDependency: Dependency {}


/// Concrete implementation of ``OnboardingDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``OnboardingBuilder`` is responsible to make an instance of ``OnboardingComponent``
/// which then populates the properties of ``OnboardingDependency``.
final class OnboardingComponent: Component<OnboardingDependency>,
                                 PairDependency,
                                 InformationDependency
{
//    var pairingService: FPPairingService {
//        shared { FPPairingService() }
//    }
}


/// Collection of methods who defines what it takes to construct `OnboardingRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `OnboardingRIB` if given the required dependencies.
protocol OnboardingBuildable: Buildable {
    /// Constructs and initializes the `OnboardingRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: OnboardingListener) -> OnboardingRouting
}


/// Constructs and assembles the `OnboardingRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``OnboardingBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class OnboardingBuilder: Builder<OnboardingDependency>, OnboardingBuildable {

    override init (dependency: OnboardingDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: OnboardingListener) -> OnboardingRouting {
        let component      = OnboardingComponent(dependency: dependency)
        let viewController = OnboardingViewController()
        let interactor     = OnboardingInteractor(presenter: viewController)
            interactor.listener = listener
        
        return OnboardingRouter (
            interactor: interactor, 
            viewController: viewController,
            informationBuilder: InformationBuilder(dependency: component),
            pairBuilder: PairBuilder(dependency: component)
        )
    }
    
}
