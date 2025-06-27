import Foundation
import VinUtility
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``IssueTypesRegistrarInteractor``, listing the attributes and/or actions 
/// that ``IssueTypesRegistrarViewController`` is allowed to access or invoke.
protocol IssueTypesRegistrarPresentableListener: AnyObject {
    func navigateBack(from origin: UIViewController)
}
 
 

/// The visible region of `IssueTypesRegistrarRIB`.
final class IssueTypesRegistrarViewController: UIViewController {
    
    
    /// Reference to ``IssueTypesRegistrarInteractor``.
    weak var presentableListener: IssueTypesRegistrarPresentableListener?
    
    
    /// Reference to ``IssueTypesRegistrarSwiftUIViewModel``.
    weak var viewModel: IssueTypesRegistrarSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<IssueTypesRegistrarSwiftUIView>?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        title = "Issue Types Registrar"
        hidesBottomBarWhenPushed = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            presentableListener?.navigateBack(from: self)
        }
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Constructs an instance of ``IssueTypesRegistrarSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = IssueTypesRegistrarSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``IssueTypesRegistrarViewControllable`` protocol.
/// Contains everything accessible or invokable by ``IssueTypesRegistrarRouter``.
extension IssueTypesRegistrarViewController: IssueTypesRegistrarViewControllable {
    
    
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



/// Conformance extension to the ``IssueTypesRegistrarPresentable`` protocol.
/// Contains everything accessible or invokable by ``IssueTypesRegistrarInteractor``.
extension IssueTypesRegistrarViewController: IssueTypesRegistrarPresentable {
    
    
    /// Binds the ``IssueTypesRegistrarSwiftUIViewModel`` to the view controller.
    func bind(viewModel: IssueTypesRegistrarSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``IssueTypesRegistrarSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
