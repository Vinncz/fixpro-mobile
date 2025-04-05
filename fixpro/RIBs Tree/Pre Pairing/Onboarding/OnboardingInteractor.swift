import RIBs
import RxSwift


/// Collection of methods which ``OnboardingInteractor`` can invoke, 
/// to perform something on its enclosing router (``OnboardingRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``OnboardingRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``OnboardingInteractor`` and
/// ``OnboardingRouter``, to enable business logic to manipulate the UI.
protocol OnboardingRouting: ViewableRouting {
    func attachPairingFlow()
    func detachPairingFlow()
    func attachInformationFlow()
    func detachInformationFlow()
}


/// Collection of methods which ``OnboardingInteractor`` can invoke, 
/// to present data on ``OnboardingViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``OnboardingViewController``.
///
/// The `Presentable` protocol bridges between ``OnboardingInteractor`` and 
/// ``OnboardingViewController``, to enable business logic to navigate the UI.
protocol OnboardingPresentable: Presentable {
    var presentableListener: OnboardingPresentableListener? { get set }
}


/// Collection of methods which ``OnboardingInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``OnboardingInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``OnboardingInteractor``.
protocol OnboardingListener: AnyObject {
    func didFinishPairingAndRequestingChangeOfFlowToPostPairing()
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class OnboardingInteractor: PresentableInteractor<OnboardingPresentable>, OnboardingInteractable {
    
    
    /// The reference to the Router where self resides on.
    weak var router: OnboardingRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: OnboardingListener?
    
    
    override init (presenter: OnboardingPresentable) {
        super.init(presenter: presenter)
        presenter.presentableListener = self
    }
    
    
    func didDissapear() {
        router?.detachInformationFlow()
    }
    
}


extension OnboardingInteractor: OnboardingPresentableListener {
    
    
    // MARK: -- Conformance to PresentableListener
    func quePairingFlow () {
        router?.attachPairingFlow()
    }
    
    func queInformationFlow() {
        router?.attachInformationFlow()
    }
    
    
    // MARK: -- Conformance to Listener
    func didFinishPairing(isImmidiatelyAccepted: Bool) {
        router?.detachPairingFlow()
        
        if isImmidiatelyAccepted {
            listener?.didFinishPairingAndRequestingChangeOfFlowToPostPairing()
            return
        }
        
        // refresh the onboarding view to see its status
    }
    
    func didNotPair() {
        router?.detachPairingFlow()
    }
    
}
