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
                                        MemberScopeListener,
                                        MaintenanceCrewScopeListener,
                                        ManagementTeamScopeListener
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
    
    private let memberScopeBuilder: MemberScopeBuildable
    private let maintenanceCrewScopeBuilder: MaintenanceCrewScopeBuildable
    private let managementScopeBuilder: ManagementTeamScopeBuildable
    
    private var activeRouting: ViewableRouting? = nil
    private var memberScopeRouting: MemberScopeRouting? = nil
    private var maintenanceCrewScopeRouting: MaintenanceCrewScopeRouting? = nil
    private var managementScopeRouting: ManagementTeamScopeRouting? = nil
    
    private var parentViewControllable: RoleAppropriationViewControllable?
    
    init (
        interactor: RoleAppropriationInteractable, 
        viewController: RoleAppropriationViewControllable,
        memberScopeBuilder: MemberScopeBuildable,
        maintenanceCrewScopeBuilder: MaintenanceCrewScopeBuildable,
        managementScopeBuilder: ManagementTeamScopeBuildable
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
        let memberScopeRouting = memberScopeBuilder.build(withListener: self.interactor)
        self.activeRouting = memberScopeRouting
        self.memberScopeRouting = memberScopeRouting
        
        self.attachChild(memberScopeRouting)
        (self.parentViewControllable?.uiviewController as? RootViewControllable)?.transitionFlow(to: memberScopeRouting.viewControllable)
        FPLogger.log("Attached memberScopeRouting")
    }
    
    
    ///
    func attachMaintenanceCrewFlow() {
        let crewRouting = maintenanceCrewScopeBuilder.build(withListener: self.interactor)
        self.activeRouting = crewRouting
        self.maintenanceCrewScopeRouting = crewRouting
        
        self.attachChild(crewRouting)
        (self.parentViewControllable?.uiviewController as? RootViewControllable)?.transitionFlow(to: crewRouting.viewControllable)
        FPLogger.log("Attached crewRouting")
    }
    
    
    /// 
    func attachManagementFlow() {
        let managementRouting = managementScopeBuilder.build(withListener: self.interactor)
        self.activeRouting = managementRouting
        self.managementScopeRouting = managementRouting
        
        self.attachChild(managementRouting)
        (self.parentViewControllable?.uiviewController as? RootViewControllable)?.transitionFlow(to: managementRouting.viewControllable)
        FPLogger.log("Attached managementRouting")
    }
    
    
    /// 
    func detachAnyFlow() {
        guard let activeRouting else { return }
        switch activeRouting {
            case is MemberScopeRouting:
                memberScopeRouting = nil
            case is MaintenanceCrewScopeRouting:
                maintenanceCrewScopeRouting = nil
            case is ManagementTeamScopeRouting:
                managementScopeRouting = nil
            default:
                break
        }
        
        self.detachChild(activeRouting)
        self.activeRouting = nil
    }
    
}
