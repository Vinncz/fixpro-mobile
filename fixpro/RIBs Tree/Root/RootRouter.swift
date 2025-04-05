import RIBs


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``RootInteractor`` (internal use).
/// 
/// Conform this protocol to other RIBs' `Listener` protocols, to mark ``OnboardingInteractor`` 
/// as able to receive and will handle events coming from its descendants. 
protocol RootInteractable: Interactable,
                           MainframeListener,
                           OnboardingListener
{
    var router  : RootRouting? { get set }
    var listener: RootListener? { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `RootRIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``RootRouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``RootRouter`` that manipulates 
/// the view its controlling.
protocol RootViewControllable: ViewControllable {
    func transitionFlow (to: ViewControllable)
    func cleanupFlow (from: ViewControllable)
}


/// Manages the UI of `RootRIB` and relation with another RIB.
final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable> {
    
    private let mainframeBuilder : MainframeBuildable
    private let onboardingBuilder: OnboardingBuildable
    
    private var mainframeRouting : MainframeRouting?  = nil
    private var onboardingRouting: OnboardingRouting? = nil
    
    init (
        interactor    : RootInteractable, 
        viewController: RootViewControllable,
        mainframeBuilder: MainframeBuildable,
        onboardingBuilder: OnboardingBuildable
    ) {
        self.mainframeBuilder = mainframeBuilder
        self.onboardingBuilder = onboardingBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad () {
        super.didLoad()
        attachOnboarding()
    }
    
}

extension RootRouter: RootRouting {
    
    func transitionToPairedFlow () {
        FPLogger.log("Attached mainframeRouting")
        let mainframeRouting  = mainframeBuilder.build(withListener: self.interactor)
        self.mainframeRouting = mainframeRouting
        
        self.attachChild(mainframeRouting)
    }
    
    func transitionToUnpairedFlow () {
        FPLogger.log("Attached onboardingRouting")
        let onboardingRouting = onboardingBuilder.build(withListener: self.interactor)
        self.onboardingRouting = onboardingRouting
        
        self.attachChild(onboardingRouting)
    }
    
    func detachAnyFlow () {
        if let mainframeRouting {
            FPLogger.log("Detached mainframeRouting")
            self.detachChild(mainframeRouting)
            mainframeRouting.cleanupViews()
            self.mainframeRouting = nil
        }
        
        if let onboardingRouting {
            FPLogger.log("Detached onboardingRouting")
            self.detachChild(onboardingRouting)
            viewController.cleanupFlow(from: onboardingRouting.viewControllable)
            self.onboardingRouting = nil
        }
    }
    
}

extension RootRouter {
    
    func attachOnboarding () {
        let onboardingRouting  = onboardingBuilder.build(withListener: self.interactor)
        self.onboardingRouting = onboardingRouting
        
        attachChild(onboardingRouting)
        viewController.transitionFlow(to: onboardingRouting.viewControllable)
    }
    
    func attachMainframe () {
        let mainframeRouting  = mainframeBuilder.build(withListener: self.interactor)
        self.mainframeRouting = mainframeRouting
        
        attachChild(mainframeRouting)
    }
    
}
