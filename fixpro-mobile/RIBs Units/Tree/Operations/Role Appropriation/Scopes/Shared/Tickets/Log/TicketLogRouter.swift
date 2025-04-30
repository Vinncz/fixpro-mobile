import RIBs



/// Contract adhered to by ``TicketLogInteractor``, listing the attributes and/or actions 
/// that ``TicketLogRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol TicketLogInteractable: Interactable {
    
    
    /// Reference to ``TicketLogRouter``.
    var router: TicketLogRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: TicketLogListener? { get set }
    
}



/// Contract adhered to by ``TicketLogViewController``, listing the attributes and/or actions
/// that ``TicketLogRouter`` is allowed to access or invoke.
protocol TicketLogViewControllable: ViewControllable {
    
    
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



/// The attachment point of `TicketLogRIB`.
final class TicketLogRouter: ViewableRouter<TicketLogInteractable, TicketLogViewControllable> {
    
    
    /// Constructs an instance of ``TicketLogRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: TicketLogInteractable, viewController: TicketLogViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didLoad() {}
    
}



/// Conformance extension to the ``TicketLogRouting`` protocol.
/// Contains everything accessible or invokable by ``TicketLogInteractor``.
extension TicketLogRouter: TicketLogRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func cleanupViews() {
        viewController.clear(completion: nil)
        // TODO: detach any child RIBs
        // TODO: nullify any references to child RIBs
    }
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func removeSwiftUI() {
        viewController.nilHostingViewController()
    }
    
}
