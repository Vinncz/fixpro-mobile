struct FPInboundEntryFormField: Decodable {
    var fieldLabel: String
    
    enum CodingKeys: String, CodingKey {
        case fieldLabel = "field_label"
    }
}
