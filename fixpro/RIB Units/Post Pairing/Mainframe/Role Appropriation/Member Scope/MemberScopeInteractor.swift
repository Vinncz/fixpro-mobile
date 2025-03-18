import RIBs
import RxSwift


/// Collection of methods which ``MemberScopeInteractor`` can invoke, 
/// to perform something on its enclosing router (``MemberScopeRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``MemberScopeRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``MemberScopeInteractor`` and
/// ``MemberScopeRouter``, to enable business logic to manipulate the UI.
protocol MemberScopeRouting: ViewableRouting {}


/// Collection of methods which ``MemberScopeInteractor`` can invoke, 
/// to present data on ``MemberScopeViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``MemberScopeViewController``.
///
/// The `Presentable` protocol bridges between ``MemberScopeInteractor`` and 
/// ``MemberScopeViewController``, to enable business logic to navigate the UI.
protocol MemberScopePresentable: Presentable {
    var presentableListener: MemberScopePresentableListener? { get set }
}


/// Collection of methods which ``MemberScopeInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``MemberScopeInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``MemberScopeInteractor``.
protocol MemberScopeListener: AnyObject {}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class MemberScopeInteractor: PresentableInteractor<MemberScopePresentable>, MemberScopeInteractable, MemberScopePresentableListener {
    
    
    /// The reference to the Router where self resides on.
    weak var router: MemberScopeRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: MemberScopeListener?
    
    
    // TODO: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init (presenter: MemberScopePresentable) {
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
