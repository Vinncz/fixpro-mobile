import RIBs
import UIKit


/// The `Interactable` protocol declares that all `Interactor` classes
/// can communicate with its enclosing `Router` and its parent's `Interactor`.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to 
/// ``RoleAppropriationInteractor`` (internal use).
/// 
/// Conform this protocol to other RIBs' `Listener` protocols, to mark ``RoleAppropriationInteractor`` 
/// as able to receive and will handle events coming from its descendants. 
protocol RoleAppropriationInteractable: Interactable,
                                        MemberScopedListener,
                                        CrewScopedListener,
                                        ManagementScopedListener
{
    var router  : RoleAppropriationRouting? { get set }
    var listener: RoleAppropriationListener? { get set }
}


/// Collection of methods which allow for view manipulation without exposing UIKit.
/// 
/// This protocol may be used externally of `RoleAppropriationRIB`.
/// 
/// By conforming some `ViewController` to this, you allow for them 
/// to be manipulated by ``RoleAppropriationRouter``.
/// 
/// By conforming this RIB's descendant's `Router` to this, 
/// you declare that said `Router` will bridge out ny interactions 
/// coming from ``RoleAppropriationRouter`` that manipulates 
/// the view its controlling.
protocol RoleAppropriationViewControllable: ViewControllable {}


/// Manages the UI of `RoleAppropriationRIB` and relation with another RIB.
final class RoleAppropriationRouter: Router<RoleAppropriationInteractable> {
    
    private let memberScopeBuilder: MemberScopedBuildable
    private let maintenanceCrewScopeBuilder: CrewScopedBuildable
    private let managementScopeBuilder: ManagementScopedBuildable
    
    private var activeRouting: ViewableRouting? = nil
    private var memberScopeRouting: MemberScopedRouting? = nil
    private var maintenanceCrewScopeRouting: CrewScopedRouting? = nil
    private var managementScopeRouting: ManagementScopedRouting? = nil
    
    private var parentViewControllable: RoleAppropriationViewControllable?
    
    init (
        interactor: RoleAppropriationInteractable, 
        viewController: RoleAppropriationViewControllable,
        memberScopeBuilder: MemberScopedBuildable,
        maintenanceCrewScopeBuilder: CrewScopedBuildable,
        managementScopeBuilder: ManagementScopedBuildable
    ) {
        self.parentViewControllable = viewController
        self.memberScopeBuilder = memberScopeBuilder
        self.maintenanceCrewScopeBuilder = maintenanceCrewScopeBuilder
        self.managementScopeBuilder = managementScopeBuilder
        
        super.init(interactor: interactor)
        interactor.router = self
    }
    
    func cleanupViews () {
        if let activeRouting {
            self.detachChild(activeRouting)
            self.activeRouting = nil
        }
    }
    
}

extension RoleAppropriationRouter: RoleAppropriationRouting {
    
    
    /// 
    func attachMemberFlow() {
        FPLogger.log("Attached memberScopeRouting")
        let memberScopeRouting = memberScopeBuilder.build(withListener: self.interactor)
        self.activeRouting = memberScopeRouting
        self.memberScopeRouting = memberScopeRouting
        
        self.attachChild(memberScopeRouting)
        (self.parentViewControllable?.uiviewController as? RootViewControllable)?.transitionFlow(to: memberScopeRouting.viewControllable)
    }
    
    
    ///
    func attachMaintenanceCrewFlow() {
        FPLogger.log("Attached crewRouting")
        let crewRouting = maintenanceCrewScopeBuilder.build(withListener: self.interactor)
        self.activeRouting = crewRouting
        self.maintenanceCrewScopeRouting = crewRouting
        
        self.attachChild(crewRouting)
        (self.parentViewControllable?.uiviewController as? RootViewControllable)?.transitionFlow(to: crewRouting.viewControllable)
    }
    
    
    /// 
    func attachManagementFlow() {
        FPLogger.log("Attached managementRouting")
        let managementRouting = managementScopeBuilder.build(withListener: self.interactor)
        self.activeRouting = managementRouting
        self.managementScopeRouting = managementRouting
        
        self.attachChild(managementRouting)
        (self.parentViewControllable?.uiviewController as? RootViewControllable)?.transitionFlow(to: managementRouting.viewControllable)
    }
    
    
    /// 
    func detachAnyFlow() {
        guard let activeRouting else { return }
        FPLogger.log("Detached any flow")
        
        switch activeRouting {
            case is MemberScopedRouting:
                memberScopeRouting = nil
            case is CrewScopedRouting:
                maintenanceCrewScopeRouting = nil
            case is ManagementScopedRouting:
                managementScopeRouting = nil
            default:
                break
        }
        
        self.detachChild(activeRouting)
        self.activeRouting = nil
    }
    
}
