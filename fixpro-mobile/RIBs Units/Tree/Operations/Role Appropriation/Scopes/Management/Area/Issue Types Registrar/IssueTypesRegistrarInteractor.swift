import RIBs
import VinUtility
import UIKit
import RxSwift



/// Contract adhered to by ``IssueTypesRegistrarRouter``, listing the attributes and/or actions 
/// that ``IssueTypesRegistrarInteractor`` is allowed to access or invoke.
protocol IssueTypesRegistrarRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
    
    func dismiss()
    
}



/// Contract adhered to by ``IssueTypesRegistrarViewController``, listing the attributes and/or actions
/// that ``IssueTypesRegistrarInteractor`` is allowed to access or invoke.
protocol IssueTypesRegistrarPresentable: Presentable {
    
    
    /// Reference to ``IssueTypesRegistrarInteractor``.
    var presentableListener: IssueTypesRegistrarPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: IssueTypesRegistrarSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `IssueTypesRegistrarRIB`'s parent, listing the attributes and/or actions
/// that ``IssueTypesRegistrarInteractor`` is allowed to access or invoke.
protocol IssueTypesRegistrarListener: AnyObject {
    func respondToNavigateBack(from origin: UIViewController)
}



/// The functionality centre of `IssueTypesRegistrarRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class IssueTypesRegistrarInteractor: PresentableInteractor<IssueTypesRegistrarPresentable>, IssueTypesRegistrarInteractable {
    
    
    /// Reference to ``IssueTypesRegistrarRouter``.
    weak var router: IssueTypesRegistrarRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: IssueTypesRegistrarListener?
    
    
    /// Reference to the component of this RIB.
    var component: IssueTypesRegistrarComponent
    
    
    /// Bridge to the ``IssueTypesRegistrarSwiftUIVIew``.
    private var viewModel = IssueTypesRegistrarSwiftUIViewModel()
    
    
    /// Constructs an instance of ``IssueTypesRegistrarInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: IssueTypesRegistrarComponent, presenter: IssueTypesRegistrarPresentable) {
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
        viewModel.didRefresh = { [weak self] in 
            do {
                self?.viewModel.issueTypes = try await self?.getIssueTypes() ?? []
            } catch {
                VULogger.log(tag: .error, error)
            }
        }
        viewModel.didMakeNewIssueType = { [weak self] (name: String, slaDuration: String) in
            guard let self else { return }
            Task { 
                do {
                    if try await self.makeIssueType(name: name, slaDuration: slaDuration) {
                        self.viewModel.shouldShowSuccessAlert = true
                    } 
                } catch {
                    VULogger.log(tag: .error, error)
                }
            }
        }
        viewModel.didRemoveIssueType = { [weak self] (issueType: FPIssueType) in
            guard let self else { return }
            
            Task {
                do {
                    if try await self.removeIssueType(issueType: issueType) {
                        self.viewModel.issueTypes.removeAll { $0.id == issueType.id }
                    } else {
                        self.viewModel.shouldShowFailureAlert = true
                    } 
                } catch {
                    VULogger.log(tag: .error, error)
                }
            }
        }
        presenter.bind(viewModel: self.viewModel)
        
        Task { [weak self] in
            do {
                self?.viewModel.issueTypes = try await self?.getIssueTypes() ?? []
            } catch {
                VULogger.log(tag: .error, error)
            }
        }
    }
    
}



extension IssueTypesRegistrarInteractor {
    
    
    func makeIssueType(name: String, slaDuration: String) async throws -> Bool {
        let request = try await component.networkingClient.gateway.postIssueType(.init(
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(data: .init(
                name: name,
                service_level_agreement_duration_hour: Int32(slaDuration)
            )))
        ))
        
        switch request {
            case .created(let response):
                if case let .json(jsonBody) = response.body {
                    guard 
                        let data = jsonBody.data, 
                        let id = data.id, 
                        let name = data.name, 
                        let duration = data.service_level_agreement_duration_hour 
                    else { return false }
                    
                    let newIssueType = FPIssueType(id: id, name: name, serviceLevelAgreementDurationHour: duration)
                    viewModel.issueTypes.append(newIssueType)
                    
                    viewModel.didIntendToAddIssueTypes = false
                    return true
                }
                
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return false
    }
    
    
    func getIssueTypes() async throws -> [FPIssueType] {
        let request = try await component.networkingClient.gateway.getIssueTypes(.init(
            headers: .init(accept: [.init(contentType: .json)])
        ))
        
        var types: [FPIssueType] = []
        
        switch request {
            case .ok(let response):
                if case let .json(payload) = response.body {
                    payload.data?.forEach { sla in 
                        guard let id = sla.id, let name = sla.name, let duration = sla.service_level_agreement_duration_hour else { return }
                        
                        types.append(.init(id: id, name: name, serviceLevelAgreementDurationHour: duration))
                    }
                }
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return types
    }
    
    
    func removeIssueType(issueType: FPIssueType) async throws -> Bool {
        let request = try await component.networkingClient.gateway.deleteIssueType(.init(
            path: .init(type_id: issueType.id), 
            headers: .init(accept: [.init(contentType: .json)])
        ))
        
        switch request {
            case .ok(let response):
                if case let .json(jsonBody) = response.body {
                    guard 
                        let data = jsonBody.data, 
                        let id = data.id, 
                        let name = data.name, 
                        let duration = data.service_level_agreement_duration_hour 
                    else { return false }
                    
                    viewModel.issueTypes.removeAll { $0.id == id }
                    
                    return true
                }
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return false
    }
    
} 



/// Conformance to the ``IssueTypesRegistrarPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``IssueTypesRegistrarViewController``.
extension IssueTypesRegistrarInteractor: IssueTypesRegistrarPresentableListener {
    
    
    func navigateBack(from origin: UIViewController) {
        listener?.respondToNavigateBack(from: origin)
    }
    
}
