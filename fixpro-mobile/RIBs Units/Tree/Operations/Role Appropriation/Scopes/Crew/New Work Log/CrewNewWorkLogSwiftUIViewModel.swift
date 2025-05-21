import Foundation
import Observation



/// Bridges between ``CrewNewWorkLogSwiftUIView`` and the ``CrewNewWorkLogInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class CrewNewWorkLogSwiftUIViewModel {
    
    
    var selectedFiles: [URL] = [] { 
        didSet {
            validationLabel = .EMPTY
        }
    }
    
    
    var news: String = .EMPTY { 
        didSet {
            validationLabel = .EMPTY
        }
    }
    
    
    var logType: FPTIcketLogType = .select { 
        didSet {
            validationLabel = .EMPTY
        }
    }
    
    
    var validationLabel: String = .EMPTY
    
    
    var didIntendToDismiss: (()->Void)?
    
    
    var didIntendToAddWorkLog: (()->Void)?
    
    
    func reset() {
        news = .EMPTY
        selectedFiles = []
        logType = .select
        validationLabel = .EMPTY
    }
    
}
