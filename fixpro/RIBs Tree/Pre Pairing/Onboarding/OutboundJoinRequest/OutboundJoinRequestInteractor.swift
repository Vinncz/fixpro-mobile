import RIBs
import RxSwift


/// Collection of methods which ``OutboundJoinRequestInteractor`` can invoke, 
/// to perform something on its enclosing router (``OutboundJoinRequestRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``OutboundJoinRequestRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``OutboundJoinRequestInteractor`` and
/// ``OutboundJoinRequestRouter``, to enable business logic to manipulate the UI.
protocol OutboundJoinRequestRouting: ViewableRouting {}


/// Collection of methods which ``OutboundJoinRequestInteractor`` can invoke, 
/// to present data on ``OutboundJoinRequestViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``OutboundJoinRequestViewController``.
///
/// The `Presentable` protocol bridges between ``OutboundJoinRequestInteractor`` and 
/// ``OutboundJoinRequestViewController``, to enable business logic to navigate the UI.
protocol OutboundJoinRequestPresentable: Presentable {
    var presentableListener: OutboundJoinRequestPresentableListener? { get set }
}


/// Collection of methods which ``OutboundJoinRequestInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``OutboundJoinRequestInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``OutboundJoinRequestInteractor``.
protocol OutboundJoinRequestListener: AnyObject {}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class OutboundJoinRequestInteractor: PresentableInteractor<OutboundJoinRequestPresentable>, OutboundJoinRequestInteractable, OutboundJoinRequestPresentableListener {
    
    
    /// The reference to the Router where self resides on.
    weak var router: OutboundJoinRequestRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: OutboundJoinRequestListener?
    
    
    // TODO: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init (presenter: OutboundJoinRequestPresentable) {
        super.init(presenter: presenter)
        presenter.presentableListener = self
    }
    
    
    /// Logics to perform after self becomes activated.
    override func didBecomeActive () {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }
    
    
    /// Logics to perform after self is nudged to be deactivated.
    override func willResignActive () {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
}
