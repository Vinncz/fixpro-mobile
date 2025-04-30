import RIBs
import VinUtility
import RxSwift



/// Contract adhered to by ``ManagementRoleScopingRouter``, listing the attributes and/or actions 
/// that ``ManagementRoleScopingInteractor`` is allowed to access or invoke.
protocol ManagementRoleScopingRouting: ViewableRouting {
    var ticketNavigatorRouter: TicketNavigatorRouting? { get }
}



/// Contract adhered to by ``ManagementRoleScopingViewController``, listing the attributes and/or actions
/// that ``ManagementRoleScopingInteractor`` is allowed to access or invoke.
protocol ManagementRoleScopingPresentable: Presentable {
    
    
    /// Reference to ``ManagementRoleScopingInteractor``.
    var presentableListener: ManagementRoleScopingPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `ManagementRoleScopingRIB`'s parent, listing the attributes and/or actions
/// that ``ManagementRoleScopingInteractor`` is allowed to access or invoke.
protocol ManagementRoleScopingListener: AnyObject {
    func didIntendToLogOut()
}



/// The functionality centre of `ManagementRoleScopingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class ManagementRoleScopingInteractor: PresentableInteractor<ManagementRoleScopingPresentable>, ManagementRoleScopingInteractable {
    
    
    /// Reference to ``ManagementRoleScopingRouter``.
    weak var router: ManagementRoleScopingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: ManagementRoleScopingListener?
    
    
    /// Reference to the component of this RIB.
    var component: ManagementRoleScopingComponent
    
    
    /// Others.
    var triggerNotification: FPNotificationDigest?
    
    
    /// Constructs an instance of ``ManagementRoleScopingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: ManagementRoleScopingComponent, presenter: ManagementRoleScopingPresentable, triggerNotification: FPNotificationDigest?) {
        self.component = component
        self.triggerNotification = triggerNotification
        
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
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
}



extension ManagementRoleScopingInteractor {
    
    
    func didIntendToLogOut() {
        listener?.didIntendToLogOut()
    }
    
}



/// Conformance to the ``ManagementRoleScopingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``ManagementRoleScopingViewController``
extension ManagementRoleScopingInteractor: ManagementRoleScopingPresentableListener {}
