import RIBs
import RxSwift
import UIKit



/// Contract adhered to by ``AreaManagementNavigatorRouter``, listing the attributes and/or actions 
/// that ``AreaManagementNavigatorInteractor`` is allowed to access or invoke.
protocol AreaManagementNavigatorRouting: ViewableRouting {
        
    
    /// Cleanses the view hierarchy of any `ViewControllable` instances this RIB may have added.
    func cleanupViews()
    
    
    func navigateToApplicationReviewAndManagement()
    
    
    func navigateToIssueTypesWithSLARegistrar()
    
    
    func navigateToStatistics()
    
    
    func toRoot()
    
}



/// Contract adhered to by ``AreaManagementNavigatorViewController``, listing the attributes and/or actions
/// that ``AreaManagementNavigatorInteractor`` is allowed to access or invoke.
protocol AreaManagementNavigatorPresentable: Presentable {
    
    
    /// Reference to ``AreaManagementNavigatorInteractor``.
    var presentableListener: AreaManagementNavigatorPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `AreaManagementNavigatorRIB`'s parent, listing the attributes and/or actions
/// that ``AreaManagementNavigatorInteractor`` is allowed to access or invoke.
protocol AreaManagementNavigatorListener: AnyObject {}



/// The functionality centre of `AreaManagementNavigatorRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaManagementNavigatorInteractor: PresentableInteractor<AreaManagementNavigatorPresentable>, AreaManagementNavigatorInteractable {
    
    
    /// Reference to ``AreaManagementNavigatorRouter``.
    weak var router: AreaManagementNavigatorRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaManagementNavigatorListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaManagementNavigatorComponent
    
    
    /// Constructs an instance of ``AreaManagementNavigatorInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaManagementNavigatorComponent, presenter: AreaManagementNavigatorPresentable) {
        self.component = component
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()
    }
    
}



extension AreaManagementNavigatorInteractor {
    
    
    func navigateToApplicationReviewAndManagement() {
        router?.navigateToApplicationReviewAndManagement()
    }
    
    
    func navigateToIssueTypesWithSLARegistrar() {
        router?.navigateToIssueTypesWithSLARegistrar()
    }
    
    
    func navigateToStatistics() {
        router?.navigateToStatistics()
    }
    
    
    func navigateBack() {
        router?.toRoot()
    }
    
}



/// Conformance to the ``AreaManagementNavigatorPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaManagementNavigatorViewController``.
extension AreaManagementNavigatorInteractor: AreaManagementNavigatorPresentableListener {}
