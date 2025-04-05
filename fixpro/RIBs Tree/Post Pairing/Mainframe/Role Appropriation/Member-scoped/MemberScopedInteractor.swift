import RIBs
import RxSwift


/// Collection of methods which ``MemberScopedInteractor`` can invoke, 
/// to perform something on its enclosing router (``MemberScopedRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``MemberScopedRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``MemberScopedInteractor`` and
/// ``MemberScopedRouter``, to enable business logic to manipulate the UI.
protocol MemberScopedRouting: ViewableRouting {}


/// Collection of methods which ``MemberScopedInteractor`` can invoke, 
/// to present data on ``MemberScopedViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``MemberScopedViewController``.
///
/// The `Presentable` protocol bridges between ``MemberScopedInteractor`` and 
/// ``MemberScopedViewController``, to enable business logic to navigate the UI.
protocol MemberScopedPresentable: Presentable {
    var presentableListener: MemberScopedPresentableListener? { get set }
}


/// Collection of methods which ``MemberScopedInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``MemberScopedInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``MemberScopedInteractor``.
protocol MemberScopedListener: AnyObject {}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class MemberScopedInteractor: PresentableInteractor<MemberScopedPresentable>, MemberScopedInteractable, MemberScopedPresentableListener {
    
    
    /// The reference to the Router where self resides on.
    weak var router: MemberScopedRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: MemberScopedListener?
    
    
    // TODO: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init (presenter: MemberScopedPresentable) {
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
