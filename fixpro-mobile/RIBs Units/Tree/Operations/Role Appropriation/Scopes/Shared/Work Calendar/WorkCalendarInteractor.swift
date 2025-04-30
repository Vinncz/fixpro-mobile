import RIBs
import VinUtility
import RxSwift



/// Contract adhered to by ``WorkCalendarRouter``, listing the attributes and/or actions 
/// that ``WorkCalendarInteractor`` is allowed to access or invoke.
protocol WorkCalendarRouting: ViewableRouting {}



/// Contract adhered to by ``WorkCalendarViewController``, listing the attributes and/or actions
/// that ``WorkCalendarInteractor`` is allowed to access or invoke.
protocol WorkCalendarPresentable: Presentable {
    
    
    /// Reference to ``WorkCalendarInteractor``.
    var presentableListener: WorkCalendarPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: WorkCalendarSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `WorkCalendarRIB`'s parent, listing the attributes and/or actions
/// that ``WorkCalendarInteractor`` is allowed to access or invoke.
protocol WorkCalendarListener: AnyObject {}



/// The functionality centre of `WorkCalendarRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class WorkCalendarInteractor: PresentableInteractor<WorkCalendarPresentable>, WorkCalendarInteractable {
    
    
    /// Reference to ``WorkCalendarRouter``.
    weak var router: WorkCalendarRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: WorkCalendarListener?
    
    
    /// Reference to the component of this RIB.
    var component: WorkCalendarComponent
    
    
    /// Bridge to the ``WorkCalendarSwiftUIVIew``.
    private var viewModel = WorkCalendarSwiftUIViewModel()
    
    
    /// Constructs an instance of ``WorkCalendarInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: WorkCalendarComponent) {
        self.component = component
        let presenter = component.workCalendarViewController
        
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
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        // TODO: Configure the view model.
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``WorkCalendarPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``WorkCalendarViewController``.
extension WorkCalendarInteractor: WorkCalendarPresentableListener {}
