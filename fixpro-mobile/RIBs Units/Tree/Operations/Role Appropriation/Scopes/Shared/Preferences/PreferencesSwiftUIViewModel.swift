import Foundation
import Observation



/// Bridges between ``PreferencesSwiftUIView`` and the ``PreferencesInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class PreferencesSwiftUIViewModel {
    
    
    var logOut: (()->Void)?
    
}
