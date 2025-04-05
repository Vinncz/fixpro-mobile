import RIBs
import RxSwift


/// Collection of methods which ``InboxInteractor`` can invoke, 
/// to perform something on its enclosing router (``InboxRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``InboxRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``InboxInteractor`` and
/// ``InboxRouter``, to enable business logic to manipulate the UI.
protocol InboxRouting: ViewableRouting {}


/// Collection of methods which ``InboxInteractor`` can invoke, 
/// to present data on ``InboxViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``InboxViewController``.
///
/// The `Presentable` protocol bridges between ``InboxInteractor`` and 
/// ``InboxViewController``, to enable business logic to navigate the UI.
protocol InboxPresentable: Presentable {
    var presentableListener: InboxPresentableListener? { get set }
}


/// Collection of methods which ``InboxInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``InboxInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``InboxInteractor``.
protocol InboxListener: AnyObject {}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class InboxInteractor: PresentableInteractor<InboxPresentable>, InboxInteractable, InboxPresentableListener {
    
    
    /// The reference to the Router where self resides on.
    weak var router: InboxRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: InboxListener?
    
    
    // TODO: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init (presenter: InboxPresentable) {
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
