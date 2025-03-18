import RIBs
import RxSwift


/// Collection of methods which ``EntryRequestFormInteractor`` can invoke, 
/// to perform something on its enclosing router (``EntryRequestFormRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``EntryRequestFormRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``EntryRequestFormInteractor`` and
/// ``EntryRequestFormRouter``, to enable business logic to manipulate the UI.
protocol EntryRequestFormRouting: ViewableRouting {}


/// Collection of methods which ``EntryRequestFormInteractor`` can invoke, 
/// to present data on ``EntryRequestFormViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``EntryRequestFormViewController``.
///
/// The `Presentable` protocol bridges between ``EntryRequestFormInteractor`` and 
/// ``EntryRequestFormViewController``, to enable business logic to navigate the UI.
protocol EntryRequestFormPresentable: Presentable {
    var presentableListener: EntryRequestFormPresentableListener? { get set }
}


/// Collection of methods which ``EntryRequestFormInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``EntryRequestFormInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``EntryRequestFormInteractor``.
protocol EntryRequestFormListener: AnyObject {
    func didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf: EntryRequestFormFillout)
    func didChooseToGoBackToScanningCodes()
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class EntryRequestFormInteractor: PresentableInteractor<EntryRequestFormPresentable>, EntryRequestFormInteractable {
    
    
    /// The reference to the Router where self resides on.
    weak var router: EntryRequestFormRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: EntryRequestFormListener?
    
    
    override init (presenter: EntryRequestFormPresentable) {
        super.init(presenter: presenter)
        presenter.presentableListener = self
    }
    
}


extension EntryRequestFormInteractor: EntryRequestFormPresentableListener {
    
    func didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf answer: EntryRequestFormFillout) {
        listener?.didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf: answer)
    }
    
    func didChooseToGoBackToScanningCodes() {
        listener?.didChooseToGoBackToScanningCodes()
    }
    
}
