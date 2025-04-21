import RIBs
import RxSwift



/// Contract adhered to by ``WorkEvaluatingRouter``, listing the attributes and/or actions 
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingRouting: ViewableRouting {}



/// Contract adhered to by ``WorkEvaluatingViewController``, listing the attributes and/or actions
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingPresentable: Presentable {
    
    
    /// Reference to ``WorkEvaluatingInteractor``.
    var presentableListener: WorkEvaluatingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: WorkEvaluatingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `WorkEvaluatingRIB`'s parent, listing the attributes and/or actions
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingListener: AnyObject {}



/// The functionality centre of `WorkEvaluatingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class WorkEvaluatingInteractor: PresentableInteractor<WorkEvaluatingPresentable>, WorkEvaluatingInteractable {
    
    
    /// Reference to ``WorkEvaluatingRouter``.
    weak var router: WorkEvaluatingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: WorkEvaluatingListener?
    
    
    /// Reference to the component of this RIB.
    var component: WorkEvaluatingComponent
    
    
    /// Bridge to the ``WorkEvaluatingSwiftUIVIew``.
    private var viewModel = WorkEvaluatingSwiftUIViewModel()
    
    
    /// Constructs an instance of ``WorkEvaluatingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: WorkEvaluatingComponent) {
        self.component = component
        let presenter = component.workEvaluatingViewController
        
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



/// Conformance to the ``WorkEvaluatingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``WorkEvaluatingViewController``.
extension WorkEvaluatingInteractor: WorkEvaluatingPresentableListener {}
