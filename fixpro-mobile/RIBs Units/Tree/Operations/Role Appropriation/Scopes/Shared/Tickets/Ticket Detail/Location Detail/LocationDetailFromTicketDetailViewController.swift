import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``LocationDetailFromTicketDetailInteractor``, listing the attributes and/or actions 
/// that ``LocationDetailFromTicketDetailViewController`` is allowed to access or invoke.
protocol LocationDetailFromTicketDetailPresentableListener: AnyObject {}
 
 

/// The visible region of `LocationDetailFromTicketDetailRIB`.
final class LocationDetailFromTicketDetailViewController: UIViewController {
    
    
    /// Reference to ``LocationDetailFromTicketDetailInteractor``.
    weak var presentableListener: LocationDetailFromTicketDetailPresentableListener?
    
    
    /// Reference to ``LocationDetailFromTicketDetailSwiftUIViewModel``.
    weak var viewModel: LocationDetailFromTicketDetailSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<LocationDetailFromTicketDetailSwiftUIView>?
    
    
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
    
    
    /// Constructs an instance of ``LocationDetailFromTicketDetailSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = LocationDetailFromTicketDetailSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``LocationDetailFromTicketDetailViewControllable`` protocol.
/// Contains everything accessible or invokable by ``LocationDetailFromTicketDetailRouter``.
extension LocationDetailFromTicketDetailViewController: LocationDetailFromTicketDetailViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy OVER the ``hostingViewController``.
    /// - Parameter newFlow: The `ViewControllable` to be inserted.
    /// - Parameter completion: A closure to be executed after the insertion is complete.
    /// 
    /// The default implementation of this method adds the new `ViewControllable` as a child view controller
    /// and adds its view as a subview of the current view controller's view.
    /// - Note: The default implementation of this method REMOVES the previous `ViewControllable` from the view hierarchy.
    func transition(to newFlow: any ViewControllable, completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = nil
            
            completion?()
        }
    }
    
}



/// Conformance extension to the ``LocationDetailFromTicketDetailPresentable`` protocol.
/// Contains everything accessible or invokable by ``LocationDetailFromTicketDetailInteractor``.
extension LocationDetailFromTicketDetailViewController: LocationDetailFromTicketDetailPresentable {
    
    
    /// Binds the ``LocationDetailFromTicketDetailSwiftUIViewModel`` to the view controller.
    func bind(viewModel: LocationDetailFromTicketDetailSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``LocationDetailFromTicketDetailSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
