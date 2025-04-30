import Foundation



struct FPTicketLog: Codable, Hashable, Identifiable {
    
    
    var id: String
    
    
    var owningTicketId: String
    
    
    var type: FPTIcketLogType
    
    
    var issuer: FPContactInformation
    
    
    var recordedOn: Date


    var news: String
    
    
    var attachment: [FPSupportiveDocument]
    
    
    var actionable: FPRemoteNotificationActionable
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case owningTicketId = "owning_ticket_id"
        case type = "log_type"
        case issuer
        case recordedOn = "recorded_on"
        case news
        case attachment
        case actionable
    }
    
}
