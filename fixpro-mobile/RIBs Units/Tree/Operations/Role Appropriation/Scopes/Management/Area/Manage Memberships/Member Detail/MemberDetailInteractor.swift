import RIBs
import VinUtility
import UIKit
import RxSwift



/// Contract adhered to by ``MemberDetailRouter``, listing the attributes and/or actions 
/// that ``MemberDetailInteractor`` is allowed to access or invoke.
protocol MemberDetailRouting: ViewableRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI()
    
}



/// Contract adhered to by ``MemberDetailViewController``, listing the attributes and/or actions
/// that ``MemberDetailInteractor`` is allowed to access or invoke.
protocol MemberDetailPresentable: Presentable {
    
    
    /// Reference to ``MemberDetailInteractor``.
    var presentableListener: MemberDetailPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: MemberDetailSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `MemberDetailRIB`'s parent, listing the attributes and/or actions
/// that ``MemberDetailInteractor`` is allowed to access or invoke.
protocol MemberDetailListener: AnyObject {
    func didRemove(member: FPPerson)
    func respondToNavigateBack(from origin: UIViewController)
}



/// The functionality centre of `MemberDetailRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class MemberDetailInteractor: PresentableInteractor<MemberDetailPresentable>, MemberDetailInteractable {
    
    
    /// Reference to ``MemberDetailRouter``.
    weak var router: MemberDetailRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: MemberDetailListener?
    
    
    /// Reference to the component of this RIB.
    var component: MemberDetailComponent
    
    
    /// Bridge to the ``MemberDetailSwiftUIVIew``.
    private var viewModel: MemberDetailSwiftUIViewModel
    
    
    private var member: FPPerson
    
    
    /// Constructs an instance of ``MemberDetailInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: MemberDetailComponent, presenter: MemberDetailPresentable, member: FPPerson) {
        self.component = component
        self.member = member
        self.viewModel = MemberDetailSwiftUIViewModel(member: member)
        
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
        viewModel.didRemove = { [weak self] in
            guard let self else { return }
            Task { 
                if try await self.deleteAreaMember() {
                    Task { @MainActor in
                        self.listener?.didRemove(member: self.member)
                    }
                }
            }
        }
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension MemberDetailInteractor {
    
    
    func deleteAreaMember() async throws -> Bool {
        let request = try await component.networkingClient.gateway.deleteAreaMember(.init(path: .init(member_id: member.id)))
        
        switch request {
            case .accepted:
                return true
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
                return false
        }
    }
    
}



/// Conformance to the ``MemberDetailPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``MemberDetailViewController``.
extension MemberDetailInteractor: MemberDetailPresentableListener {
    
    
    func navigateBack(from origin: UIViewController) {
        listener?.respondToNavigateBack(from: origin)
    }
    
}
