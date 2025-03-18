import RIBs


/// Collection of types whose instances are necessary for `PairRIB` to function.
/// 
/// This protocol may be used externally of `PairRIB`.
/// 
/// When you intend for `PairRIB` to bear descendant(s), 
/// you **MUST** conform either ``PairDependency`` 
/// or ``PairComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``PairBuilder`` uses a concrete implementation of
/// this protocol--usually the ``PairComponent``.
protocol PairDependency: Dependency {}


/// Concrete implementation of ``PairDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``PairBuilder`` is responsible to make an instance of ``PairComponent``
/// which then populates the properties of ``PairDependency``.
final class PairComponent: Component<PairDependency> {}


/// Collection of methods who defines what it takes to construct `PairRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `PairRIB` if given the required dependencies.
protocol PairBuildable: Buildable {
    /// Constructs and initializes the `PairRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: PairListener) -> PairRouting
}


/// Constructs and assembles the `PairRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``PairBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class PairBuilder: Builder<PairDependency>, PairBuildable {

    override init (dependency: PairDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: PairListener) -> PairRouting {
        let component      = PairComponent(dependency: dependency)
        let viewController = PairViewController()
        let interactor     = PairInteractor(presenter: viewController)
            interactor.listener = listener
        
        let csDependency: CodeScanDependency = {
            class CSDependency: CodeScanDependency {
                
            }
            return CSDependency()
        }()
        
        let erfDependency: EntryRequestFormDependency = {
            class ERFDependency: EntryRequestFormDependency {
                
            }
            return ERFDependency()
        }()
        
        let pscta: PostSignupCTADependency = {
            class PSCTADependency: PostSignupCTADependency {
                
            }
            return PSCTADependency()
        }()
        
        return PairRouter (
            interactor    : interactor, 
            viewController: viewController,
            codeScanBuilder: CodeScanBuilder(dependency: csDependency),
            entryRequestFormBuilder: EntryRequestFormBuilder(dependency: erfDependency),
            postSignupCTABuilder: PostSignupCTABuilder(dependency: pscta)
        )
    }
    
}
