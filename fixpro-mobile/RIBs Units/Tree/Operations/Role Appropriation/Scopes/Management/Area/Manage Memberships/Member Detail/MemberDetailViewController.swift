import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit
import VinUtility



/// Contract adhered to by ``MemberDetailInteractor``, listing the attributes and/or actions 
/// that ``MemberDetailViewController`` is allowed to access or invoke.
protocol MemberDetailPresentableListener: AnyObject {
    func navigateBack(from: UIViewController)
}
 
 

/// The visible region of `MemberDetailRIB`.
final class MemberDetailViewController: UIViewController {
    
    
    /// Reference to ``MemberDetailInteractor``.
    weak var presentableListener: MemberDetailPresentableListener?
    
    
    /// Reference to ``MemberDetailSwiftUIViewModel``.
    weak var viewModel: MemberDetailSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<MemberDetailSwiftUIView>?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        title = "Member Detail"
        hidesBottomBarWhenPushed = true
        let removeAction = makeToolbarButton(title: "Remove", systemImage: "trash", action: #selector(didIntendToRemove), color: .red)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.toolbarItems = [removeAction, spacer]
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
    
    
    /// Constructs an instance of ``MemberDetailSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = MemberDetailSwiftUIView(viewModel: viewModel)
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
    
    
    func makeToolbarButton(title: String, systemImage: String, action: Selector, color: UIColor = .tintColor) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemImage), for: .normal)
        button.setTitle(" " + title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.tintColor = color
        button.sizeToFit()

        return UIBarButtonItem(customView: button)
    }
    
    
    @objc func didIntendToRemove() {
        viewModel?.didIntendToRemove = true
    }
    
}



/// Conformance to the ``MemberDetailViewControllable`` protocol.
/// Contains everything accessible or invokable by ``MemberDetailRouter``.
extension MemberDetailViewController: MemberDetailViewControllable {
    
    
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



/// Conformance extension to the ``MemberDetailPresentable`` protocol.
/// Contains everything accessible or invokable by ``MemberDetailInteractor``.
extension MemberDetailViewController: MemberDetailPresentable {
    
    
    /// Binds the ``MemberDetailSwiftUIViewModel`` to the view controller.
    func bind(viewModel: MemberDetailSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``MemberDetailSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
