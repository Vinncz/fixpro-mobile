import Observation

@Observable class CodeScanViewModel {
    
    var didScan: ((_ obfuscatedAreaJoinCodeInString: String) -> Void)?
    
    var scannerError: String = ""
    
}
