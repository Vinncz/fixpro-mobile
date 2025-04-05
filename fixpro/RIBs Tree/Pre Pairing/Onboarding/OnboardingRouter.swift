import RIBs


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``OnboardingInteractor`` (internal use).
/// 
/// Conform this protocol to other RIBs' `Listener` protocols, to mark ``OnboardingInteractor`` 
/// as able to receive and will handle events coming from its descendants. 
protocol OnboardingInteractable: Interactable,
                                 PairListener,
                                 InformationListener
{
    var router  : OnboardingRouting? { get set }
    var listener: OnboardingListener? { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `OnboardingRIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``OnboardingRouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``OnboardingRouter`` that manipulates 
/// the view its controlling.
protocol OnboardingViewControllable: ViewControllable {
    func present(_ flow: ViewControllable)
    func dismiss(_ flow: ViewControllable)
}


/// Manages the UI of `OnboardingRIB` and relation with another RIB.
final class OnboardingRouter: ViewableRouter<OnboardingInteractable, OnboardingViewControllable> {
    
    private let informationBuilder: InformationBuildable
    private let pairBuilder: PairBuildable
    
    private var informationRouting: InformationRouting? = nil
    private var pairRouting: PairRouting? = nil
    
    init (
        interactor: OnboardingInteractable, 
        viewController: OnboardingViewControllable,
        informationBuilder: InformationBuildable,
        pairBuilder: PairBuildable
    ) {
        self.informationBuilder = informationBuilder
        self.pairBuilder = pairBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad () {
        super.didLoad()
    }
    
}

extension OnboardingRouter: OnboardingRouting {
    
    
    // MARK: -- Pairing Flow
    func attachPairingFlow () {
        let pairRouting = pairBuilder.build(withListener: self.interactor)
        self.pairRouting = pairRouting
        
        self.attachChild(pairRouting)
        self.viewController.present(pairRouting.viewControllable)
        
        FPLogger.log("Attached PairingRIB")
    }
    
    func detachPairingFlow () {
        guard let pairRouting else { return }
        
        self.viewController.dismiss(pairRouting.viewControllable)
        self.detachChild(pairRouting)
        self.pairRouting = nil
        
        FPLogger.log("Detached PairingRIB")
    }
    
    
    // MARK: -- InformationFlow
    /// Attaches the InfromationRIB that tells about this current build, that's triggered upon tapping the
    /// information button on the top right corner of the screen.
    func attachInformationFlow () {
        let informationRouting = informationBuilder.build(withListener: self.interactor)
        self.informationRouting = informationRouting
        
        self.attachChild(informationRouting)
        self.viewController.present(informationRouting.viewControllable)
        
        FPLogger.log("Attached InformationRIB")
    }
    
    /// Detaches the InformationRIB that tells us about this current build, 
    /// that's triggered by dismissing the sheet.
    func detachInformationFlow () {
        guard let informationRouting else { return }
        
        self.viewController.dismiss(informationRouting.viewControllable)
        self.detachChild(informationRouting)
        self.informationRouting = nil
        
        FPLogger.log("Detached InformationRIB")
    }
    
}
