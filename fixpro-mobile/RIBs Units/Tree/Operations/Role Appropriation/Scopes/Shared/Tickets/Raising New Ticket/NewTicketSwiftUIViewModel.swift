import Foundation
import Observation



/// Bridges between ``NewTicketSwiftUIView`` and the ``NewTicketInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class NewTicketSwiftUIViewModel {
    
    
    var executiveSummary: String = "" {
        didSet {
            errorLabel = nil
        }
    }
    
    
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
    
    
    var issueTypes: [FPIssueType] = [] {
        didSet {
            errorLabel = nil
        }
    }
    
    
    var selectedIssueTypes: [FPIssueType] = [] {
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
    
    
    func toggleSelection(for issueType: FPIssueType) {
        if selectedIssueTypes.contains(issueType) {
            selectedIssueTypes.removeAll(where: {$0 == issueType})
        } else {
            selectedIssueTypes.append(issueType)
        }
    }
    
    
    func reset() {
        self.statedIssue = .EMPTY
        self.statedLocation = .EMPTY
        self.selectedIssueTypes = []
        self.suggestedResponseLevel = .normal
        self.errorLabel = nil
        self.selectedFiles = []
    }
    
}
