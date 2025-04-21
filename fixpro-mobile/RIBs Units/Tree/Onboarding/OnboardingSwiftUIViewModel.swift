import Foundation
import Observation



/// Bridges between ``OnboardingSwiftUIView`` and the ``OnboardingInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class OnboardingSwiftUIViewModel {
    
    
    // MARK: -- Navigations
    
    /// Signals the ``OnboardingInteractor`` to attach, transition, and display the `Operational Flow` on its discretion.
    /// Set by ``OnboardingInteractor``, invoked by ``OnboardingSwiftUIView``.
    var queOperationalFlow: (() -> Void)?
    
    
    /// Signals the ``OnboardingInteractor`` to attach and display `PairingRIB` on its discretion.
    /// Set by ``OnboardingInteractor``, invoked by ``OnboardingViewController``.
    var quePairingFlow: (() -> Void)?
    
    
    
    // MARK: -- State & its management
    var applicationReceipt: ApplicationReceipt?
    var cancelApplicationAndRemoveReceipt: (() -> Void)?
    
    var applicationState: ApplicationState = .undecided
    var refreshApplicationStatus: (() -> Void)?
    
    
    enum ApplicationState {
        case undecided
        case approvedAndReadyForTransition
        case rejected
        case expired
    }
    
}
