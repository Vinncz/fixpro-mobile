import Foundation



struct FPTicketLog: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var owningTicketId: String
    
    
    var type: FPTicketLogType
    
    
    var issuer: FPPerson
    
    
    var recordedOn: String


    var news: String
    
    
    var attachments: [FPSupportiveDocument]
    
    
    var actionable: FPRemoteNotificationActionable
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case owningTicketId = "owning_ticket_id"
        case type
        case issuer
        case recordedOn = "recorded_on"
        case news
        case attachments
        case actionable
    }
    
}
