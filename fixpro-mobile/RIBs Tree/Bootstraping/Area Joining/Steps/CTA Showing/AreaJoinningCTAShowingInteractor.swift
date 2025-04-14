import RIBs
import RxSwift



/// Contract adhered to by ``AreaJoinningCTAShowingRouter``, listing the attributes and/or actions 
/// that ``AreaJoinningCTAShowingInteractor`` is allowed to access or invoke.
protocol AreaJoinningCTAShowingRouting: ViewableRouting {}



/// Contract adhered to by ``AreaJoinningCTAShowingViewController``, listing the attributes and/or actions
/// that ``AreaJoinningCTAShowingInteractor`` is allowed to access or invoke.
protocol AreaJoinningCTAShowingPresentable: Presentable {
    
    
    /// Reference to ``AreaJoinningCTAShowingInteractor``.
    var presentableListener: AreaJoinningCTAShowingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: AreaJoinningCTAShowingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `AreaJoinningCTAShowingRIB`'s parent, listing the attributes and/or actions
/// that ``AreaJoinningCTAShowingInteractor`` is allowed to access or invoke.
protocol AreaJoinningCTAShowingListener: AnyObject {
    func didFinishPairing(isImmidiatelyAccepted: Bool)
}



/// The functionality centre of `AreaJoinningCTAShowingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaJoinningCTAShowingInteractor: PresentableInteractor<AreaJoinningCTAShowingPresentable>, AreaJoinningCTAShowingInteractable {
    
    
    /// Reference to ``AreaJoinningCTAShowingRouter``.
    weak var router: AreaJoinningCTAShowingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaJoinningCTAShowingListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaJoinningCTAShowingComponent
    
    
    /// Bridge to the ``AreaJoinningCTAShowingSwiftUIVIew``.
    private var viewModel = AreaJoinningCTAShowingSwiftUIViewModel()
    
    
    /// Constructs an instance of ``AreaJoinningCTAShowingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaJoinningCTAShowingComponent) {
        self.component = component
        let presenter = component.areaJoinningCTAShowingViewController
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



/// Conformance to the ``AreaJoinningCTAShowingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningCTAShowingViewController``.
extension AreaJoinningCTAShowingInteractor: AreaJoinningCTAShowingPresentableListener {
    
    
    func didFinishPairing() {
        listener?.didFinishPairing(isImmidiatelyAccepted: false)
    }
    
}
