import Foundation
import VinUtility
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``TicketDetailInteractor``, listing the attributes and/or actions 
/// that ``TicketDetailViewController`` is allowed to access or invoke.
protocol TicketDetailPresentableListener: AnyObject {
    var component: TicketDetailComponent { get }
    func navigateBack()
    func didIntendToContribute()
    func didIntendToDelegateTicket()
    func didIntendToInviteTicket()
    func didIntendToEvaluateWork()
}
 
 

/// The visible region of `TicketDetailRIB`.
final class TicketDetailViewController: UIViewController {
    
    
    /// Reference to ``TicketDetailInteractor``.
    weak var presentableListener: TicketDetailPresentableListener?
    
    
    /// Reference to ``TicketDetailSwiftUIViewModel``.
    weak var viewModel: TicketDetailSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<TicketDetailSwiftUIView>?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ticket Details"
        self.hidesBottomBarWhenPushed = true
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupToolbar()
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            presentableListener?.navigateBack()
        }
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Constructs an instance of ``TicketDetailSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = TicketDetailSwiftUIView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)
        
        hostingController.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }
    
}



fileprivate extension TicketDetailViewController {
    
    
    func setupToolbar() {
        if let viewModel {
            switch viewModel.role {
                case .member: self.toolbarItems = makeMemberToolbar()
                case .crew: self.toolbarItems = makeCrewToolbar()
                case .management: self.toolbarItems = makeManagementToolbar()
            }
        }
    }
    
    
    func makeMemberToolbar() -> [UIBarButtonItem] {
        if let viewModel, let ticket = viewModel.ticket {
            let cancelAction = makeToolbarButton(
                title: "Cancel", 
                systemImage: "xmark.bin", 
                action: #selector(cancelTicket),
                isEnabled: [.open, .inAssessment].contains(ticket.status)
            )
            let evaluateAction = makeToolbarButton(
                title: "Evaluate works", 
                systemImage: "checkmark.circle.badge.xmark", 
                action: #selector(evaluateTicket),
                isEnabled: ticket.status == .ownerEvaluation
            )
            let printViewAction =  makeToolbarButton(
                title: "Print", 
                systemImage: "printer", 
                action: #selector(printViewTicket)
            )
            
            return [
                cancelAction, 
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                evaluateAction,
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                printViewAction
            ]
        }
        
        return []
    }
    
    
    func makeCrewToolbar() -> [UIBarButtonItem] {
        if let viewModel, let ticket = viewModel.ticket {
            let contributeAction = makeToolbarButton(
                title: "Contribute", 
                systemImage: "plus.square.on.square", 
                action: #selector(contributeToTicket),
                isEnabled: [.onProgress].contains(ticket.status)
            )
            let inviteAction = makeToolbarButton(
                title: "Invite", 
                systemImage: "person.2.badge.plus", 
                action: #selector(inviteToTicket),
                isEnabled: [.onProgress].contains(ticket.status)
            )
            let evaluateAction = makeToolbarButton(
                title: "Evaluate works", 
                systemImage: "checkmark.circle.badge.xmark", 
                action: #selector(evaluateTicket),
                isEnabled: [.workEvaluation].contains(ticket.status) 
                           && (presentableListener?.component.authorizationContext.capabilities.contains(.IssueSupervisorApproval) ?? false)
            )
            let printViewAction =  makeToolbarButton(
                title: "Print", 
                systemImage: "printer", 
                action: #selector(printViewTicket)
            )
            
            return [
                contributeAction, 
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                inviteAction,
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                evaluateAction,
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                printViewAction
            ]
        }
        
        return []
    }
    
    
    func makeManagementToolbar() -> [UIBarButtonItem] {
        if let viewModel, let ticket = viewModel.ticket {
            let rejectAction = makeToolbarButton(
                title: "Reject", 
                systemImage: "xmark.bin", 
                action: #selector(rejectTicket),
                isEnabled: [.open, .inAssessment].contains(ticket.status)
            )
            let delegateAction = makeToolbarButton(
                title: "Delegate", 
                systemImage: "person.2.badge.plus", 
                action: #selector(delegateTicket),
                isEnabled: [.onProgress].contains(ticket.status)
            )
            let contributeAction = makeToolbarButton(
                title: "Contribute", 
                systemImage: "plus.square.on.square", 
                action: #selector(contributeToTicket),
                isEnabled: [.open, .inAssessment, .onProgress, .workEvaluation, .qualityControl].contains(ticket.status)
            )
            let evaluateAction = makeToolbarButton(
                title: "Evaluate works", 
                systemImage: "checkmark.circle.badge.xmark", 
                action: #selector(evaluateTicket),
                isEnabled: [.workEvaluation, .qualityControl].contains(ticket.status)
            )
            let printViewAction =  makeToolbarButton(
                title: "Print", 
                systemImage: "printer", 
                action: #selector(printViewTicket)
            )
            
            VULogger.log("ticket status: \([.workEvaluation].contains(ticket.status))")
            VULogger.log("has enough capability: \((presentableListener?.component.authorizationContext.capabilities.contains(.IssueSupervisorApproval) == true))")
            VULogger.log("Combined: \([.workEvaluation].contains(ticket.status) && (presentableListener?.component.authorizationContext.capabilities.contains(.IssueSupervisorApproval) == true))")
            
            return [
                rejectAction,
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                delegateAction,
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                contributeAction, 
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                evaluateAction,
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), 
                printViewAction
            ]
        }
        
        return []
    }
    
    
    func makeToolbarButton(title: String, systemImage: String, action: Selector, isEnabled: Bool = true) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemImage), for: .normal)
//        button.setTitle(" " + title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.sizeToFit()
        
        let barButton = UIBarButtonItem(customView: button)
        barButton.isEnabled = isEnabled
        return barButton
    }
    
    
    @objc func cancelTicket() {
        if let viewModel {
            viewModel.shouldShowCancellationAlert = true
        }
    }
    
    
    @objc func rejectTicket() {
        if let viewModel {
            viewModel.shouldShowRejectionAlert = true
        }
    }
    
    
    @objc func inviteToTicket() {
        presentableListener?.didIntendToInviteTicket()
    }
    
    
    @objc func delegateTicket() {
        presentableListener?.didIntendToDelegateTicket()
    }
    
    
    @objc func contributeToTicket() {
        presentableListener?.didIntendToContribute()
    }
    
    
    @objc func evaluateTicket() {
        presentableListener?.didIntendToEvaluateWork()
    }
    
    
    @objc func printViewTicket() {
        if let viewModel {
            viewModel.shouldShowPrintView = true
        }
    }
    
}



/// Conformance to the ``TicketDetailViewControllable`` protocol.
/// Contains everything accessible or invokable by ``TicketDetailRouter``.
extension TicketDetailViewController: TicketDetailViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy OVER the ``hostingViewController``.
    /// - Parameter newFlow: The `ViewControllable` to be inserted.
    /// - Parameter completion: A closure to be executed after the insertion is complete.
    /// 
    /// The default implementation of this method adds the new `ViewControllable` as a child view controller
    /// and adds its view as a subview of the current view controller's view.
    /// - Note: The default implementation of this method REMOVES the previous `ViewControllable` from the view hierarchy.
    func transition(to newFlow: any ViewControllable, completion: (() -> Void)?) {
        Task { @MainActor in
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = newFlow
            
            self.addChild(newFlow.uiviewController)
            self.view.addSubview(newFlow.uiviewController.view)
            newFlow.uiviewController.didMove(toParent: self)
            
            completion?()
        }
    }
    
    
    /// Clears any `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    /// 
    /// The default implementation of this method removes the current `ViewControllable` from the view hierarchy.
    func cleanUp(completion: (() -> Void)?) {
        Task { @MainActor in
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            self.activeFlow?.uiviewController.dismiss(animated: true)
            
            self.activeFlow = nil
            
            completion?()
        }
    }
    
    
    func present(newFlow: any ViewControllable, completion: (() -> Void)?) {
        Task { @MainActor in
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = newFlow
            
            self.present(newFlow.uiviewController, animated: true)
            newFlow.uiviewController.didMove(toParent: self)
            
            completion?()
        }
    }
    
}



/// Conformance extension to the ``TicketDetailPresentable`` protocol.
/// Contains everything accessible or invokable by ``TicketDetailInteractor``.
extension TicketDetailViewController: TicketDetailPresentable {
    
    
    /// Binds the ``TicketDetailSwiftUIViewModel`` to the view controller.
    func bind(viewModel: TicketDetailSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``TicketDetailSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
    
    func updateToolbar() {
        setupToolbar()
    }
    
}
