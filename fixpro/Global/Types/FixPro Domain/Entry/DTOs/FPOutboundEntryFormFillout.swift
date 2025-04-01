struct FPOutboundEntryFormFillout {
    
    var nonce: String
    var data: [FPOutboundEntryFormFieldEntry]
    
    init(nonce: String, fields: [FPInboundEntryFormField], answers: [String]) {
        self.nonce = nonce
        self.data = zip(fields, answers).map { (field, answer) in
            .init(fieldLabel: field.fieldLabel, fieldValue: answer)
        }
    }
    
}

struct FPOutboundEntryFormFieldEntry: Encodable {
    
    var fieldLabel: String
    var fieldValue: String
    
    enum CodingKeys: String, CodingKey {
        case fieldLabel = "field_label"
        case fieldValue = "field_value"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(fieldLabel, forKey: .fieldLabel)
        try container.encode(fieldValue, forKey: .fieldValue)
    }
    
    init(fieldLabel: String, fieldValue: String) {
        self.fieldLabel = fieldLabel
        self.fieldValue = fieldValue
    }
    
}

extension FPOutboundEntryFormFillout: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case nonce
        case data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(nonce, forKey: .nonce)
        try container.encode(data, forKey: .data)
    }
    
}
