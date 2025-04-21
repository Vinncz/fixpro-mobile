import RIBs
import RxSwift



/// Contract adhered to by ``TicketListsRouter``, listing the attributes and/or actions 
/// that ``TicketListsInteractor`` is allowed to access or invoke.
protocol TicketListsRouting: ViewableRouting {}



/// Contract adhered to by ``TicketListsViewController``, listing the attributes and/or actions
/// that ``TicketListsInteractor`` is allowed to access or invoke.
protocol TicketListsPresentable: Presentable {
    
    
    /// Reference to ``TicketListsInteractor``.
    var presentableListener: TicketListsPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: TicketListsSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `TicketListsRIB`'s parent, listing the attributes and/or actions
/// that ``TicketListsInteractor`` is allowed to access or invoke.
protocol TicketListsListener: AnyObject {}



/// The functionality centre of `TicketListsRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class TicketListsInteractor: PresentableInteractor<TicketListsPresentable>, TicketListsInteractable {
    
    
    /// Reference to ``TicketListsRouter``.
    weak var router: TicketListsRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: TicketListsListener?
    
    
    /// Reference to the component of this RIB.
    var component: TicketListsComponent
    
    
    /// Bridge to the ``TicketListsSwiftUIVIew``.
    private var viewModel = TicketListsSwiftUIViewModel()
    
    
    /// Constructs an instance of ``TicketListsInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: TicketListsComponent) {
        self.component = component
        let presenter = component.ticketListsViewController
        
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



/// Conformance to the ``TicketListsPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``TicketListsViewController``.
extension TicketListsInteractor: TicketListsPresentableListener {}
