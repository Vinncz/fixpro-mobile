import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``OperationsRouter``, listing the attributes and/or actions 
/// that ``OperationsInteractor`` is allowed to access or invoke.
protocol OperationsRouting: Routing {
    func routeToRoleAppropriation()
}



/// Contract adhered to by the Interactor of `OperationsRIB`'s parent, listing the attributes and/or actions
/// that ``OperationsInteractor`` is allowed to access or invoke.
protocol OperationsListener: AnyObject {
    func didLogOut()
}



/// The functionality centre of `OperationsRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class OperationsInteractor: Interactor, OperationsInteractable {
    
    
    /// Reference to ``OperationsRouter``.
    weak var router: OperationsRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: OperationsListener?
    
    
    /// Reference to the component of this RIB.
    var component: OperationsComponent
    
    
    /// Constructs an instance of ``OperationsInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: OperationsComponent) {
        self.component = component
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        
        Task {
            switch await component.sessionIdentityService.refreshAccessToken() {
                case .success:
                    router?.routeToRoleAppropriation()
                    
                case .failure(let error):
                    VULogger.log(tag: .critical, "Failed to refresh access token: \(error)")
                    
                    // TODO: Show something that indicate refresh failure.
            }
        }
    }
    
    
    /// Customization point that is invoked before self is detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
}
