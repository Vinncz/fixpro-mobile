import RIBs
import VinUtility
import UIKit
import RxSwift



/// Contract adhered to by ``ManageMembershipsRouter``, listing the attributes and/or actions 
/// that ``ManageMembershipsInteractor`` is allowed to access or invoke.
protocol ManageMembershipsRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
    
    func didRemove(applicant: FPEntryApplication)
    
    
    func didRemove(member: FPPerson)
    
}



/// Contract adhered to by ``ManageMembershipsViewController``, listing the attributes and/or actions
/// that ``ManageMembershipsInteractor`` is allowed to access or invoke.
protocol ManageMembershipsPresentable: Presentable {
    
    
    /// Reference to ``ManageMembershipsInteractor``.
    var presentableListener: ManageMembershipsPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: ManageMembershipsSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `ManageMembershipsRIB`'s parent, listing the attributes and/or actions
/// that ``ManageMembershipsInteractor`` is allowed to access or invoke.
protocol ManageMembershipsListener: AnyObject {
    func respondToNavigateBack(from origin: UIViewController)
    func navigateTo(applicant: FPEntryApplication)
    func navigateTo(member: FPPerson)
}



/// The functionality centre of `ManageMembershipsRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class ManageMembershipsInteractor: PresentableInteractor<ManageMembershipsPresentable>, ManageMembershipsInteractable {
    
    
    /// Reference to ``ManageMembershipsRouter``.
    weak var router: ManageMembershipsRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: ManageMembershipsListener?
    
    
    /// Reference to the component of this RIB.
    var component: ManageMembershipsComponent
    
    
    /// Bridge to the ``ManageMembershipsSwiftUIVIew``.
    private var viewModel = ManageMembershipsSwiftUIViewModel()
    
    
    /// Constructs an instance of ``ManageMembershipsInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: ManageMembershipsComponent, presenter: ManageMembershipsPresentable) {
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
        viewModel.didTapApplicant = { [weak self] applicant in 
            self?.listener?.navigateTo(applicant: applicant)
        }
        viewModel.didTapMember = { [weak self] member in
            self?.listener?.navigateTo(member: member)
        }
        viewModel.didRefresh = { [weak self] in
            do {
                try await self?.fetchApplicantsAndMembers()
            } catch {
                VULogger.log(tag: .error, error)
            }
        }
        presenter.bind(viewModel: self.viewModel)
        
        Task { [weak self] in 
            do {
                try await self?.fetchApplicantsAndMembers()
            } catch {
                VULogger.log(tag: .error, error)
            }
        }
    }
    
    
    func didRemove(applicant: FPEntryApplication) {
        viewModel.applicants.removeAll { $0.id == applicant.id }
    }
    
    
    func didRemove(member: FPPerson) {
        viewModel.members.removeAll { $0.id == member.id }
    }
    
    
    func fetchApplicantsAndMembers() async throws {
        async let applicantsRequest = try component.networkingClient.gateway.getAreaPendingMemberships(.init(headers: .init(accept: [.init(contentType: .json)])))
        async let membersRequest  = try component.networkingClient.gateway.getAreaMembers(.init(headers: .init(accept: [.init(contentType: .json)])))
        
        var applicants: [FPEntryApplication] = []
        var members: [FPPerson] = []
        
        switch try await applicantsRequest {
            case .ok(let response): 
                if case let .json(body) = response.body {
                    body.data?.forEach { applicant in 
                        guard let applicantId = applicant.id, let submittedOn = applicant.submitted_on else { 
                            return 
                        }
                        
                        applicants.append(.init(
                            id: applicantId,
                            formAnswer: applicant.form_answer?.map { answer in
                                FPFormAnswer(fieldLabel: answer.field_label ?? "", 
                                                    fieldValue: answer.field_value ?? "")
                            } ?? [],
                            submittedOn: submittedOn
                        ))
                    }
                    
                    VULogger.log("Dapet applicants")
                    
                } else  {
                    VULogger.log("Meledak")
                    
                }
                
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        switch try await membersRequest {
            case .ok(let response):
                if case let .json(body) = response.body {
                    body.data?.forEach { member in 
                        guard 
                            let memberId = member.id,
                            let name = member.name,
                            let encodedRole = member.role, let role: FPTokenRole = .init(rawValue: encodedRole.value as? String ?? ""),
                            let encodedSpecialties = member.specialties,
                            let encodedCapabilities = member.capabilities,
                            let memberSince = member.member_since
                        else { 
                            VULogger.log("Kena cegat")
                            return 
                        }
                        
                        let specialties: [FPIssueType] = encodedSpecialties.map { specialty in
                            .init(id: specialty.id ?? UUID().uuidString, 
                                  name: specialty.name ?? "Unnamed specialty", 
                                  serviceLevelAgreementDurationHour: specialty.service_level_agreement_duration_hour ?? "-1")
                        }
                        
                        let capabilities = encodedCapabilities.compactMap {
                            FPCapability(rawValue: "\($0.value ?? "")")
                        }
                        
                        members.append(.init(
                            id: memberId, 
                            name: name, 
                            role: role, 
                            title: member.title,
                            specialties: specialties, 
                            capabilities: capabilities,
                            memberSince: memberSince
                        ))
                    }
                    
                } else {
                    VULogger.log(tag: .error, "Meledak")
                    
                }
                
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        viewModel.applicants = applicants
        viewModel.members = members
    }
    
}



/// Conformance to the ``ManageMembershipsPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``ManageMembershipsViewController``.
extension ManageMembershipsInteractor: ManageMembershipsPresentableListener {
    
    
    func navigateBack(from origin: UIViewController) {
        listener?.respondToNavigateBack(from: origin)
    }
    
}
