import RIBs
import RxSwift



/// Contract adhered to by ``AreaManagementStatisticsRouter``, listing the attributes and/or actions 
/// that ``AreaManagementStatisticsInteractor`` is allowed to access or invoke.
protocol AreaManagementStatisticsRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``AreaManagementStatisticsViewController``, listing the attributes and/or actions
/// that ``AreaManagementStatisticsInteractor`` is allowed to access or invoke.
protocol AreaManagementStatisticsPresentable: Presentable {
    
    
    /// Reference to ``AreaManagementStatisticsInteractor``.
    var presentableListener: AreaManagementStatisticsPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: AreaManagementStatisticsSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `AreaManagementStatisticsRIB`'s parent, listing the attributes and/or actions
/// that ``AreaManagementStatisticsInteractor`` is allowed to access or invoke.
protocol AreaManagementStatisticsListener: AnyObject {}



/// The functionality centre of `AreaManagementStatisticsRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaManagementStatisticsInteractor: PresentableInteractor<AreaManagementStatisticsPresentable>, AreaManagementStatisticsInteractable {
    
    
    /// Reference to ``AreaManagementStatisticsRouter``.
    weak var router: AreaManagementStatisticsRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaManagementStatisticsListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaManagementStatisticsComponent
    
    
    /// Bridge to the ``AreaManagementStatisticsSwiftUIVIew``.
    private var viewModel = AreaManagementStatisticsSwiftUIViewModel()
    
    
    /// Constructs an instance of ``AreaManagementStatisticsInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaManagementStatisticsComponent, presenter: AreaManagementStatisticsPresentable) {
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



/// Conformance to the ``AreaManagementStatisticsPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaManagementStatisticsViewController``.
extension AreaManagementStatisticsInteractor: AreaManagementStatisticsPresentableListener {}
