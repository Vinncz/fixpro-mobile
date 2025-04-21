import RIBs
import RxSwift



/// Contract adhered to by ``SupportiveDocumentListRouter``, listing the attributes and/or actions 
/// that ``SupportiveDocumentListInteractor`` is allowed to access or invoke.
protocol SupportiveDocumentListRouting: ViewableRouting {}



/// Contract adhered to by ``SupportiveDocumentListViewController``, listing the attributes and/or actions
/// that ``SupportiveDocumentListInteractor`` is allowed to access or invoke.
protocol SupportiveDocumentListPresentable: Presentable {
    
    
    /// Reference to ``SupportiveDocumentListInteractor``.
    var presentableListener: SupportiveDocumentListPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: SupportiveDocumentListSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `SupportiveDocumentListRIB`'s parent, listing the attributes and/or actions
/// that ``SupportiveDocumentListInteractor`` is allowed to access or invoke.
protocol SupportiveDocumentListListener: AnyObject {}



/// The functionality centre of `SupportiveDocumentListRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class SupportiveDocumentListInteractor: PresentableInteractor<SupportiveDocumentListPresentable>, SupportiveDocumentListInteractable {
    
    
    /// Reference to ``SupportiveDocumentListRouter``.
    weak var router: SupportiveDocumentListRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: SupportiveDocumentListListener?
    
    
    /// Reference to the component of this RIB.
    var component: SupportiveDocumentListComponent
    
    
    /// Bridge to the ``SupportiveDocumentListSwiftUIVIew``.
    private var viewModel = SupportiveDocumentListSwiftUIViewModel()
    
    
    /// Constructs an instance of ``SupportiveDocumentListInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: SupportiveDocumentListComponent) {
        self.component = component
        let presenter = component.supportiveDocumentListViewController
        
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
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        // TODO: Configure the view model.
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``SupportiveDocumentListPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``SupportiveDocumentListViewController``.
extension SupportiveDocumentListInteractor: SupportiveDocumentListPresentableListener {}
