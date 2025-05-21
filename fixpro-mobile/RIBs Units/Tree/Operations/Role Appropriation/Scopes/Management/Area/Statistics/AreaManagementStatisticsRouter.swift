import RIBs



/// Contract adhered to by ``AreaManagementStatisticsInteractor``, listing the attributes and/or actions 
/// that ``AreaManagementStatisticsRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol AreaManagementStatisticsInteractable: Interactable {
    
    
    /// Reference to ``AreaManagementStatisticsRouter``.
    var router: AreaManagementStatisticsRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: AreaManagementStatisticsListener? { get set }
    
}



/// Contract adhered to by ``AreaManagementStatisticsViewController``, listing the attributes and/or actions
/// that ``AreaManagementStatisticsRouter`` is allowed to access or invoke.
protocol AreaManagementStatisticsViewControllable: ViewControllable {
    
    
    /// Attaches the given `ViewControllable` into the view hierarchy, becoming the top-most view controller.
    /// - Parameter newFlow: The `ViewControllable` to be attached.
    /// - Parameter completion: A closure to be executed after the operation is complete.
    /// 
    /// > Note: You are responsible for removing the previous `ViewControllable` from the view hierarchy.
    func attach(newFlow: ViewControllable, completion: (() -> Void)?)
    
    
    /// Clears the  `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    func clear(completion: (() -> Void)?)
    
    
    /// Removes the hosting controller from the view hierarchy and deallocates it.
    func nilHostingViewController()
    
}



/// The attachment point of `AreaManagementStatisticsRIB`.
final class AreaManagementStatisticsRouter: ViewableRouter<AreaManagementStatisticsInteractable, AreaManagementStatisticsViewControllable> {
    
    
    /// Constructs an instance of ``AreaManagementStatisticsRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: AreaManagementStatisticsInteractable, viewController: AreaManagementStatisticsViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didLoad() {}
    
}



/// Conformance extension to the ``AreaManagementStatisticsRouting`` protocol.
/// Contains everything accessible or invokable by ``AreaManagementStatisticsInteractor``.
extension AreaManagementStatisticsRouter: AreaManagementStatisticsRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers() {
        viewController.clear(completion: nil)
        // TODO: detach any child RIBs
        // TODO: nullify any references to child RIBs
    }
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI() {
        viewController.nilHostingViewController()
    }
    
}
