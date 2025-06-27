import Foundation
import Observation



/// Bridges between ``AreaJoinningCodeScanningSwiftUIView`` and the ``AreaJoinningCodeScanningInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class AreaJoinningCodeScanningSwiftUIViewModel {
    
    var isScanning: Bool = false
    
    var isInputingManually: Bool = false
    
    var didScan: ((_ obfuscatedAreaJoinCodeInString: String) -> Void)?
    
    var scannerError: String = ""
    
}
