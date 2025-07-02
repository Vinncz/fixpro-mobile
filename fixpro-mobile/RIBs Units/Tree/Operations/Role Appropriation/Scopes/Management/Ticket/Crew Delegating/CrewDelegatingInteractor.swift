import RIBs
import UniformTypeIdentifiers
import Foundation
import VinUtility
import RxSwift



/// Contract adhered to by ``CrewDelegatingRouter``, listing the attributes and/or actions 
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
    
    func dismiss()
    
}



/// Contract adhered to by ``CrewDelegatingViewController``, listing the attributes and/or actions
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingPresentable: Presentable {
    
    
    /// Reference to ``CrewDelegatingInteractor``.
    var presentableListener: CrewDelegatingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: CrewDelegatingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `CrewDelegatingRIB`'s parent, listing the attributes and/or actions
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingListener: AnyObject {
    func dismissCrewDelegating(didDelegate: Bool)
}



/// The functionality centre of `CrewDelegatingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class CrewDelegatingInteractor: PresentableInteractor<CrewDelegatingPresentable>, CrewDelegatingInteractable {
    
    
    /// Reference to ``CrewDelegatingRouter``.
    weak var router: CrewDelegatingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: CrewDelegatingListener?
    
    
    /// Reference to the component of this RIB.
    var component: CrewDelegatingComponent
    
    
    /// Bridge to the ``CrewDelegatingSwiftUIVIew``.
    private var viewModel: CrewDelegatingSwiftUIViewModel
    
    
    /// Ticket in question.
    var ticket: FPTicketDetail
    
    
    /// Constructs an instance of ``CrewDelegatingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: CrewDelegatingComponent, presenter: CrewDelegatingPresentable, ticket: FPTicketDetail) {
        self.component = component
        self.ticket = ticket
        self.viewModel = CrewDelegatingSwiftUIViewModel(ticket: ticket)
        
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
        viewModel.didIntendToRefreshMemberList = { [weak self] in 
            guard let self else { return }
            self.viewModel.availablePersonnel = try await self.fetchAvailablePersonnel()
        }
        viewModel.didIntendToCancel = { [weak self] in 
            guard let self else { return }
            router?.dismiss()
            listener?.dismissCrewDelegating(didDelegate: false)
        }
        viewModel.didIntendToDelegate = { [weak self] in 
            guard let self else { return }
            do {
                if try await self.submitDelegation() {
                    router?.dismiss()
                    listener?.dismissCrewDelegating(didDelegate: true)
                }
            } catch {
                VULogger.log(tag: .error, error)
            }
        }
        Task { [weak self] in
            guard let self else { return }
            self.viewModel.availablePersonnel = try await self.fetchAvailablePersonnel()
        }
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension CrewDelegatingInteractor {
    
    
    func fetchAvailablePersonnel() async throws -> [FPPerson] {
        async let request = component.networkingClient.gateway.getAreaMembers(.init(
            headers: .init(accept: [.init(contentType: .json)])
        ))
        
        switch try await request {
            case let .ok(response):
                var personnel: [FPPerson] = []
                if case let .json(body) = response.body {
                    guard let data = body.data else { break }
                    
                    personnel.append(contentsOf: data.compactMap { dto in
                        let encoder = JSONEncoder()
                        if let encodedData = try? encoder.encode(dto),
                           let individualPersonnelData = try? decode(encodedData, to: VUExtrasPreservingDecodable<FPPerson>.self).get() 
                        {
                            var individualPersonnel = individualPersonnelData.model
                                individualPersonnel.extras = individualPersonnelData.extrasAsStringMap()
                            
                            return individualPersonnel
                        }
                        
                        return nil
                        
//                        guard 
//                            let id = dto.id,
//                            let name = dto.name, 
//                            let unparsedRole = dto.role,
//                            let role = FPTokenRole(rawValue: "\(unparsedRole.value ?? "")"),
//                            let unparsedSpecialties = dto.specialties,
//                            let unparsedCapabilities = dto.capabilities,
//                            let memberSince = dto.member_since
//                        else { return nil }
//                        
//                        let specialties: [FPIssueType] = unparsedSpecialties.compactMap { dto in
//                            guard
//                                let id = dto.id,
//                                let name = dto.name,
//                                let serviceLevelAgreementDurationHour = dto.service_level_agreement_duration_hour
//                            else { return nil }
//                            
//                            return FPIssueType(
//                                id: id, 
//                                name: name, 
//                                serviceLevelAgreementDurationHour: serviceLevelAgreementDurationHour
//                            )
//                        }
//                        
//                        let capabilities: [FPCapability] = unparsedCapabilities.compactMap { dto in 
//                            guard let value = dto.value else { return nil }
//                            return FPCapability(rawValue: "\(value)")
//                        }
//                        
//                        return FPPerson(
//                            id: id, 
//                            name: name, 
//                            role: role, 
//                            specialties: specialties, 
//                            capabilities: capabilities, 
//                            memberSince: memberSince
//                        )
                    })
                }
                
                return personnel
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return []
    }
    
    
    func submitDelegation() async throws -> Bool {
        async let request = component.networkingClient.gateway.postTicketHandlers(.init(
            path: .init(ticket_id: ticket.id),
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(
                data: viewModel.crewDelegatingDetails.map { detail in 
                    let attachments = viewModel.supportiveDocuments.map { file in Components.Schemas.TOBEMADE_hyphen_supportive_hyphen_document(
                        resource_type: .init(stringLiteral: UTType(file.pathExtension)?.preferredMIMEType ?? UTType.data.preferredMIMEType ?? "application/octet-stream"),
                        resource_name: file.lastPathComponent,
                        resource_size: Double(inferFileSize(from: file) ?? 0), 
                        resource_content: fileToBase64(on: file)
                    )}
                    
                    return .init(
                        work_description: detail.workDirective,
                        appointed_member_ids: detail.personnel.map { $0.id },
                        issue_type: detail.issueType.id,
                        supportive_documents: attachments
                    )
                }
            ))
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



/// Conformance to the ``CrewDelegatingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``CrewDelegatingViewController``.
extension CrewDelegatingInteractor: CrewDelegatingPresentableListener {}
