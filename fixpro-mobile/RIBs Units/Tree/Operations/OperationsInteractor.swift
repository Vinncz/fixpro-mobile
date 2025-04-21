import RIBs
import RxSwift
import UIKit
import VinUtility
import FirebaseMessaging



/// Contract adhered to by ``OperationsRouter``, listing the attributes and/or actions 
/// that ``OperationsInteractor`` is allowed to access or invoke.
protocol OperationsRouting: ViewableRouting {
    func routeToRoleAppropriation(fromNotification: FPNotificationDigest?)
}



/// Contract adhered to by ``OperationsViewController``, listing the attributes and/or actions
/// that ``OperationsInteractor`` is allowed to access or invoke.
protocol OperationsPresentable: Presentable {
    
    
    /// Reference to ``OperationsInteractor``.
    var presentableListener: OperationsPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: OperationsSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `OperationsRIB`'s parent, listing the attributes and/or actions
/// that ``OperationsInteractor`` is allowed to access or invoke.
protocol OperationsListener: AnyObject {
    func didLogOut()
}



/// The functionality centre of `OperationsRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class OperationsInteractor: PresentableInteractor<OperationsPresentable>, OperationsInteractable {
    
    
    /// Reference to ``OperationsRouter``.
    weak var router: OperationsRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: OperationsListener?
    
    
    /// Reference to the component of this RIB.
    var component: OperationsComponent
    
    
    /// Bridge to the ``OperationsSwiftUIVIew``.
    private var viewModel = OperationsSwiftUIViewModel()
    
    
    /// Others.
    var triggerNotification: FPNotificationDigest?
    
    
    /// Constructs an instance of ``OperationsInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: OperationsComponent, triggerNotification: FPNotificationDigest?) {
        self.component = component
        self.triggerNotification = triggerNotification
        let presenter = component.operationsViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        configureViewModel()
        
        performLaunchBootstrapping()
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        presenter.bind(viewModel: self.viewModel)
    }
    
    
    fileprivate func performLaunchBootstrapping() {
        Task {
            self.viewModel.state = .normal("Establishing connection with Area..")
            
            let accessTokenExpiryDate = await self.component.sessionIdentityService.accessTokenExpirationDate!
            if accessTokenExpiryDate < .now.addingTimeInterval(1800) {
                do {
                    try await self.component.sessionidentityServiceUpkeeper.renew()
                    
                } catch let error as FPError {
                    self.viewModel.state = .failure("\(error.errorDescription ?? "") \(error.recoverySuggestion ?? "")", "Try again") {
                        self.performLaunchBootstrapping()
                    }
                    
                    return
                }
            }
            
            router?.routeToRoleAppropriation(fromNotification: triggerNotification)
        }
    }
    
}



/// Conformance to the ``OperationsPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``OperationsViewController``.
extension OperationsInteractor: OperationsPresentableListener {}
