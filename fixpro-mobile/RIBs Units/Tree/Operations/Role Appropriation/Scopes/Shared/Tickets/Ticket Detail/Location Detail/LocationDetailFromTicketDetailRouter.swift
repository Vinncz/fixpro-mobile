import RIBs



/// Contract adhered to by ``LocationDetailFromTicketDetailInteractor``, listing the attributes and/or actions 
/// that ``LocationDetailFromTicketDetailRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol LocationDetailFromTicketDetailInteractable: Interactable {
    var router: LocationDetailFromTicketDetailRouting? { get set }
    var listener: LocationDetailFromTicketDetailListener? { get set }
}



/// Contract adhered to by ``LocationDetailFromTicketDetailViewController``, listing the attributes and/or actions
/// that ``LocationDetailFromTicketDetailRouter`` is allowed to access or invoke.
protocol LocationDetailFromTicketDetailViewControllable: ViewControllable {
    
    
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



/// The attachment point of `LocationDetailFromTicketDetailRIB`.
final class LocationDetailFromTicketDetailRouter: ViewableRouter<LocationDetailFromTicketDetailInteractable, LocationDetailFromTicketDetailViewControllable> {
    
    
    /// Constructs an instance of ``LocationDetailFromTicketDetailRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: LocationDetailFromTicketDetailInteractable, viewController: LocationDetailFromTicketDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``LocationDetailFromTicketDetailRouting`` protocol.
/// Contains everything accessible or invokable by ``LocationDetailFromTicketDetailInteractor``.
extension LocationDetailFromTicketDetailRouter: LocationDetailFromTicketDetailRouting {}
