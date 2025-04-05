import Observation

@Observable class EntryRequestFormViewModel {
    
    var fieldsAndAnswers: [String: String] = [:]
    
    var didSubmit: (([String: String]) -> Void)?
    
    var filloutValidationLabel: String = ""
    
}
