import Foundation
import Observation



/// Bridges between ``WorkCalendarSwiftUIView`` and the ``WorkCalendarInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class WorkCalendarSwiftUIViewModel {
    
    
    var events: [FPCalendarEvent] = []
    
    
    var didIntendToRefresh: (()async->Void)?
    
}



struct FPCalendarEvent: Codable, Identifiable {
    
    
    var id: String
    
    
    var title: String
    
    
    var description: String
    
    
    var happeningOn: String
    
    
    var savedOn: URL
    
    
    var durationInSeconds: Int
    
    
    var reminderEnabled: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case happeningOn = "happening_on"
        case savedOn = "saved_on"
        case durationInSeconds = "duration_in_seconds"
        case reminderEnabled = "reminder_enabled"
    }
    
}
