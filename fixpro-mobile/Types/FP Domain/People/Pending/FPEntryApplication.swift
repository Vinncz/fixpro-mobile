import Foundation
import VinUtility



struct FPEntryApplication: Decodable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var formAnswer: [FPFormAnswer]
    
    
    var submittedOn: String
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case formAnswer = "form_answer"
        case submittedOn = "submitted_on"
    }
    
}



struct FPFormAnswer: Decodable, Hashable {
    
    
    var fieldLabel: String
    
    
    var fieldValue: String
    
    
    enum CodingKeys: String, CodingKey {
        case fieldLabel = "field_label"
        case fieldValue = "field_value"
    }
    
}
