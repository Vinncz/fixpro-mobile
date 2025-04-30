import RIBs
import RxSwift



/// Contract adhered to by ``AreaManagementRouter``, listing the attributes and/or actions 
/// that ``AreaManagementInteractor`` is allowed to access or invoke.
protocol AreaManagementRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``AreaManagementViewController``, listing the attributes and/or actions
/// that ``AreaManagementInteractor`` is allowed to access or invoke.
protocol AreaManagementPresentable: Presentable {
    
    
    /// Reference to ``AreaManagementInteractor``.
    var presentableListener: AreaManagementPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: AreaManagementSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `AreaManagementRIB`'s parent, listing the attributes and/or actions
/// that ``AreaManagementInteractor`` is allowed to access or invoke.
protocol AreaManagementListener: AnyObject {}



/// The functionality centre of `AreaManagementRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaManagementInteractor: PresentableInteractor<AreaManagementPresentable>, AreaManagementInteractable {
    
    
    /// Reference to ``AreaManagementRouter``.
    weak var router: AreaManagementRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaManagementListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaManagementComponent
    
    
    /// Bridge to the ``AreaManagementSwiftUIVIew``.
    private var viewModel = AreaManagementSwiftUIViewModel()
    
    
    /// Constructs an instance of ``AreaManagementInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaManagementComponent) {
        self.component = component
        let presenter = component.areaManagementViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        configureViewModel()
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
        presenter.unbindViewModel()
        router?.clearViewControllers()
        router?.detachSwiftUI()
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        viewModel.joinPolicy = .OPEN
        viewModel.didUpdateJoinPolicy = { [weak self] newPolicy in
            self?.viewModel.joinPolicy = newPolicy
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``AreaManagementPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaManagementViewController``.
extension AreaManagementInteractor: AreaManagementPresentableListener {}
