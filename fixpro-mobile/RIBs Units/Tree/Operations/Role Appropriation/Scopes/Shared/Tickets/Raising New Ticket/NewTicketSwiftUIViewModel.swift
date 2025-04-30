import Foundation
import Observation



/// Bridges between ``NewTicketSwiftUIView`` and the ``NewTicketInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class NewTicketSwiftUIViewModel {
    
    
    var statedIssue: String = "" {
        didSet {
            errorLabel = nil
        }
    }
    
    
    var statedLocation: String = "" {
        didSet {
            errorLabel = nil
        }
    }
    
    
    var issueType: FPIssueType = .select {
        didSet {
            errorLabel = nil
        }
    }
    
    
    var suggestedResponseLevel: FPIssueTicketResponseLevel = .normal {
        didSet {
            errorLabel = nil
        }
    }
    
    
    var errorLabel: String?
    
    
    var selectedFiles: [URL] = [] {
        didSet {
            errorLabel = nil
        }
    }
    
    
    var didIntendToSubmit: () -> Void = {}
    
    
    func reset() {
        self.statedIssue = .EMPTY
        self.statedLocation = .EMPTY
        self.issueType = .select
        self.suggestedResponseLevel = .normal
        self.errorLabel = nil
        self.selectedFiles = []
    }
    
}
