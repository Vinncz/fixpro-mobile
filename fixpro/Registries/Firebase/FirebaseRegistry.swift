import Foundation
import FirebaseCore
import UIKit


/// The representation of state of Firebase services.
@Observable class FirebaseRegistry: NSObject {
    
    
    /// Constituently a singleton.
    private override init() {}
    
    
    /// The one instance of ``FirebaseRegistry`` per lifecycle.
    static let global = FirebaseRegistry()
    
    
    /// The source of truth for Firebase services' initialization status.
    /// 
    /// Instantiaion of this registry does not reflect whether Firebase client are up and running.
    /// This attribute checks for all the necessary conditions to determine if the shared instance of Firebase client is initialized.
    var isInitialized: Bool {
        FirebaseApp.app() != nil
    }
    
    
    /// Configures the firebase client to run with the given options.
    func configure(withOptions opts: FirebaseOptions) {
        FirebaseApp.configure(options: opts)
    }
    
    
    /// Configures the firebase client to run with the options provided by `GoogleServices-Info.plist`.
    func configure() {
        FirebaseApp.configure()
    }
    
}
