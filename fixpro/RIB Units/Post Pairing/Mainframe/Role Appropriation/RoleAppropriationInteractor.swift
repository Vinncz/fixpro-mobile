import RIBs
import RxSwift


/// Collection of methods which ``RoleAppropriationInteractor`` can invoke, 
/// to perform something on its enclosing router (``RoleAppropriationRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``RoleAppropriationRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``RoleAppropriationInteractor`` and
/// ``RoleAppropriationRouter``, to enable business logic to manipulate the UI.
protocol RoleAppropriationRouting: Routing {
    /// Detaches any views this RIB may have added to the hierarchy.
    /// 
    /// NEVER perform business logic here. It's exclusively for view management.
    func cleanupViews()
    func attachMemberFlow()
    func attachMaintenanceCrewFlow()
    func attachManagementFlow()
    func detachAnyFlow()
}


/// Collection of methods which ``RoleAppropriationInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``RoleAppropriationInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``RoleAppropriationInteractor``.
protocol RoleAppropriationListener: AnyObject {}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class RoleAppropriationInteractor: Interactor, RoleAppropriationInteractable {
    
    
    /// The reference to the Router where self resides on.
    weak var router: RoleAppropriationRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: RoleAppropriationListener?
    
    
    override init () {}
    
    
    /// Logics to perform after self becomes activated.
    override func didBecomeActive () {
        super.didBecomeActive()
        
        let myrole = determineRole()
        flowToRoutingWhichSuits(role: myrole)
    }
    
    
    /// Logics to perform after self is nudged to be deactivated.
    override func willResignActive () {
        super.willResignActive()
        
        router?.cleanupViews()
    }
    
}


/// 
extension RoleAppropriationInteractor {
    
    
    /// 
    func determineRole() -> Role {
        .member
    }
    
    
    /// 
    func flowToRoutingWhichSuits(role: Role) {
        switch role {
            case .member:
                router?.attachMemberFlow()
                break
            case .crew:
                router?.attachMaintenanceCrewFlow()
                break
            case .management:
                router?.attachManagementFlow()
                break
        }
    }
}


/// 
extension RoleAppropriationInteractor {
    
    
    /// 
    enum Role {
        case member
        case crew
        case management
    }
    
}
