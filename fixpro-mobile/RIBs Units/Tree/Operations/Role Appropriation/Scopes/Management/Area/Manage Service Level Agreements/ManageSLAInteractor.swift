import RIBs
import VinUtility
import UIKit
import RxSwift



/// Contract adhered to by ``ManageSLARouter``, listing the attributes and/or actions 
/// that ``ManageSLAInteractor`` is allowed to access or invoke.
protocol ManageSLARouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``ManageSLAViewController``, listing the attributes and/or actions
/// that ``ManageSLAInteractor`` is allowed to access or invoke.
protocol ManageSLAPresentable: Presentable {
    
    
    /// Reference to ``ManageSLAInteractor``.
    var presentableListener: ManageSLAPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: ManageSLASwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `ManageSLARIB`'s parent, listing the attributes and/or actions
/// that ``ManageSLAInteractor`` is allowed to access or invoke.
protocol ManageSLAListener: AnyObject {
    func respondToNavigateBack(from origin: UIViewController)
}



/// The functionality centre of `ManageSLARIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class ManageSLAInteractor: PresentableInteractor<ManageSLAPresentable>, ManageSLAInteractable {
    
    
    /// Reference to ``ManageSLARouter``.
    weak var router: ManageSLARouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: ManageSLAListener?
    
    
    /// Reference to the component of this RIB.
    var component: ManageSLAComponent
    
    
    /// Bridge to the ``ManageSLASwiftUIVIew``.
    private var viewModel = ManageSLASwiftUIViewModel()
    
    
    /// Constructs an instance of ``ManageSLAInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: ManageSLAComponent, presenter: ManageSLAPresentable) {
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
        viewModel.didSave = { [weak self] in 
            guard let self else { return }
            
            Task {
                if try await self.save() {
                    // Good.
                }
            }
        }
        presenter.bind(viewModel: self.viewModel)
        Task { [weak self] in
            if let slas = try await self?.fetchSLAs() {
                self?.viewModel.respondSLA = slas.respond
                self?.viewModel.autoCloseSLA = slas.autoClose
                self?.viewModel.issueTypes = slas.perCategory
            }
        }
    }
    
}



extension ManageSLAInteractor {
    
    
    func fetchSLAs() async throws -> (respond: String, autoClose: String, perCategory: [FPIssueType]) {
        async let request = try component.networkingClient.gateway.getSLAs(.init(headers: .init(accept: [.init(contentType: .json)])))
        
        switch try await request {
            case .ok(let response):
                if case let .json(jsonBody) = response.body {
                    guard 
                        let respondDuration = jsonBody.data?.sla_to_respond, 
                        let autoCloseDuration = jsonBody.data?.sla_to_auto_close,
                        let perIssueTypes = jsonBody.data?.per_issue_types
                    else { return (.EMPTY, .EMPTY, []) }
                    
                    return (respondDuration, autoCloseDuration, perIssueTypes.map { it in
                        FPIssueType(id: it.id ?? UUID().uuidString, name: it.name ?? "Unnamed category", serviceLevelAgreementDurationHour: it.service_level_agreement_duration_hour ?? "-1")
                    })
                }
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return (.EMPTY, .EMPTY, [])
    }
    
    
    func save() async throws -> Bool {
        async let request = try component.networkingClient.gateway.putSLAs(.init(
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(data: .init(
                sla_to_respond: viewModel.respondSLA, 
                sla_to_auto_close: viewModel.autoCloseSLA, 
                per_issue_types: viewModel.issueTypes.map { it in
                    .init(id: it.id, duration: it.serviceLevelAgreementDurationHour)
                }
            )))
        ))
        
        switch try await request {
            case .ok:
                return true
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return false
    }
    
}



/// Conformance to the ``ManageSLAPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``ManageSLAViewController``.
extension ManageSLAInteractor: ManageSLAPresentableListener {
    
    
    func navigateBack(from origin: UIViewController) {
        listener?.respondToNavigateBack(from: origin)
    }
    
}
