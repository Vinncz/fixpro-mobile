import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``RoleAppropriationRouter``, listing the attributes and/or actions 
/// that ``RoleAppropriationInteractor`` is allowed to access or invoke.
protocol RoleAppropriationRouting: ViewableRouting {
    
    
    /// Cleanses the view hierarchy of any `ViewControllable` instances this RIB may have added.
    func cleanupViews()
    
    func provisionMemberScope(component: RoleAppropriationComponent, triggerNotification: FPNotificationDigest?)
    func provisionCrewScope(component: RoleAppropriationComponent, triggerNotification: FPNotificationDigest?)
    func provisionManagementScope(component: RoleAppropriationComponent, triggerNotification: FPNotificationDigest?)
}



/// Contract adhered to by ``RoleAppropriationViewController``, listing the attributes and/or actions
/// that ``RoleAppropriationInteractor`` is allowed to access or invoke.
protocol RoleAppropriationPresentable: Presentable {
    
    
    /// Reference to ``RoleAppropriationInteractor``.
    var presentableListener: RoleAppropriationPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `RoleAppropriationRIB`'s parent, listing the attributes and/or actions
/// that ``RoleAppropriationInteractor`` is allowed to access or invoke.
protocol RoleAppropriationListener: AnyObject {
    func didIntendToLogOut()
}



/// The functionality centre of `RoleAppropriationRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class RoleAppropriationInteractor: PresentableInteractor<RoleAppropriationPresentable>, RoleAppropriationInteractable {
    
    
    /// Reference to ``RoleAppropriationRouter``.
    weak var router: RoleAppropriationRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: RoleAppropriationListener?
    
    
    /// Reference to the component of this RIB.
    var component: RoleAppropriationComponent
    
    
    /// Others.
    var triggerNotification: FPNotificationDigest?
    
    
    /// Constructs an instance of ``RoleAppropriationInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: RoleAppropriationComponent, presenter: RoleAppropriationPresentable, triggerNotification: FPNotificationDigest?) {
        self.component = component
        self.triggerNotification = triggerNotification
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        
        Task { @MainActor in
            switch await component.sessionIdentityService.role {
            case .member:
                VULogger.log("Flowing to Member scope")
                router?.provisionMemberScope(component: component, triggerNotification: triggerNotification)
                
            case .crew:
                VULogger.log("Flowing to Crew scope")
                router?.provisionCrewScope(component: component, triggerNotification: triggerNotification)
                
            case .management:
                VULogger.log("Flowing to Management scope")
                router?.provisionManagementScope(component: component, triggerNotification: triggerNotification)
            }
        }
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
}



extension RoleAppropriationInteractor {
    
    
    func didIntendToLogOut() {
        router?.cleanupViews()
        listener?.didIntendToLogOut()
    }
    
}



/// Conformance to the ``RoleAppropriationPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``RoleAppropriationViewController``.
extension RoleAppropriationInteractor: RoleAppropriationPresentableListener {
    
    
    func didMockLogOut() {
        router?.cleanupViews()
        didIntendToLogOut()
    }
    
}
