import RIBs
import RxSwift



/// Contract adhered to by ``AreaManagmentIssueTypesWithSLARegistrarRouter``, listing the attributes and/or actions 
/// that ``AreaManagmentIssueTypesWithSLARegistrarInteractor`` is allowed to access or invoke.
protocol AreaManagmentIssueTypesWithSLARegistrarRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``AreaManagmentIssueTypesWithSLARegistrarViewController``, listing the attributes and/or actions
/// that ``AreaManagmentIssueTypesWithSLARegistrarInteractor`` is allowed to access or invoke.
protocol AreaManagmentIssueTypesWithSLARegistrarPresentable: Presentable {
    
    
    /// Reference to ``AreaManagmentIssueTypesWithSLARegistrarInteractor``.
    var presentableListener: AreaManagmentIssueTypesWithSLARegistrarPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `AreaManagmentIssueTypesWithSLARegistrarRIB`'s parent, listing the attributes and/or actions
/// that ``AreaManagmentIssueTypesWithSLARegistrarInteractor`` is allowed to access or invoke.
protocol AreaManagmentIssueTypesWithSLARegistrarListener: AnyObject {
    func navigateBack()
}



/// The functionality centre of `AreaManagmentIssueTypesWithSLARegistrarRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaManagmentIssueTypesWithSLARegistrarInteractor: PresentableInteractor<AreaManagmentIssueTypesWithSLARegistrarPresentable>, AreaManagmentIssueTypesWithSLARegistrarInteractable {
    
    
    /// Reference to ``AreaManagmentIssueTypesWithSLARegistrarRouter``.
    weak var router: AreaManagmentIssueTypesWithSLARegistrarRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaManagmentIssueTypesWithSLARegistrarListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaManagmentIssueTypesWithSLARegistrarComponent
    
    
    /// Bridge to the ``AreaManagmentIssueTypesWithSLARegistrarSwiftUIVIew``.
    private var viewModel = AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel()
    
    
    /// Constructs an instance of ``AreaManagmentIssueTypesWithSLARegistrarInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaManagmentIssueTypesWithSLARegistrarComponent, presenter: AreaManagmentIssueTypesWithSLARegistrarPresentable) {
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



/// Conformance to the ``AreaManagmentIssueTypesWithSLARegistrarPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaManagmentIssueTypesWithSLARegistrarViewController``.
extension AreaManagmentIssueTypesWithSLARegistrarInteractor: AreaManagmentIssueTypesWithSLARegistrarPresentableListener {
    func navigateBack() {
        listener?.navigateBack()
    }
}
