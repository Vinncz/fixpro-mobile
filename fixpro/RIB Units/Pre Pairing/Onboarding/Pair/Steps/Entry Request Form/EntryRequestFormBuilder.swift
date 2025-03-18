import RIBs


/// Collection of types whose instances are necessary for `EntryRequestFormRIB` to function.
/// 
/// This protocol may be used externally of `EntryRequestFormRIB`.
/// 
/// When you intend for `EntryRequestFormRIB` to bear descendant(s), 
/// you **MUST** conform either ``EntryRequestFormDependency`` 
/// or ``EntryRequestFormComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``EntryRequestFormBuilder`` uses a concrete implementation of
/// this protocol--usually the ``EntryRequestFormComponent``.
protocol EntryRequestFormDependency: Dependency {}


/// Concrete implementation of ``EntryRequestFormDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``EntryRequestFormBuilder`` is responsible to make an instance of ``EntryRequestFormComponent``
/// which then populates the properties of ``EntryRequestFormDependency``.
final class EntryRequestFormComponent: Component<EntryRequestFormDependency> {}


/// Collection of methods who defines what it takes to construct `EntryRequestFormRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `EntryRequestFormRIB` if given the required dependencies.
protocol EntryRequestFormBuildable: Buildable {
    /// Constructs and initializes the `EntryRequestFormRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: EntryRequestFormListener) -> EntryRequestFormRouting
}


/// Constructs and assembles the `EntryRequestFormRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``EntryRequestFormBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class EntryRequestFormBuilder: Builder<EntryRequestFormDependency>, EntryRequestFormBuildable {

    override init (dependency: EntryRequestFormDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: EntryRequestFormListener) -> EntryRequestFormRouting {
        let component      = EntryRequestFormComponent(dependency: dependency)
        let viewController = EntryRequestFormViewController()
        let interactor     = EntryRequestFormInteractor(presenter: viewController)
            interactor.listener = listener
        
        return EntryRequestFormRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
