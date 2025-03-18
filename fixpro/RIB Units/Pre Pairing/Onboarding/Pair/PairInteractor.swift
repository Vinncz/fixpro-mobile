import RIBs
import RxSwift


/// Collection of methods which ``PairInteractor`` can invoke, 
/// to perform something on its enclosing router (``PairRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``PairRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``PairInteractor`` and
/// ``PairRouter``, to enable business logic to manipulate the UI.
protocol PairRouting: ViewableRouting {
    func walkBackFromCodeScan()
    func stepToEntryRequestForm(withDigestOf: AreaJoinCode)
    func walkBackFromEntryRequestForm()
    func stepToPostSignupCTA(isImmidiatelyAccepted: Bool)
    func dismissPostSignupCTAFlow()
}


/// Collection of methods which ``PairInteractor`` can invoke, 
/// to present data on ``PairViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``PairViewController``.
///
/// The `Presentable` protocol bridges between ``PairInteractor`` and 
/// ``PairViewController``, to enable business logic to navigate the UI.
protocol PairPresentable: Presentable {
    var presentableListener: PairPresentableListener? { get set }
}


/// Collection of methods which ``PairInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``PairInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``PairInteractor``.
protocol PairListener: AnyObject {
    func didFinishPairing(isImmidiatelyAccepted: Bool)
    func didNotPair()
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class PairInteractor: PresentableInteractor<PairPresentable> {
    
    
    /// The reference to the Router where self resides on.
    weak var router: PairRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: PairListener?
    
    
    override init(presenter: PairPresentable) {
        super.init(presenter: presenter)
        presenter.presentableListener = self
    }
    
}


extension PairInteractor: PairInteractable {
    
    // MARK: -- Code Scan RIB
    func didScanAreaJoinCode(withDigestOf ajc: AreaJoinCode) {
        FPLogger.log(tag: .success, "Did scan codes")
        // checks
        // if all green, continue to Entry Request Form
        router?.stepToEntryRequestForm(withDigestOf: ajc)
    }
    
    func didCancelScanningCodes() {
        FPLogger.log(tag: .warning, "Did cancel scanning codes")
        router?.walkBackFromCodeScan()
        listener?.didNotPair()
    }
    
    
    // MARK: -- Entry Request Form RIB
    func didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf: EntryRequestFormFillout) {
        FPLogger.log(tag: .success, "Did filled out the form, and is continuing to CTA")
        router?.stepToPostSignupCTA(isImmidiatelyAccepted: true)
    }
    
    func didChooseToGoBackToScanningCodes() {
        FPLogger.log(tag: .warning, "Went back to scanning codes")
        router?.walkBackFromEntryRequestForm()
    }
    
    
    // MARK: -- Post Signup CTA RIB
    func didFinishPairing(isImmidiatelyAccepted: Bool) {
        FPLogger.log(tag: .success, "Finished pairing")
        listener?.didFinishPairing(isImmidiatelyAccepted: isImmidiatelyAccepted)
        router?.dismissPostSignupCTAFlow()
    }
    
}


extension PairInteractor: PairPresentableListener {
    
    
    
}
