import RIBs
import RxSwift



/// Contract adhered to by ``InboxRouter``, listing the attributes and/or actions 
/// that ``InboxInteractor`` is allowed to access or invoke.
protocol InboxRouting: ViewableRouting {}



/// Contract adhered to by ``InboxViewController``, listing the attributes and/or actions
/// that ``InboxInteractor`` is allowed to access or invoke.
protocol InboxPresentable: Presentable {
    
    
    /// Reference to ``InboxInteractor``.
    var presentableListener: InboxPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: InboxSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `InboxRIB`'s parent, listing the attributes and/or actions
/// that ``InboxInteractor`` is allowed to access or invoke.
protocol InboxListener: AnyObject {}



/// The functionality centre of `InboxRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class InboxInteractor: PresentableInteractor<InboxPresentable>, InboxInteractable {
    
    
    /// Reference to ``InboxRouter``.
    weak var router: InboxRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: InboxListener?
    
    
    /// Reference to the component of this RIB.
    var component: InboxComponent
    
    
    /// Bridge to the ``InboxSwiftUIVIew``.
    private var viewModel = InboxSwiftUIViewModel()
    
    
    /// Constructs an instance of ``InboxInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: InboxComponent) {
        self.component = component
        let presenter = component.inboxViewController
        
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



/// Conformance to the ``InboxPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``InboxViewController``.
extension InboxInteractor: InboxPresentableListener {}
