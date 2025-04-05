import RIBs


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``EntryRequestFormInteractor`` (internal use).
/// 
/// Conform this protocol to other RIBs' `Listener` protocols, to mark ``EntryRequestFormInteractor`` 
/// as able to receive and will handle events coming from its descendants. 
protocol EntryRequestFormInteractable: Interactable {
    var router  : EntryRequestFormRouting? { get set }
    var listener: EntryRequestFormListener? { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `EntryRequestFormRIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``EntryRequestFormRouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``EntryRequestFormRouter`` that manipulates 
/// the view its controlling.
protocol EntryRequestFormViewControllable: ViewControllable {}


/// Manages the UI of `EntryRequestFormRIB` and relation with another RIB.
final class EntryRequestFormRouter: ViewableRouter<EntryRequestFormInteractable, EntryRequestFormViewControllable>, EntryRequestFormRouting {
    
    override init (
        interactor    : EntryRequestFormInteractable, 
        viewController: EntryRequestFormViewControllable
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
}
