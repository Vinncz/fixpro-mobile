import RIBs
import RxSwift



/// Contract adhered to by ``LocationDetailFromTicketDetailRouter``, listing the attributes and/or actions 
/// that ``LocationDetailFromTicketDetailInteractor`` is allowed to access or invoke.
protocol LocationDetailFromTicketDetailRouting: ViewableRouting {}



/// Contract adhered to by ``LocationDetailFromTicketDetailViewController``, listing the attributes and/or actions
/// that ``LocationDetailFromTicketDetailInteractor`` is allowed to access or invoke.
protocol LocationDetailFromTicketDetailPresentable: Presentable {
    
    
    /// Reference to ``LocationDetailFromTicketDetailInteractor``.
    var presentableListener: LocationDetailFromTicketDetailPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: LocationDetailFromTicketDetailSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `LocationDetailFromTicketDetailRIB`'s parent, listing the attributes and/or actions
/// that ``LocationDetailFromTicketDetailInteractor`` is allowed to access or invoke.
protocol LocationDetailFromTicketDetailListener: AnyObject {}



/// The functionality centre of `LocationDetailFromTicketDetailRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class LocationDetailFromTicketDetailInteractor: PresentableInteractor<LocationDetailFromTicketDetailPresentable>, LocationDetailFromTicketDetailInteractable {
    
    
    /// Reference to ``LocationDetailFromTicketDetailRouter``.
    weak var router: LocationDetailFromTicketDetailRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: LocationDetailFromTicketDetailListener?
    
    
    /// Reference to the component of this RIB.
    var component: LocationDetailFromTicketDetailComponent
    
    
    /// Bridge to the ``LocationDetailFromTicketDetailSwiftUIVIew``.
    private var viewModel = LocationDetailFromTicketDetailSwiftUIViewModel()
    
    
    /// Constructs an instance of ``LocationDetailFromTicketDetailInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: LocationDetailFromTicketDetailComponent) {
        self.component = component
        let presenter = component.locationDetailFromTicketDetailViewController
        
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



/// Conformance to the ``LocationDetailFromTicketDetailPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``LocationDetailFromTicketDetailViewController``.
extension LocationDetailFromTicketDetailInteractor: LocationDetailFromTicketDetailPresentableListener {}
