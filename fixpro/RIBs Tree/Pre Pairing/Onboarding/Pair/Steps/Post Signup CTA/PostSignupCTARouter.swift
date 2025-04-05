import RIBs


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``PostSignupCTAInteractor`` (internal use).
/// 
/// Conform this protocol to other RIBs' `Listener` protocols, to mark ``PostSignupCTAInteractor`` 
/// as able to receive and will handle events coming from its descendants. 
protocol PostSignupCTAInteractable: Interactable {
    var router  : PostSignupCTARouting? { get set }
    var listener: PostSignupCTAListener? { get set }
    var isImmidiatelyAccepted: Bool { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `PostSignupCTARIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``PostSignupCTARouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``PostSignupCTARouter`` that manipulates 
/// the view its controlling.
protocol PostSignupCTAViewControllable: ViewControllable {}


/// Manages the UI of `PostSignupCTARIB` and relation with another RIB.
final class PostSignupCTARouter: ViewableRouter<PostSignupCTAInteractable, PostSignupCTAViewControllable>, PostSignupCTARouting {
    
    override init (
        interactor    : PostSignupCTAInteractable,
        viewController: PostSignupCTAViewControllable
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
}
