import Foundation
import RIBs



/// Type that is informed whenever a RIB tree is made.
protocol FPRIBReadyNotifying: AnyObject {
    
    
    /// Informs the implementor that a ``RootRouter`` is now present.
    func setRootInteractor(_ interactor: RootInteractable)
    
}
