import RIBs



/// Contract adhered to by ``TicketReportInteractor``, listing the attributes and/or actions 
/// that ``TicketReportRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol TicketReportInteractable: Interactable {
    
    
    /// Reference to ``TicketReportRouter``.
    var router: TicketReportRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: TicketReportListener? { get set }
    
}



/// Contract adhered to by ``TicketReportViewController``, listing the attributes and/or actions
/// that ``TicketReportRouter`` is allowed to access or invoke.
protocol TicketReportViewControllable: ViewControllable {
    
    
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



/// The attachment point of `TicketReportRIB`.
final class TicketReportRouter: ViewableRouter<TicketReportInteractable, TicketReportViewControllable> {
    
    
    /// Constructs an instance of ``TicketReportRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: TicketReportInteractable, viewController: TicketReportViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didLoad() {}
    
}



/// Conformance extension to the ``TicketReportRouting`` protocol.
/// Contains everything accessible or invokable by ``TicketReportInteractor``.
extension TicketReportRouter: TicketReportRouting {
    
    
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
