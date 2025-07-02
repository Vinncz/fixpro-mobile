import RIBs
import VinUtility
import UIKit
import RxSwift



/// Contract adhered to by ``StatisticsAndReportsRouter``, listing the attributes and/or actions 
/// that ``StatisticsAndReportsInteractor`` is allowed to access or invoke.
protocol StatisticsAndReportsRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``StatisticsAndReportsViewController``, listing the attributes and/or actions
/// that ``StatisticsAndReportsInteractor`` is allowed to access or invoke.
protocol StatisticsAndReportsPresentable: Presentable {
    
    
    /// Reference to ``StatisticsAndReportsInteractor``.
    var presentableListener: StatisticsAndReportsPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: StatisticsAndReportsSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `StatisticsAndReportsRIB`'s parent, listing the attributes and/or actions
/// that ``StatisticsAndReportsInteractor`` is allowed to access or invoke.
protocol StatisticsAndReportsListener: AnyObject {
    func respondToNavigateBack(from origin: UIViewController)
}



/// The functionality centre of `StatisticsAndReportsRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class StatisticsAndReportsInteractor: PresentableInteractor<StatisticsAndReportsPresentable>, StatisticsAndReportsInteractable {
    
    
    /// Reference to ``StatisticsAndReportsRouter``.
    weak var router: StatisticsAndReportsRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: StatisticsAndReportsListener?
    
    
    /// Reference to the component of this RIB.
    var component: StatisticsAndReportsComponent
    
    
    /// Bridge to the ``StatisticsAndReportsSwiftUIVIew``.
    private var viewModel: StatisticsAndReportsSwiftUIViewModel
    
    
    /// Constructs an instance of ``StatisticsAndReportsInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: StatisticsAndReportsComponent, presenter: StatisticsAndReportsPresentable) {
        self.component = component
        self.viewModel = StatisticsAndReportsSwiftUIViewModel(component: component, bundles: [])
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
        viewModel.didIntendToRefresh = { [weak self] in
            guard let self else { return }
            self.viewModel.bundles = try await self.fetchStatisticsAndReports()
        }
        presenter.bind(viewModel: self.viewModel)
        Task { [weak self] in
            guard let self else { return }
            self.viewModel.bundles = try await self.fetchStatisticsAndReports()
        }
    }
    
}



extension StatisticsAndReportsInteractor {
    
    
    func fetchStatisticsAndReports() async throws -> [StatisticsAndReportsBundle] {
        async let request = component.networkingClient.gateway.getStatistics(.init(headers: .init(accept: [.init(contentType: .json)])))
        
        switch try await request {
            case let .ok(response):
                if case let .json(jsonBody) = response.body {
                    var bundles: [StatisticsAndReportsBundle] = []
                    
                    jsonBody.data?.forEach {
                        guard 
                            let month = $0.month, 
                            let year = $0.year, 
                            let periodicReportLinkString = $0.periodic_report, 
                            let ticketSummarizationLinkString = $0.ticket_summarization,
                            let periodicReportLink = URL(string: periodicReportLinkString), 
                            let ticketSummarizationLink = URL(string: ticketSummarizationLinkString) 
                        else { return }
                        
                        bundles.append(
                            StatisticsAndReportsBundle(month: month, 
                                                       year: year, 
                                                       periodicReportLink: periodicReportLink, 
                                                       ticketSummarizationLink: ticketSummarizationLink)
                        )
                    }
                    
                    return bundles
                }
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return []
    }
    
}



/// Conformance to the ``StatisticsAndReportsPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``StatisticsAndReportsViewController``.
extension StatisticsAndReportsInteractor: StatisticsAndReportsPresentableListener {
    
    
    func navigateBack(from origin: UIViewController) {
        listener?.respondToNavigateBack(from: origin)
    }
    
}
