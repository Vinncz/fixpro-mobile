import RIBs


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``MainframeInteractor`` (internal use).
protocol MainframeInteractable: Interactable,
                                RoleAppropriationListener
{
    var router  : MainframeRouting? { get set }
    var listener: MainframeListener? { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `MainframeRIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``MainframeRouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``MainframeRouter`` that manipulates 
/// the view its controlling.
protocol MainframeViewControllable: ViewControllable, RoleAppropriationViewControllable {}


/// Manages the UI of `MainframeRIB` and relation with another RIB.
final class MainframeRouter: Router<MainframeInteractable>, MainframeRouting {
    
    private let roleAppropriationBuildable: RoleAppropriationBuilder
    private var roleAppropriationRouting  : RoleAppropriationRouting? = nil
    
    var parentViewController: MainframeViewControllable?
    
    init (
        interactor: MainframeInteractable, 
        viewController: MainframeViewControllable,
        roleAppropriationBuilder: RoleAppropriationBuilder
    ) {
        self.parentViewController = viewController
        self.roleAppropriationBuildable = roleAppropriationBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }
    
    func cleanupViews () {
        guard let roleAppropriationRouting else { return }
        roleAppropriationRouting.cleanupViews()
        self.detachChild(roleAppropriationRouting)
        self.roleAppropriationRouting = nil
        FPLogger.log("Detached roleAppropriationRouting")
    }
    
    func attachRoleAppropriationFlow() {
        let roleAppropriationRouting = self.roleAppropriationBuildable.build(withListener: self.interactor)
        self.roleAppropriationRouting = roleAppropriationRouting
        self.attachChild(roleAppropriationRouting)
        FPLogger.log("Attached roleAppropriationRouting")
    }
    
}
