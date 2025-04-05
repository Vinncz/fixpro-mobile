import RIBs


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``InformationInteractor`` (internal use).
/// 
/// Conform this protocol to other RIBs' `Listener` protocols, to mark ``InformationInteractor`` 
/// as able to receive and will handle events coming from its descendants. 
protocol InformationInteractable: Interactable {
    var router  : InformationRouting? { get set }
    var listener: InformationListener? { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `InformationRIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``InformationRouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``InformationRouter`` that manipulates 
/// the view its controlling.
protocol InformationViewControllable: ViewControllable {}


/// Manages the UI of `InformationRIB` and relation with another RIB.
final class InformationRouter: ViewableRouter<InformationInteractable, InformationViewControllable>, InformationRouting {
    
    // TODO: Add builders of children
    // private let childBuilder: /*ChildRIBName*/Buildable
    
    // TODO: Add references to child `Router`(s) using the `Routing` protocol.
    //       Once you instantiate them using their builder, put their instance here.
    // private var childRouting: /*ChildRIBName*/Routing?
    
    // TODO: Constructor inject child builder protocols to allow building children.
    override init (
        interactor    : InformationInteractable, 
        viewController: InformationViewControllable
        // TODO: Constructor inject child builder protocols.
        // childBuilder: /*ChildRIBName*/Buildable
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // TODO: Perform something on load.
    override func didLoad() {
        super.didLoad()
    }
    
}
