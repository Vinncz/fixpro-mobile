import RIBs



/// Contract adhered to by ``RoleAppropriationInteractor``, listing the attributes and/or actions 
/// that ``RoleAppropriationRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol RoleAppropriationInteractable: Interactable {
    
    
    /// Reference to ``RoleAppropriationRouter``.
    var router: RoleAppropriationRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: RoleAppropriationListener? { get set }
    
}



/// Contract adhered to by ``RoleAppropriationViewController``, listing the attributes and/or actions
/// that ``RoleAppropriationRouter`` is allowed to access or invoke.
protocol RoleAppropriationViewControllable: ViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy.
    /// - Parameter newFlow: The `ViewControllable` to be inserted.
    /// - Parameter completion: A closure to be executed after the insertion is complete.
    /// 
    /// The default implementation of this method adds the new `ViewControllable` as a child view controller
    /// and adds its view as a subview of the current view controller's view.
    /// - Note: The default implementation of this method REMOVES the previous `ViewControllable` from the view hierarchy.
    func transition(to newFlow: ViewControllable, completion: (() -> Void)?)
    
    
    /// Clears any `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    /// 
    /// The default implementation of this method removes the current `ViewControllable` from the view hierarchy.
    func cleanUp(completion: (() -> Void)?)
    
}



/// The attachment point of `RoleAppropriationRIB`.
final class RoleAppropriationRouter: ViewableRouter<RoleAppropriationInteractable, RoleAppropriationViewControllable> {
    
    
    /// Constructs an instance of ``RoleAppropriationRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: RoleAppropriationInteractable, viewController: RoleAppropriationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``RoleAppropriationRouting`` protocol.
/// Contains everything accessible or invokable by ``RoleAppropriationInteractor``.
extension RoleAppropriationRouter: RoleAppropriationRouting {}
