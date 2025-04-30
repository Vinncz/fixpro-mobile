import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``TicketReportRouter``, listing the attributes and/or actions 
/// that ``TicketReportInteractor`` is allowed to access or invoke.
protocol TicketReportRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``TicketReportViewController``, listing the attributes and/or actions
/// that ``TicketReportInteractor`` is allowed to access or invoke.
protocol TicketReportPresentable: Presentable {
    
    
    /// Reference to ``TicketReportInteractor``.
    var presentableListener: TicketReportPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: TicketReportSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `TicketReportRIB`'s parent, listing the attributes and/or actions
/// that ``TicketReportInteractor`` is allowed to access or invoke.
protocol TicketReportListener: AnyObject {
    func didDismissTicketReport()
}



/// The functionality centre of `TicketReportRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class TicketReportInteractor: PresentableInteractor<TicketReportPresentable>, TicketReportInteractable {
    
    
    /// Reference to ``TicketReportRouter``.
    weak var router: TicketReportRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: TicketReportListener?
    
    
    /// Reference to the component of this RIB.
    var component: TicketReportComponent
    
    
    /// Bridge to the ``TicketReportSwiftUIVIew``.
    private var viewModel = TicketReportSwiftUIViewModel()
    
    
    var urlToReport: URL
    
    
    /// Constructs an instance of ``TicketReportInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: TicketReportComponent, presenter: TicketReportPresentable, urlToReport: URL) {
        self.component = component
        self.urlToReport = urlToReport
        
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
        router?.clearViewControllers()
        router?.detachSwiftUI()
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        viewModel.urlToReport = urlToReport
        viewModel.didIntendToDismiss = { [weak self] in
            self?.didGetDismissed()
        }
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``TicketReportPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``TicketReportViewController``.
extension TicketReportInteractor: TicketReportPresentableListener {
    func didGetDismissed() {
        listener?.didDismissTicketReport()
    }
}
