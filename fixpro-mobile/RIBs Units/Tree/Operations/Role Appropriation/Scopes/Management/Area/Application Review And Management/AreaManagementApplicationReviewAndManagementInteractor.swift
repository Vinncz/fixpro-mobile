import RIBs
import RxSwift



/// Contract adhered to by ``AreaManagementApplicationReviewAndManagementRouter``, listing the attributes and/or actions 
/// that ``AreaManagementApplicationReviewAndManagementInteractor`` is allowed to access or invoke.
protocol AreaManagementApplicationReviewAndManagementRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``AreaManagementApplicationReviewAndManagementViewController``, listing the attributes and/or actions
/// that ``AreaManagementApplicationReviewAndManagementInteractor`` is allowed to access or invoke.
protocol AreaManagementApplicationReviewAndManagementPresentable: Presentable {
    
    
    /// Reference to ``AreaManagementApplicationReviewAndManagementInteractor``.
    var presentableListener: AreaManagementApplicationReviewAndManagementPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: AreaManagementApplicationReviewAndManagementSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `AreaManagementApplicationReviewAndManagementRIB`'s parent, listing the attributes and/or actions
/// that ``AreaManagementApplicationReviewAndManagementInteractor`` is allowed to access or invoke.
protocol AreaManagementApplicationReviewAndManagementListener: AnyObject {
    func navigateBack()
}



/// The functionality centre of `AreaManagementApplicationReviewAndManagementRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaManagementApplicationReviewAndManagementInteractor: PresentableInteractor<AreaManagementApplicationReviewAndManagementPresentable>, AreaManagementApplicationReviewAndManagementInteractable {
    
    
    /// Reference to ``AreaManagementApplicationReviewAndManagementRouter``.
    weak var router: AreaManagementApplicationReviewAndManagementRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaManagementApplicationReviewAndManagementListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaManagementApplicationReviewAndManagementComponent
    
    
    /// Bridge to the ``AreaManagementApplicationReviewAndManagementSwiftUIVIew``.
    private var viewModel = AreaManagementApplicationReviewAndManagementSwiftUIViewModel()
    
    
    /// Constructs an instance of ``AreaManagementApplicationReviewAndManagementInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaManagementApplicationReviewAndManagementComponent, presenter: AreaManagementApplicationReviewAndManagementPresentable) {
        self.component = component
        
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
        // TODO: Configure the view model.
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``AreaManagementApplicationReviewAndManagementPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaManagementApplicationReviewAndManagementViewController``.
extension AreaManagementApplicationReviewAndManagementInteractor: AreaManagementApplicationReviewAndManagementPresentableListener {
    func navigateBack() {
        listener?.navigateBack()
    }
}
