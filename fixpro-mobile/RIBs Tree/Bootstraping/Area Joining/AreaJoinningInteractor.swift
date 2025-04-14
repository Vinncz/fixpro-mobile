import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``AreaJoinningRouter``, listing the attributes and/or actions 
/// that ``AreaJoinningInteractor`` is allowed to access or invoke.
protocol AreaJoinningRouting: ViewableRouting {
    func walkBackFromCodeScan()
    func stepToEntryRequestForm(withFieldsOf: [String])
    func walkBackFromEntryRequestForm()
    func stepToPostSignupCTA()
    func dismissPostSignupCTAFlow()
}



/// Contract adhered to by ``AreaJoinningViewController``, listing the attributes and/or actions
/// that ``AreaJoinningInteractor`` is allowed to access or invoke.
protocol AreaJoinningPresentable: Presentable {
    
    
    /// Reference to ``AreaJoinningInteractor``.
    var presentableListener: AreaJoinningPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `AreaJoinningRIB`'s parent, listing the attributes and/or actions
/// that ``AreaJoinningInteractor`` is allowed to access or invoke.
protocol AreaJoinningListener: AnyObject {
    func didFinishPairing()
    func didNotPair()
}



/// The functionality centre of `AreaJoinningRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaJoinningInteractor: PresentableInteractor<AreaJoinningPresentable>, AreaJoinningInteractable {
    
    
    /// Reference to ``AreaJoinningRouter``.
    weak var router: AreaJoinningRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaJoinningListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaJoinningComponent
    
    
    /// Constructs an instance of ``AreaJoinningInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaJoinningComponent) {
        self.component = component
        let presenter = component.areaJoinningViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
    }
    
    
    /// Customization point that is invoked before self is detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
}



extension AreaJoinningInteractor {
    
    
    func didContactAreaForTheirEntryForm(andCameUpWithTheFollowingFields fields: [String]) {
        router?.stepToEntryRequestForm(withFieldsOf: fields)
    }
    
    
    func exitScanningCodes() {
        VULogger.log(tag: .warning, "Did cancel scanning codes")
        router?.walkBackFromCodeScan()
        listener?.didNotPair()
    }
    
}



extension AreaJoinningInteractor {
    
    
    func didFinishFillingOutTheFormAndSubmittedItWhileAlsoSavedPairingInformationToPairingService() {
        VULogger.log(tag: .success, "Did filled out the form, and is continuing to CTA")
        
        router?.stepToPostSignupCTA()
    }
    
    
    func didChooseToGoBackToScanningCodes() {
        VULogger.log(tag: .warning, "Went back to scanning codes")
        router?.walkBackFromEntryRequestForm()
    }
    
}



extension AreaJoinningInteractor {
    
    
    func didFinishPairing(isImmidiatelyAccepted: Bool) {
        VULogger.log(tag: .success, "Finished pairing")
        listener?.didFinishPairing()
        router?.dismissPostSignupCTAFlow()
    }
    
}



/// Conformance to the ``AreaJoinningPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningViewController``
extension AreaJoinningInteractor: AreaJoinningPresentableListener {}
