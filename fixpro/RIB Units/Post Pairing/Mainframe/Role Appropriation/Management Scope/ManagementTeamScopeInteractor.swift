import RIBs
import RxSwift


/// Collection of methods which ``ManagementTeamScopeInteractor`` can invoke, 
/// to perform something on its enclosing router (``ManagementTeamScopeRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``ManagementTeamScopeRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``ManagementTeamScopeInteractor`` and
/// ``ManagementTeamScopeRouter``, to enable business logic to manipulate the UI.
protocol ManagementTeamScopeRouting: ViewableRouting {}


/// Collection of methods which ``ManagementTeamScopeInteractor`` can invoke, 
/// to present data on ``ManagementTeamScopeViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``ManagementTeamScopeViewController``.
///
/// The `Presentable` protocol bridges between ``ManagementTeamScopeInteractor`` and 
/// ``ManagementTeamScopeViewController``, to enable business logic to navigate the UI.
protocol ManagementTeamScopePresentable: Presentable {
    var presentableListener: ManagementTeamScopePresentableListener? { get set }
}


/// Collection of methods which ``ManagementTeamScopeInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``ManagementTeamScopeInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``ManagementTeamScopeInteractor``.
protocol ManagementTeamScopeListener: AnyObject {}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class ManagementTeamScopeInteractor: PresentableInteractor<ManagementTeamScopePresentable>, ManagementTeamScopeInteractable, ManagementTeamScopePresentableListener {
    
    
    /// The reference to the Router where self resides on.
    weak var router: ManagementTeamScopeRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: ManagementTeamScopeListener?
    
    
    // TODO: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init (presenter: ManagementTeamScopePresentable) {
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
