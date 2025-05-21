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
    func navigateBack()
    func didIntedToCloseTicket()
    func didIntendToAddWorkReport()
    func didIntendToDelegateTicket()
    func didIntendToEvaluateWorkReport()
    func didIntendToSeeTicketReport()
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
        
        setupToolbar()
        
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
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
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        var items = [UIBarButtonItem]()
        
        switch viewModel.role {
            case .member:
                let cancelTicketButton = createToolbarButton(
                    title: "Cancel ticket", 
                    systemImage: "xmark.bin", 
                    actionHandler: {  [weak self] in
                        self?.presentableListener?.didIntedToCloseTicket()
                    },
                    isEnabled: viewModel.status == .open
                )
                items.append(cancelTicketButton)
                
                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                
                let printViewButton = createToolbarButton(
                    title: "Print", 
                    systemImage: "printer.inverse", 
                    actionHandler: { [weak self] in
                        self?.presentableListener?.didIntendToSeeTicketReport()
                    },
                    isEnabled: viewModel.status != nil
                )
                items.append(printViewButton)
                
            case .crew:
                let addWorkReportButton = createToolbarButton(
                    title: "Add work report", 
                    systemImage: "document.viewfinder", 
                    actionHandler: { [weak self] in
                        self?.presentableListener?.didIntendToAddWorkReport()
                    },
                    isEnabled: ![.open, .inAssessment, .workEvaluation, .closed, .cancelled, .rejected].contains(viewModel.status) && viewModel.status != nil
                )
                items.append(addWorkReportButton)

                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                
                let printViewButton =  createToolbarButton(
                    title: "Print", 
                    systemImage: "printer.inverse", 
                    actionHandler: { [weak self] in 
                        self?.presentableListener?.didIntendToSeeTicketReport()
                    },
                    isEnabled: viewModel.status != nil
                )
                items.append(printViewButton)
                
            case .management:
                if viewModel.status == .workEvaluation {
                    let evaluateWorkReportButton = createToolbarButton(
                        title: "Evaluate work report(s)", 
                        systemImage: "pencil.and.list.clipboard", 
                        actionHandler: { [weak self] in 
                            self?.presentableListener?.didIntendToEvaluateWorkReport()
                        }
                    )
                    items.append(evaluateWorkReportButton)
                } else {
                    let delegateTicketButton = createToolbarButton(
                        title: "Delegate ticket", 
                        systemImage: "person.badge.plus", 
                        actionHandler: {  [weak self] in
                            self?.presentableListener?.didIntendToDelegateTicket()
                        },
                        isEnabled: ![.workEvaluation, .closed, .cancelled, .rejected].contains(viewModel.status) && viewModel.status != nil
                    )
                    items.append(delegateTicketButton)
                }

                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                
                let cancelTicketButton = createToolbarButton(
                    title: "Cancel ticket", 
                    systemImage: "xmark.bin", 
                    actionHandler: {  [weak self] in
                        self?.presentableListener?.didIntedToCloseTicket()
                    },
                    isEnabled: [.open, .inAssessment, .onProgress, .workEvaluation].contains(viewModel.status)
                )
                items.append(cancelTicketButton)
                
                items.append(UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil))
                
                let printViewButton =  createToolbarButton(
                    title: "Print", 
                    systemImage: "printer.inverse", 
                    actionHandler: {  [weak self] in
                        self?.presentableListener?.didIntendToSeeTicketReport()
                    },
                    isEnabled: viewModel.status != nil
                )
                items.append(printViewButton)
        }
        self.toolbarItems = items
    }
    
    class ActionWrapper: NSObject {
        let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func invoke() {
            action()
        }
    }
    
    
    func createToolbarButton(title: String, systemImage: String, actionHandler: @escaping () -> Void, isEnabled: Bool = true) -> UIBarButtonItem {
        let actionWrapper = ActionWrapper(action: actionHandler)
        let button = UIBarButtonItem(title: title, style: .plain, target: actionWrapper, action: #selector(ActionWrapper.invoke))
        button.image = UIImage(systemName: systemImage)
        button.isEnabled = isEnabled
        
        // Strongly associate the action wrapper so it doesn't deallocate
        objc_setAssociatedObject(button, "[\(UUID())]", actionWrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return button
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
