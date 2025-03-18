import RIBs
import Foundation
import RxSwift


/// Collection of methods which ``RootInteractor`` can invoke, 
/// to perform something on its enclosing router (``RootRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``RootRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``RootInteractor`` and
/// ``RootRouter``, to enable business logic to manipulate the UI.
protocol RootRouting: ViewableRouting {
    func transitionToPairedFlow()
    func transitionToUnpairedFlow()
    func detachAnyFlow()
}


/// Collection of methods which ``RootInteractor`` can invoke, 
/// to present data on ``RootViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``RootViewController``.
///
/// The `Presentable` protocol bridges between ``RootInteractor`` and 
/// ``RootViewController``, to enable business logic to navigate the UI.
protocol RootPresentable: Presentable {
    var presentableListener: RootPresentableListener? { get set }
}


/// Collection of methods which ``RootInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``RootInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``RootInteractor``.
protocol RootListener: AnyObject {}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {
    
    
    /// The reference to the Router where self resides on.
    weak var router: RootRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: RootListener?
    
    
    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.presentableListener = self
    }
    
    
    override func didBecomeActive() {}
    
}


// MARK: -- Conformance to OnboardingListener
extension RootInteractor {
    
    func didFinishPairingAndRequestingChangeOfFlowToPostPairing () {
        router?.detachAnyFlow()
        router?.transitionToPairedFlow()
    }
    
}


// MARK: -- Conformance to MainframeListener
extension RootInteractor {
    
    func didUnpairAndRequestChangeOfFlowToOnboarding () {
        router?.detachAnyFlow()
        router?.transitionToUnpairedFlow()
    }
    
}
