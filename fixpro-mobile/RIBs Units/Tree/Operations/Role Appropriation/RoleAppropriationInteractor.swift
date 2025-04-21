import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``RoleAppropriationRouter``, listing the attributes and/or actions 
/// that ``RoleAppropriationInteractor`` is allowed to access or invoke.
protocol RoleAppropriationRouting: ViewableRouting {
    func provisionMemberScope(component: RoleAppropriationComponent)
    func provisionCrewScope(component: RoleAppropriationComponent)
    func provisionManagementScope(component: RoleAppropriationComponent)
}



/// Contract adhered to by ``RoleAppropriationViewController``, listing the attributes and/or actions
/// that ``RoleAppropriationInteractor`` is allowed to access or invoke.
protocol RoleAppropriationPresentable: Presentable {
    
    
    /// Reference to ``RoleAppropriationInteractor``.
    var presentableListener: RoleAppropriationPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `RoleAppropriationRIB`'s parent, listing the attributes and/or actions
/// that ``RoleAppropriationInteractor`` is allowed to access or invoke.
protocol RoleAppropriationListener: AnyObject {}



/// The functionality centre of `RoleAppropriationRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class RoleAppropriationInteractor: PresentableInteractor<RoleAppropriationPresentable>, RoleAppropriationInteractable {
    
    
    /// Reference to ``RoleAppropriationRouter``.
    weak var router: RoleAppropriationRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: RoleAppropriationListener?
    
    
    /// Reference to the component of this RIB.
    var component: RoleAppropriationComponent
    
    
    /// Constructs an instance of ``RoleAppropriationInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: RoleAppropriationComponent) {
        self.component = component
        let presenter = component.roleAppropriationViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        
        Task {
            switch await component.sessionIdentityService.role {
                case .Crew:
                    VULogger.log("Flowing to CrewScope")
                    router?.provisionCrewScope(component: component)
                case .Management:
                    VULogger.log("Flowing to ManagementScope")
                    router?.provisionManagementScope(component: component)
                case .Member:
                    VULogger.log("Flowing to MemberScope")
                    router?.provisionMemberScope(component: component)
            }
        }
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
}



/// Conformance to the ``RoleAppropriationPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``RoleAppropriationViewController``.
extension RoleAppropriationInteractor: RoleAppropriationPresentableListener {}
