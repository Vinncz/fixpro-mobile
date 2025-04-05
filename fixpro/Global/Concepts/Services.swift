import Foundation


/// The base type for all FixPro Mobile services.
protocol FPService {}


/// Services which maintain an internal state or context.
/// 
/// Conformance to this protocol is decorative; marking the service
/// as stateful. It does not enforce any specific behavior or
/// implementation details.
protocol FPStatefulService: FPService {}


/// Services which does not maintain an internal state or context.
/// 
/// Conformance to this protocol is decorative; marking the service
/// as stateless. It does not enforce any specific behavior or
/// implementation details.
protocol FPStatelessService: FPService {}


/// Services which precede other services that may depend on them.
protocol FPAntecedentService: FPService {}


/// Services which are compatible with being transitioned to,
/// and continue on the responsibility of another service.
protocol FPTransitionCompatibleService: FPService {}


/// Services which operates at a transitional or intermediate stage;
/// facilitating the handover of its state, responsibility, or functionality
/// to another service once its role is fulfilled.
/// 
/// Conformance to this protocol requires your service to be able to gracefully
/// manage transitions, ensuring continuity and consistency.
protocol FPLiminalService: FPService {
    
    
    /// The type of the service that will take over the responsibility.
    associatedtype NextService: FPTransitionCompatibleService
    
    
    /// The service that will take over the responsibility once this service
    /// has completed its task.
    var nextService: NextService? { get set }
    
    
    /// Initiates the transition to the next service.
    func transitionToNextService()
    
    
    /// Handles any cleanup or finalization before transitioning.
    func finalizeTransition()
    
}
