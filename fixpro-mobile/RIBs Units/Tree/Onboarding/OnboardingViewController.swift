import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``OnboardingInteractor``, listing the attributes and/or actions 
/// that ``OnboardingViewController`` is allowed to access or invoke.
protocol OnboardingPresentableListener: AnyObject {}
 
 

/// The visible region of `OnboardingRIB`.
final class OnboardingViewController: UIViewController {
    
    
    /// Reference to ``OnboardingInteractor``.
    weak var presentableListener: OnboardingPresentableListener?
    
    
    /// Reference to ``OnboardingSwiftUIViewModel``.
    weak var viewModel: OnboardingSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<OnboardingSwiftUIView>?
    
    
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
    
    
    /// Constructs an instance of ``OnboardingSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = OnboardingSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``OnboardingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``OnboardingRouter``
extension OnboardingViewController: OnboardingViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy.
    /// - Parameter newFlow: The `ViewControllable` to be inserted.
    /// - Parameter completion: A closure to be executed after the insertion is complete.
    /// 
    /// The default implementation of this method adds the new `ViewControllable` as a child view controller
    /// and adds its view as a subview of the current view controller's view.
    /// - Note: The default implementation of this method REMOVES the previous `ViewControllable` from the view hierarchy.
    func transition(to newFlow: any ViewControllable, completion: (() -> Void)?) {
        self.activeFlow?.uiviewController.view.removeFromSuperview()
        self.activeFlow?.uiviewController.removeFromParent()
        
        self.activeFlow = newFlow
        
        self.addChild(newFlow.uiviewController)
        self.view.addSubview(newFlow.uiviewController.view)
        newFlow.uiviewController.didMove(toParent: self)
        
        completion?()
    }
    
    
    /// Clears any `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    /// 
    /// The default implementation of this method removes the current `ViewControllable` from the view hierarchy.
    func cleanUp(completion: (() -> Void)?) {
        self.activeFlow?.uiviewController.view.removeFromSuperview()
        self.activeFlow?.uiviewController.removeFromParent()
        
        self.activeFlow = nil
        
        completion?()
    }
    
    
    func present(_ flow: any ViewControllable) {
        self.activeFlow = flow
        self.present(flow.uiviewController, animated: true)
    }
    
    
    func dismiss(withoutDetachingView: Bool) {
        if let activeFlow {
            self.dismiss(animated: true)
            
            if !withoutDetachingView {
                activeFlow.uiviewController.view.removeFromSuperview()
                activeFlow.uiviewController.removeFromParent()
            }
            
            self.activeFlow = nil
        }
    }
    
}



/// Conformance extension to the ``OnboardingPresentable`` protocol.
/// Contains everything accessible or invokable by ``OnboardingInteractor``
extension OnboardingViewController: OnboardingPresentable {
    
    
    /// Binds the ``OnboardingSwiftUIViewModel`` to the view controller.
    func bind(viewModel: OnboardingSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``OnboardingSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
