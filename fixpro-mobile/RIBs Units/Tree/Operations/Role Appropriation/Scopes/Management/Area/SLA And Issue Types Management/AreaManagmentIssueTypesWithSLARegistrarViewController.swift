import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``AreaManagmentIssueTypesWithSLARegistrarInteractor``, listing the attributes and/or actions 
/// that ``AreaManagmentIssueTypesWithSLARegistrarViewController`` is allowed to access or invoke.
protocol AreaManagmentIssueTypesWithSLARegistrarPresentableListener: AnyObject {
    func navigateBack()
}
 
 

/// The visible region of `AreaManagmentIssueTypesWithSLARegistrarRIB`.
final class AreaManagmentIssueTypesWithSLARegistrarViewController: UIViewController {
    
    
    /// Reference to ``AreaManagmentIssueTypesWithSLARegistrarInteractor``.
    weak var presentableListener: AreaManagmentIssueTypesWithSLARegistrarPresentableListener?
    
    
    /// Reference to ``AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel``.
    weak var viewModel: AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<AreaManagmentIssueTypesWithSLARegistrarSwiftUIView>?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            presentableListener?.navigateBack()
        }
    }
    
    /// Constructs an instance of ``AreaManagmentIssueTypesWithSLARegistrarSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = AreaManagmentIssueTypesWithSLARegistrarSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``AreaManagmentIssueTypesWithSLARegistrarViewControllable`` protocol.
/// Contains everything accessible or invokable by ``AreaManagmentIssueTypesWithSLARegistrarRouter``.
extension AreaManagmentIssueTypesWithSLARegistrarViewController: AreaManagmentIssueTypesWithSLARegistrarViewControllable {
    
    
    /// Attaches the given `ViewControllable` into the view hierarchy, becoming the top-most view controller.
    /// - Parameter newFlow: The `ViewControllable` to be attached.
    /// - Parameter completion: A closure to be executed after the operation is complete.
    /// 
    /// > Note: You are responsible for removing the previous `ViewControllable` from the view hierarchy.
    func attach(newFlow: ViewControllable, completion: (() -> Void)?) {
        self.activeFlow = newFlow
        
        self.addChild(newFlow.uiviewController)
        self.view.addSubview(newFlow.uiviewController.view)
        newFlow.uiviewController.didMove(toParent: self)
        
        completion?()
    }
    
    
    /// Clears the  `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    func clear(completion: (() -> Void)?) {
        self.activeFlow?.uiviewController.view.removeFromSuperview()
        self.activeFlow?.uiviewController.removeFromParent()
        self.activeFlow = nil
        
        completion?()
    }
    
    
    /// Removes the hosting controller from the view hierarchy and deallocates it.
    func nilHostingViewController() {
        if let hostingController {
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
            hostingController.didMove(toParent: nil)
        }
        
        self.hostingController = nil
    }
    
}



/// Conformance extension to the ``AreaManagmentIssueTypesWithSLARegistrarPresentable`` protocol.
/// Contains everything accessible or invokable by ``AreaManagmentIssueTypesWithSLARegistrarInteractor``.
extension AreaManagmentIssueTypesWithSLARegistrarViewController: AreaManagmentIssueTypesWithSLARegistrarPresentable {
    
    
    /// Binds the ``AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel`` to the view controller.
    func bind(viewModel: AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
