import RIBs
import UIKit
import VinUtility



/// Contract adhered to by ``AreaJoinningInteractor``, listing the attributes and/or actions 
/// that ``AreaJoinningRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol AreaJoinningInteractable: Interactable, AreaJoinningCodeScanningListener, AreaJoinningFormFillingListener, AreaJoinningCTAShowingListener {
    
    
    /// Reference to ``AreaJoinningRouter``.
    var router: AreaJoinningRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: AreaJoinningListener? { get set }
    
}



/// Contract adhered to by ``AreaJoinningViewController``, listing the attributes and/or actions
/// that ``AreaJoinningRouter`` is allowed to access or invoke.
protocol AreaJoinningViewControllable: ViewControllable {}



/// The attachment point of `AreaJoinningRIB`.
final class AreaJoinningRouter: ViewableRouter<AreaJoinningInteractable, AreaJoinningViewControllable> {
    
    
    private let areaJoinningCodeScanningBuilder: AreaJoinningCodeScanningBuildable
    private var areaJoinningCodeScanningRouter: AreaJoinningCodeScanningRouting? = nil
    
    private let areaJoinningFormFillingBuilder: AreaJoinningFormFillingBuildable
    private var areaJoinningFormFillingRouter: AreaJoinningFormFillingRouting? = nil
    
    private let areaJoinningCTAShowingBuilder: AreaJoinningCTAShowingBuildable
    private var areaJoinningCTAShowingRouter: AreaJoinningCTAShowingRouting? = nil
    
    
    private var activeStep: Routing? = nil
    
    
    /// Constructs an instance of ``AreaJoinningRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(
        interactor: AreaJoinningInteractable, 
        viewController: AreaJoinningViewControllable,
        areaJoinningCodeScanningBuilder: AreaJoinningCodeScanningBuildable,
        areaJoinningFormFillingBuilder: AreaJoinningFormFillingBuildable,
        areaJoinningCTAShowingBuilder: AreaJoinningCTAShowingBuildable
    ) {
        self.areaJoinningCodeScanningBuilder = areaJoinningCodeScanningBuilder
        self.areaJoinningFormFillingBuilder = areaJoinningFormFillingBuilder
        self.areaJoinningCTAShowingBuilder = areaJoinningCTAShowingBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    
    override func didLoad() {
        super.didLoad()
        stepToCodeScan()
    }
    
    
    private func stepToCodeScan () {
        let areaJoinningCodeScanningRouter = areaJoinningCodeScanningBuilder.build(withListener: self.interactor)
        self.areaJoinningCodeScanningRouter = areaJoinningCodeScanningRouter
        
        attachChild(areaJoinningCodeScanningRouter)
        guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
        navcon.pushViewController(areaJoinningCodeScanningRouter.viewControllable.uiviewController, animated: true)
        
        VULogger.log("Attached CodeScanRIB")
    }
    
}



/// Conformance extension to the ``AreaJoinningRouting`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningInteractor``
extension AreaJoinningRouter: AreaJoinningRouting {
    
    
    // MARK: -- Code Scan Flow
    func walkBackFromCodeScan () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            guard let areaJoinningCodeScanningRouter else { return }
            self.detachChild(areaJoinningCodeScanningRouter)
            self.areaJoinningCodeScanningRouter = nil
            
            guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
            navcon.setViewControllers([], animated: true)
            
            VULogger.log("Detached CodeScanRIB")
        }
    }
    
    
    // MARK: -- Entry Request Form Flow
    func stepToEntryRequestForm (withFieldsOf fields: [String]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            guard areaJoinningFormFillingRouter == nil else { return }
            
            let areaJoinningFormFillingRouter = areaJoinningFormFillingBuilder.build(withListener: self.interactor, fields: fields)
            self.areaJoinningFormFillingRouter = areaJoinningFormFillingRouter
            
            attachChild(areaJoinningFormFillingRouter)
            guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
            navcon.pushViewController(areaJoinningFormFillingRouter.viewControllable.uiviewController, animated: true)
            
            VULogger.log("Attached EntryRequestFormRIB")
        }
    }
    
    func walkBackFromEntryRequestForm () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            guard let areaJoinningFormFillingRouter else { return }
            guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
            navcon.popToRootViewController(animated: true)
            
            self.detachChild(areaJoinningFormFillingRouter)
            self.areaJoinningFormFillingRouter = nil
            
            VULogger.log("Detached EntryRequestFormRIB")
        }
    }
    
    
    // MARK: -- Post Signup CTA Flow
    func stepToPostSignupCTA() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let areaJoinningCTAShowingRouter = areaJoinningCTAShowingBuilder.build(withListener: self.interactor)
            self.areaJoinningCTAShowingRouter = areaJoinningCTAShowingRouter
            
            attachChild(areaJoinningCTAShowingRouter)
            guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
            navcon.pushViewController(areaJoinningCTAShowingRouter.viewControllable.uiviewController, animated: true)
            
            VULogger.log("Attached PostSignupCTARIB")
        }
    }
    
    func dismissPostSignupCTAFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            guard let areaJoinningCTAShowingRouter else { return }
            self.detachChild(areaJoinningCTAShowingRouter)
            self.areaJoinningCTAShowingRouter = nil
            
            guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
            navcon.setViewControllers([], animated: false)
            
            VULogger.log("Detached PostSignupCTARIB")
        }
    }
    
}
