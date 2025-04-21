import RIBs
import RxSwift



/// Contract adhered to by ``NewTicketRouter``, listing the attributes and/or actions 
/// that ``NewTicketInteractor`` is allowed to access or invoke.
protocol NewTicketRouting: ViewableRouting {}



/// Contract adhered to by ``NewTicketViewController``, listing the attributes and/or actions
/// that ``NewTicketInteractor`` is allowed to access or invoke.
protocol NewTicketPresentable: Presentable {
    
    
    /// Reference to ``NewTicketInteractor``.
    var presentableListener: NewTicketPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: NewTicketSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `NewTicketRIB`'s parent, listing the attributes and/or actions
/// that ``NewTicketInteractor`` is allowed to access or invoke.
protocol NewTicketListener: AnyObject {}



/// The functionality centre of `NewTicketRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class NewTicketInteractor: PresentableInteractor<NewTicketPresentable>, NewTicketInteractable {
    
    
    /// Reference to ``NewTicketRouter``.
    weak var router: NewTicketRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: NewTicketListener?
    
    
    /// Reference to the component of this RIB.
    var component: NewTicketComponent
    
    
    /// Bridge to the ``NewTicketSwiftUIVIew``.
    private var viewModel = NewTicketSwiftUIViewModel()
    
    
    /// Constructs an instance of ``NewTicketInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: NewTicketComponent) {
        self.component = component
        let presenter = component.newTicketViewController
        
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



/// Conformance to the ``NewTicketPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``NewTicketViewController``.
extension NewTicketInteractor: NewTicketPresentableListener {}
