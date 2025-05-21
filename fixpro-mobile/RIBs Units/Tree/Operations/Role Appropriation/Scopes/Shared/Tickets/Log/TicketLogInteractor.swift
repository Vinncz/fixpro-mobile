import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``TicketLogRouter``, listing the attributes and/or actions 
/// that ``TicketLogInteractor`` is allowed to access or invoke.
protocol TicketLogRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func cleanupViews()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func removeSwiftUI()
    
}



/// Contract adhered to by ``TicketLogViewController``, listing the attributes and/or actions
/// that ``TicketLogInteractor`` is allowed to access or invoke.
protocol TicketLogPresentable: Presentable {
    
    
    /// Reference to ``TicketLogInteractor``.
    var presentableListener: TicketLogPresentableListener? { get set }
    
    
    /// Reference to the view model.
    var viewModel: TicketLogSwiftUIViewModel? { get }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: TicketLogSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `TicketLogRIB`'s parent, listing the attributes and/or actions
/// that ``TicketLogInteractor`` is allowed to access or invoke.
protocol TicketLogListener: AnyObject {
    func navigateBackToTicketDetail()
}



/// The functionality centre of `TicketLogRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class TicketLogInteractor: PresentableInteractor<TicketLogPresentable>, TicketLogInteractable {
    
    
    /// Reference to ``TicketLogRouter``.
    weak var router: TicketLogRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: TicketLogListener?
    
    
    /// Reference to the component of this RIB.
    var component: TicketLogComponent
    
    
    /// Bridge to the ``TicketLogSwiftUIVIew``.
    private var viewModel: TicketLogSwiftUIViewModel
    
    
    var ticketLog: FPTicketLog
    
    
    /// Constructs an instance of ``TicketLogInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: TicketLogComponent, presenter: TicketLogPresentable, ticketLog: FPTicketLog) {
        self.component = component
        self.ticketLog = ticketLog
        self.viewModel = TicketLogSwiftUIViewModel(log: ticketLog)
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
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
        router?.cleanupViews()
        router?.removeSwiftUI()
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``TicketLogPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``TicketLogViewController``.
extension TicketLogInteractor: TicketLogPresentableListener {
    
    
    func navigateToTicketDetail() {
        listener?.navigateBackToTicketDetail()
    }
    
}
