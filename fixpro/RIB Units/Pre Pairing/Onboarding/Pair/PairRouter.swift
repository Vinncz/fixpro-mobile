import RIBs
import UIKit


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``PairInteractor`` (internal use).
/// 
/// Conform this protocol to other RIBs' `Listener` protocols, to mark ``PairInteractor`` 
/// as able to receive and will handle events coming from its descendants. 
protocol PairInteractable: Interactable,
                           CodeScanListener,
                           EntryRequestFormListener,
                           PostSignupCTAListener
{
    var router  : PairRouting? { get set }
    var listener: PairListener? { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `PairRIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``PairRouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``PairRouter`` that manipulates 
/// the view its controlling.
protocol PairViewControllable: ViewControllable {}


/// Manages the UI of `PairRIB` and relation with another RIB.
final class PairRouter: ViewableRouter<PairInteractable, PairViewControllable> {
    
    private let codeScanBuilder: CodeScanBuildable
    private let entryRequestFormBuilder: EntryRequestFormBuildable
    private let postSignupCTABuilder: PostSignupCTABuildable
    
    private var codeScanRouting: CodeScanRouting? = nil
    private var entryRequestFormRouting: EntryRequestFormRouting? = nil
    private var postSignupCTARouting: PostSignupCTARouting? = nil
    
    private var activeStep: Routing? = nil
    
    init (
        interactor    : PairInteractable, 
        viewController: PairViewControllable,
        codeScanBuilder: CodeScanBuildable,
        entryRequestFormBuilder: EntryRequestFormBuildable,
        postSignupCTABuilder: PostSignupCTABuildable
    ) {
        self.codeScanBuilder = codeScanBuilder
        self.entryRequestFormBuilder = entryRequestFormBuilder
        self.postSignupCTABuilder = postSignupCTABuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad() {
        super.didLoad()
        stepToCodeScan()
    }
    
    private func stepToCodeScan () {
        let codeScanRouting = codeScanBuilder.build(withListener: self.interactor)
        self.codeScanRouting = codeScanRouting
        
        attachChild(codeScanRouting)
        guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
        navcon.pushViewController(codeScanRouting.viewControllable.uiviewController, animated: true)
        
        FPLogger.log("Attached CodeScanRIB")
    }
    
}

extension PairRouter: PairRouting {
    
    // MARK: -- Code Scan Flow
    func walkBackFromCodeScan () {
        guard let codeScanRouting else { return }
        self.detachChild(codeScanRouting)
        self.codeScanRouting = nil
        
        guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
        navcon.setViewControllers([], animated: true)
        
        FPLogger.log("Detached CodeScanRIB")
    }
    
    
    // MARK: -- Entry Request Form Flow
    func stepToEntryRequestForm (withDigestOf: AreaJoinCode) {
        guard entryRequestFormRouting == nil else { return }
        
        let entryRequestFormRouting = entryRequestFormBuilder.build(withListener: self.interactor)
        self.entryRequestFormRouting = entryRequestFormRouting
        
        attachChild(entryRequestFormRouting)
        guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
        navcon.pushViewController(entryRequestFormRouting.viewControllable.uiviewController, animated: true)
        
        FPLogger.log("Attached EntryRequestFormRIB")
    }
    
    func walkBackFromEntryRequestForm () {
        guard let entryRequestFormRouting else { return }
        guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
        navcon.popToRootViewController(animated: true)
        
        self.detachChild(entryRequestFormRouting)
        self.entryRequestFormRouting = nil
        
        FPLogger.log("Detached EntryRequestFormRIB")
    }
    
    
    // MARK: -- Post Signup CTA Flow
    func stepToPostSignupCTA(isImmidiatelyAccepted: Bool) {
        let postSignupCTARouting = postSignupCTABuilder.build(withListener: self.interactor, isImmidiatelyAccepted: isImmidiatelyAccepted)
        self.postSignupCTARouting = postSignupCTARouting
        
        attachChild(postSignupCTARouting)
        guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
        navcon.pushViewController(postSignupCTARouting.viewControllable.uiviewController, animated: true)
        
        FPLogger.log("Attached PostSignupCTARIB")
    }
    
    func dismissPostSignupCTAFlow() {
        guard let postSignupCTARouting else { return }
        self.detachChild(postSignupCTARouting)
        self.postSignupCTARouting = nil
        
        guard let navcon = self.viewController.uiviewController as? UINavigationController else { return }
        navcon.setViewControllers([], animated: false)
        
        FPLogger.log("Detached PostSignupCTARIB")
    }
    
}
