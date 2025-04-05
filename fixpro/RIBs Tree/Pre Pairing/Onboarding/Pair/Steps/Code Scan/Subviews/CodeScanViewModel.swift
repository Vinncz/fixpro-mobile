import Observation

@Observable class CodeScanViewModel {
    
    var isScanning: Bool = false
    
    var didScan: ((_ obfuscatedAreaJoinCodeInString: String) -> Void)?
    
    var scannerError: String = ""
    
}
