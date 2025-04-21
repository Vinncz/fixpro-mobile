import Foundation
import Observation



/// Bridges between ``AreaJoinningFormFillingSwiftUIView`` and the ``AreaJoinningFormFillingInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class AreaJoinningFormFillingSwiftUIViewModel {
    
    
    var fieldsAndAnswers: [String: String] = [:]
    
    
    var didSubmit: (([String: String]) -> Void)?
    
    
    var filloutValidationLabel: String = ""
    
}
