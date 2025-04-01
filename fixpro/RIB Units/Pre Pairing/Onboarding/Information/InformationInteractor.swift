import RIBs
import RxSwift


/// Collection of methods which ``InformationInteractor`` can invoke, 
/// to perform something on its enclosing router (``InformationRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``InformationRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``InformationInteractor`` and
/// ``InformationRouter``, to enable business logic to manipulate the UI.
protocol InformationRouting: ViewableRouting {}


/// Collection of methods which ``InformationInteractor`` can invoke, 
/// to present data on ``InformationViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``InformationViewController``.
///
/// The `Presentable` protocol bridges between ``InformationInteractor`` and 
/// ``InformationViewController``, to enable business logic to navigate the UI.
protocol InformationPresentable: Presentable {
    var presentableListener: InformationPresentableListener? { get set }
}


/// Collection of methods which ``InformationInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``InformationInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``InformationInteractor``.
protocol InformationListener: AnyObject {
    func didDissapear()
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class InformationInteractor: PresentableInteractor<InformationPresentable>, InformationInteractable {
    
    
    /// The reference to the Router where self resides on.
    weak var router: InformationRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: InformationListener?
    
    
    // TODO: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init (presenter: InformationPresentable) {
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

extension InformationInteractor: InformationPresentableListener {
    
    func didDissapear() {
        listener?.didDissapear()
    }
    
}
