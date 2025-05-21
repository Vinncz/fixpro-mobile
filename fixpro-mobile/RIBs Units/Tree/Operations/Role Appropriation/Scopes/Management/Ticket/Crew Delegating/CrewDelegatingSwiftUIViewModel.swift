import Foundation
import Observation



/// Bridges between ``CrewDelegatingSwiftUIView`` and the ``CrewDelegatingInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class CrewDelegatingSwiftUIViewModel {
    
    
    var availablePersonnel: [FPPerson] = []
    
    
    var selectedPersonnel: [FPPerson] = [] {
        didSet {
            validationLabel = .EMPTY
        }
    }
    
    
    var executiveSummary: String = .EMPTY {
        didSet {
            validationLabel = .EMPTY
        }
    }
    
    
    func toggleSelection(for person: FPPerson) {
        if selectedPersonnel.contains(person) {
            selectedPersonnel.removeAll(where: {$0 == person})
        } else {
            selectedPersonnel.append(person)
        }
    }
    
    
    var validationLabel: String = .EMPTY
    
    
    var didIntendToDismiss: (()->Void)?
    
    
    var didIntendToDelegate: (()->Void)?
    
}
