import RIBs
import RxSwift


/// Collection of methods which ``PostSignupCTAInteractor`` can invoke, 
/// to perform something on its enclosing router (``PostSignupCTARouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``PostSignupCTARouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``PostSignupCTAInteractor`` and
/// ``PostSignupCTARouter``, to enable business logic to manipulate the UI.
protocol PostSignupCTARouting: ViewableRouting {}


/// Collection of methods which ``PostSignupCTAInteractor`` can invoke, 
/// to present data on ``PostSignupCTAViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``PostSignupCTAViewController``.
///
/// The `Presentable` protocol bridges between ``PostSignupCTAInteractor`` and 
/// ``PostSignupCTAViewController``, to enable business logic to navigate the UI.
protocol PostSignupCTAPresentable: Presentable {
    var presentableListener: PostSignupCTAPresentableListener? { get set }
}


/// Collection of methods which ``PostSignupCTAInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``PostSignupCTAInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``PostSignupCTAInteractor``.
protocol PostSignupCTAListener: AnyObject {
    func didFinishPairing(isImmidiatelyAccepted: Bool)
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class PostSignupCTAInteractor: PresentableInteractor<PostSignupCTAPresentable>, PostSignupCTAInteractable {
    
    
    /// The reference to the Router where self resides on.
    weak var router: PostSignupCTARouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: PostSignupCTAListener?
    
    
    var isImmidiatelyAccepted: Bool
    
    init (presenter: PostSignupCTAPresentable, isImmidiatelyAccepted: Bool) {
        self.isImmidiatelyAccepted = isImmidiatelyAccepted
        super.init(presenter: presenter)
        presenter.presentableListener = self
    }
    
}

extension PostSignupCTAInteractor: PostSignupCTAPresentableListener {
    
    func didFinishPairing() {
        listener?.didFinishPairing(isImmidiatelyAccepted: isImmidiatelyAccepted)
    }
    
}
