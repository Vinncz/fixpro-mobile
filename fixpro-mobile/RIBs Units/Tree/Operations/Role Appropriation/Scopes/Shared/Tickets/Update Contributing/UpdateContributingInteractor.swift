import RIBs
import UniformTypeIdentifiers
import Foundation
import VinUtility
import RxSwift



/// Contract adhered to by ``UpdateContributingRouter``, listing the attributes and/or actions 
/// that ``UpdateContributingInteractor`` is allowed to access or invoke.
protocol UpdateContributingRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
    
    func dismiss()
    
}



/// Contract adhered to by ``UpdateContributingViewController``, listing the attributes and/or actions
/// that ``UpdateContributingInteractor`` is allowed to access or invoke.
protocol UpdateContributingPresentable: Presentable {
    
    
    /// Reference to ``UpdateContributingInteractor``.
    var presentableListener: UpdateContributingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: UpdateContributingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `UpdateContributingRIB`'s parent, listing the attributes and/or actions
/// that ``UpdateContributingInteractor`` is allowed to access or invoke.
protocol UpdateContributingListener: AnyObject {
    func dismissUpdateContributing(didContribute: Bool)
}



/// The functionality centre of `UpdateContributingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class UpdateContributingInteractor: PresentableInteractor<UpdateContributingPresentable>, UpdateContributingInteractable {
    
    
    /// Reference to ``UpdateContributingRouter``.
    weak var router: UpdateContributingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: UpdateContributingListener?
    
    
    /// Reference to the component of this RIB.
    var component: UpdateContributingComponent
    
    
    /// Bridge to the ``UpdateContributingSwiftUIVIew``.
    private var viewModel = UpdateContributingSwiftUIViewModel()
    
    
    var ticketId: String
    
    
    /// Constructs an instance of ``UpdateContributingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: UpdateContributingComponent, presenter: UpdateContributingPresentable, ticketId: String) {
        self.component = component
        self.ticketId = ticketId
        
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
        viewModel.authorizationContext = component.authorizationContext
        viewModel.didIntendToCancel = { [weak self] in 
            self?.router?.dismiss()
            self?.listener?.dismissUpdateContributing(didContribute: false)
        }
        viewModel.didIntendToSubmit = { [weak self] (news: String, supportiveDocuments: [URL], updateType: FPTicketLogType) in 
            Task { [weak self] in
                guard let self else { return }
                if try await self.submitMadeUpdate(news: news, supportiveDocuments: supportiveDocuments, updateType: updateType) {
                    self.router?.dismiss()
                    self.listener?.dismissUpdateContributing(didContribute: true)
                }
            }
        }
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension UpdateContributingInteractor {
    
    
    func submitMadeUpdate(news: String, supportiveDocuments: [URL], updateType: FPTicketLogType) async throws -> Bool {
        let attachments = supportiveDocuments.map { file in Components.Schemas.TOBEMADE_hyphen_supportive_hyphen_document(
            resource_type: .init(stringLiteral: UTType(file.pathExtension)?.preferredMIMEType ?? UTType.data.preferredMIMEType ?? "application/octet-stream"),
            resource_name: file.lastPathComponent,
            resource_size: Double(inferFileSize(from: file) ?? 0), 
            resource_content: fileToBase64(on: file)
        )}
        
        async let request = component.networkingClient.gateway.postTicketLog(.init(
            path: .init(ticket_id: ticketId),
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(data: .init(
                news: news,
                supportive_documents: attachments,
                _type: .init(stringLiteral: updateType.id.rawValue)
            )))
        ))
        
        switch try await request {
            case .created:
                return true
                
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return false
    }
    
}



/// Conformance to the ``UpdateContributingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``UpdateContributingViewController``.
extension UpdateContributingInteractor: UpdateContributingPresentableListener {}
