import RIBs
import UniformTypeIdentifiers
import Foundation
import VinUtility
import RxSwift



/// Contract adhered to by ``WorkEvaluatingRouter``, listing the attributes and/or actions 
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
    
    func dismiss()
    
}



/// Contract adhered to by ``WorkEvaluatingViewController``, listing the attributes and/or actions
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingPresentable: Presentable {
    
    
    /// Reference to ``WorkEvaluatingInteractor``.
    var presentableListener: WorkEvaluatingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: WorkEvaluatingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `WorkEvaluatingRIB`'s parent, listing the attributes and/or actions
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingListener: AnyObject {
    func detachWorkEvaluating(didEvaluate: Bool)
}



/// The functionality centre of `WorkEvaluatingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class WorkEvaluatingInteractor: PresentableInteractor<WorkEvaluatingPresentable>, WorkEvaluatingInteractable {
    
    
    /// Reference to ``WorkEvaluatingRouter``.
    weak var router: WorkEvaluatingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: WorkEvaluatingListener?
    
    
    /// Reference to the component of this RIB.
    var component: WorkEvaluatingComponent
    
    
    /// Bridge to the ``WorkEvaluatingSwiftUIVIew``.
    private var viewModel: WorkEvaluatingSwiftUIViewModel
    
    
    var ticket: FPTicketDetail
    
    
    /// Constructs an instance of ``WorkEvaluatingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: WorkEvaluatingComponent, presenter: WorkEvaluatingPresentable, ticket: FPTicketDetail) {
        self.component = component
        self.ticket = ticket
        self.viewModel = WorkEvaluatingSwiftUIViewModel(ticket: ticket, component: component)
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
        viewModel.didIntendToCancel = { [weak self] in 
            self?.router?.dismiss()
            self?.listener?.detachWorkEvaluating(didEvaluate: false)
        }
        viewModel.didIntendToEvaluate = { [weak self] in 
            guard let self else { return }
            do {
                if try await self.evaluate(isApproved: viewModel.resolve == .Approved, shouldRequestOwnerConfirmation: viewModel.requireOwnerEvaluation, remarks: viewModel.remarks, supportiveDocuments: viewModel.supportiveDocuments) == true {
                    Task { @MainActor in
                        self.router?.dismiss()
                        self.listener?.detachWorkEvaluating(didEvaluate: true)
                    }
                }
            } catch {
                VULogger.log(tag: .error, error)
            }
        }
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``WorkEvaluatingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``WorkEvaluatingViewController``.
extension WorkEvaluatingInteractor: WorkEvaluatingPresentableListener {}



extension WorkEvaluatingInteractor {
    
    
    func evaluate(isApproved: Bool, shouldRequestOwnerConfirmation: Bool, remarks: String, supportiveDocuments: [URL]) async throws -> Bool {
        let attachments = supportiveDocuments.map { file in Components.Schemas.TOBEMADE_hyphen_supportive_hyphen_document(
            resource_type: .init(stringLiteral: UTType(file.pathExtension)?.preferredMIMEType ?? UTType.data.preferredMIMEType ?? "application/octet-stream"),
            resource_name: file.lastPathComponent,
            resource_size: Double(inferFileSize(from: file) ?? 0), 
            resource_content: fileToBase64(on: file)
        )}
        
        async let request = component.networkingClient.gateway.postTicketEvaluation(.init(
            path: .init(ticket_id: ticket.id),
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(data: .init(
                resolveToApprove: isApproved,
                requireOwnerApproval: shouldRequestOwnerConfirmation,
                reason: remarks,
                supportive_documents: attachments
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
