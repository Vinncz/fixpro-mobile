import RIBs



/// Contract adhered to by ``WorkCalendarInteractor``, listing the attributes and/or actions 
/// that ``WorkCalendarRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol WorkCalendarInteractable: Interactable {
    var router: WorkCalendarRouting? { get set }
    var listener: WorkCalendarListener? { get set }
}



/// Contract adhered to by ``WorkCalendarViewController``, listing the attributes and/or actions
/// that ``WorkCalendarRouter`` is allowed to access or invoke.
protocol WorkCalendarViewControllable: ViewControllable {
    
    
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



/// The attachment point of `WorkCalendarRIB`.
final class WorkCalendarRouter: ViewableRouter<WorkCalendarInteractable, WorkCalendarViewControllable> {
    
    
    /// Constructs an instance of ``WorkCalendarRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: WorkCalendarInteractable, viewController: WorkCalendarViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``WorkCalendarRouting`` protocol.
/// Contains everything accessible or invokable by ``WorkCalendarInteractor``.
extension WorkCalendarRouter: WorkCalendarRouting {}
