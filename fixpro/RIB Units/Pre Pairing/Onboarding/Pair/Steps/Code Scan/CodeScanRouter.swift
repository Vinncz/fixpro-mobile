import RIBs


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``CodeScanInteractor`` (internal use).
/// 
/// Conform this protocol to other RIBs' `Listener` protocols, to mark ``CodeScanInteractor`` 
/// as able to receive and will handle events coming from its descendants. 
protocol CodeScanInteractable: Interactable {
    var router  : CodeScanRouting? { get set }
    var listener: CodeScanListener? { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `CodeScanRIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``CodeScanRouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``CodeScanRouter`` that manipulates 
/// the view its controlling.
protocol CodeScanViewControllable: ViewControllable {}


/// Manages the UI of `CodeScanRIB` and relation with another RIB.
final class CodeScanRouter: ViewableRouter<CodeScanInteractable, CodeScanViewControllable>, CodeScanRouting {
    
    override init (
        interactor    : CodeScanInteractable, 
        viewController: CodeScanViewControllable
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
}
