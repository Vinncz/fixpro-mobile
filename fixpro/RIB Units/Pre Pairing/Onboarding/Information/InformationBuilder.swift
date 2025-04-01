import RIBs


/// Collection of types whose instances are necessary for `InformationRIB` to function.
/// 
/// This protocol may be used externally of `InformationRIB`.
/// 
/// When you intend for `InformationRIB` to bear descendant(s), 
/// you **MUST** conform either ``InformationDependency`` 
/// or ``InformationComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``InformationBuilder`` uses a concrete implementation of
/// this protocol--usually the ``InformationComponent``.
protocol InformationDependency: Dependency {}


/// Concrete implementation of ``InformationDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``InformationBuilder`` is responsible to make an instance of ``InformationComponent``
/// which then populates the properties of ``InformationDependency``.
final class InformationComponent: Component<InformationDependency> {}


/// Collection of methods who defines what it takes to construct `InformationRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `InformationRIB` if given the required dependencies.
protocol InformationBuildable: Buildable {
    /// Constructs and initializes the `InformationRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: InformationListener) -> InformationRouting
}


/// Constructs and assembles the `InformationRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``InformationBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class InformationBuilder: Builder<InformationDependency>, InformationBuildable {

    override init (dependency: InformationDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: InformationListener) -> InformationRouting {
        let viewController = InformationViewController()
        let interactor     = InformationInteractor(presenter: viewController)
            interactor.listener = listener
        
        return InformationRouter (
            interactor    : interactor, 
            viewController: viewController
        )
    }
    
}
