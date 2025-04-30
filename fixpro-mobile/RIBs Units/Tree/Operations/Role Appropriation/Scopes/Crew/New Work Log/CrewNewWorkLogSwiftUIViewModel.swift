import Foundation
import Observation



/// Bridges between ``CrewNewWorkLogSwiftUIView`` and the ``CrewNewWorkLogInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class CrewNewWorkLogSwiftUIViewModel {
    
    
    var selectedFiles: [URL] = []
    
    
    var workDescription: String = .EMPTY
    
    
    var logType: FPTIcketLogType = .select
    
    
    var validationLabel: String = .EMPTY
    
    
    var didIntendToDismiss: (()->Void)?
    
    
    var didIntendToAddWorkLog: (()->Void)?
    
}
