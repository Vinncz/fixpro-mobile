import RIBs
import RxSwift


/// Collection of methods which ``MainframeInteractor`` can invoke, 
/// to perform something on its enclosing router (``MainframeRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``MainframeRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``MainframeInteractor`` and
/// ``MainframeRouter``, to enable business logic to manipulate the UI.
protocol MainframeRouting: Routing {
    /// Detaches any views this RIB may have added to the hierarchy.
    /// 
    /// NEVER perform business logic here. It's exclusively for view management.
    func cleanupViews()
    func attachRoleAppropriationFlow()
}


/// Collection of methods which ``MainframeInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``MainframeInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``MainframeInteractor``.
protocol MainframeListener: AnyObject {
    func didFinishPairingAndRequestingChangeOfFlowToPostPairing()
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class MainframeInteractor: Interactor, MainframeInteractable {
    
    
    /// The reference to the Router where self resides on.
    weak var router: MainframeRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: MainframeListener?
    
    
    override init () {}
    
    
    /// Logics to perform after self becomes activated.
    override func didBecomeActive () {
        super.didBecomeActive()
        
        
        router?.attachRoleAppropriationFlow()
    }
    
    
    /// Logics to perform after self is nudged to be deactivated.
    override func willResignActive () {
        super.willResignActive()
        router?.cleanupViews()
    }
    
}
