import RIBs
import VinUtility
import UIKit
import RxSwift



/// Contract adhered to by ``ApplicantDetailRouter``, listing the attributes and/or actions 
/// that ``ApplicantDetailInteractor`` is allowed to access or invoke.
protocol ApplicantDetailRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``ApplicantDetailViewController``, listing the attributes and/or actions
/// that ``ApplicantDetailInteractor`` is allowed to access or invoke.
protocol ApplicantDetailPresentable: Presentable {
    
    
    /// Reference to ``ApplicantDetailInteractor``.
    var presentableListener: ApplicantDetailPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: ApplicantDetailSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `ApplicantDetailRIB`'s parent, listing the attributes and/or actions
/// that ``ApplicantDetailInteractor`` is allowed to access or invoke.
protocol ApplicantDetailListener: AnyObject {
    func respondToNavigateBack(from origin: UIViewController)
    func didApprove(applicant: FPEntryApplication)
    func didReject(applicant: FPEntryApplication)
}



/// The functionality centre of `ApplicantDetailRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class ApplicantDetailInteractor: PresentableInteractor<ApplicantDetailPresentable>, ApplicantDetailInteractable {
    
    
    /// Reference to ``ApplicantDetailRouter``.
    weak var router: ApplicantDetailRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: ApplicantDetailListener?
    
    
    /// Reference to the component of this RIB.
    var component: ApplicantDetailComponent
    
    
    /// Bridge to the ``ApplicantDetailSwiftUIVIew``.
    private var viewModel: ApplicantDetailSwiftUIViewModel
    
    
    private var applicant: FPEntryApplication
    
    
    /// Constructs an instance of ``ApplicantDetailInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: ApplicantDetailComponent, presenter: ApplicantDetailPresentable, applicant: FPEntryApplication) {
        self.component = component
        self.applicant = applicant
        self.viewModel = ApplicantDetailSwiftUIViewModel(applicant: applicant)
        
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
        viewModel.didApprove = { [weak self] (role: FPTokenRole, title: String, specialties: [FPIssueType], capabilities: [FPCapability]) in
            guard let self else { return }
            
            Task { 
                if try await self.approveApplicant(role: role, title: title, specialties: specialties, capabilities: capabilities) {
                    self.viewModel.didIntendToApprove = false
                    Task { @MainActor in
                        self.listener?.didApprove(applicant: self.applicant)
                    }
                }
            }
        }
        viewModel.didReject = { [weak self] in
            guard let self else { return }
            
            Task { 
                if try await self.rejectApplicant() {
                    Task { @MainActor in
                        self.listener?.didReject(applicant: self.applicant)
                    }
                }
            }
        }
        Task { [weak self] in
            self?.viewModel.specialties = try await self?.getSpecialties() ?? []
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension ApplicantDetailInteractor {
    
    
    func approveApplicant(role: FPTokenRole, title: String, specialties: [FPIssueType], capabilities: [FPCapability]) async throws -> Bool {
        let request = try await component.networkingClient.gateway.postAreaPendingMembership(.init(
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(data: .init(
                application_id: applicant.id,
                role: .init(stringLiteral: role.rawValue),
                specialization: specialties.map { $0.id },
                capabilities: capabilities.map { .init(stringLiteral: "\($0.rawValue)") },
                title: title
            )))
        ))
        
        switch request {
            case .ok:
                return true
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
                return false
        }
    }
    
    
    func rejectApplicant() async throws -> Bool {
        let request = try await component.networkingClient.gateway.deleteAreaPendingMembership(.init(path: .init(application_id: applicant.id)))
        
        switch request {
            case .ok:
                return true
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
                return false
        }
    }
    
    
    func getSpecialties() async throws -> [FPIssueType] {
        let request = try await component.networkingClient.gateway.getIssueTypes(.init(
            headers: .init(accept: [.init(contentType: .json)])
        ))
        
        var specialties: [FPIssueType] = []
        
        switch request {
            case .ok(let response):
                if case let .json(payload) = response.body {
                    payload.data?.forEach { sla in 
                        guard let id = sla.id, let name = sla.name, let duration = sla.service_level_agreement_duration_hour else { return }
                        
                        specialties.append(.init(id: id, name: name, serviceLevelAgreementDurationHour: duration))
                    }
                }
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return specialties
    }
    
}



/// Conformance to the ``ApplicantDetailPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``ApplicantDetailViewController``.
extension ApplicantDetailInteractor: ApplicantDetailPresentableListener {
    
    
    func navigateBack(from origin: UIViewController) {
        listener?.respondToNavigateBack(from: origin)
    }
    
}
