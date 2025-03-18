import RIBs


/// Collection of types whose instances are necessary for `CodeScanRIB` to function.
/// 
/// This protocol may be used externally of `CodeScanRIB`.
/// 
/// When you intend for `CodeScanRIB` to bear descendant(s), 
/// you **MUST** conform either ``CodeScanDependency`` 
/// or ``CodeScanComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``CodeScanBuilder`` uses a concrete implementation of
/// this protocol--usually the ``CodeScanComponent``.
protocol CodeScanDependency: Dependency {}


/// Concrete implementation of ``CodeScanDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``CodeScanBuilder`` is responsible to make an instance of ``CodeScanComponent``
/// which then populates the properties of ``CodeScanDependency``.
final class CodeScanComponent: Component<CodeScanDependency> {}


/// Collection of methods who defines what it takes to construct `CodeScanRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `CodeScanRIB` if given the required dependencies.
protocol CodeScanBuildable: Buildable {
    /// Constructs and initializes the `CodeScanRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: CodeScanListener) -> CodeScanRouting
}


/// Constructs and assembles the `CodeScanRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``CodeScanBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class CodeScanBuilder: Builder<CodeScanDependency>, CodeScanBuildable {

    override init (dependency: CodeScanDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: CodeScanListener) -> CodeScanRouting {
        let component      = CodeScanComponent(dependency: dependency)
        let viewController = CodeScanViewController()
        let interactor     = CodeScanInteractor(presenter: viewController)
            interactor.listener = listener
        
        return CodeScanRouter (
            interactor    : interactor, 
            viewController: viewController
            // TODO: Pass grandchildren's builders here
        )
    }
    
}
