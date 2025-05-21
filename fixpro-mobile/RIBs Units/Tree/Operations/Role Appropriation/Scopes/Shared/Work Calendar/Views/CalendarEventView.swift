import SwiftUI
import VinUtility



struct CalendarEventView: View {
    
    
    var event: FPCalendarEvent
    
    
    var body: some View {
        Form {
            Section("Event title") {
                Text(event.title)
            }
            Section("Event description") {
                Text(event.description)
            }
            Section("Happening on") {
                Text("\(Date.parse(event.happeningOn) ?? .now)")
            }
            Section("Duration of event") {
                Text(VUSecondsToDurationConverter(Double(event.durationInSeconds)))
            }
            Section("Save this event") {
                Text(LocalizedStringResource("[Save to calendar](\(event.savedOn.absoluteString))"))
                    .foregroundStyle(.blue)
            }
        }
        .navigationTitle("Event details")
    }
    
}


#Preview {
    @Previewable @State var event: FPCalendarEvent = .init(id: "ID", title: "Basic Event to Start Your Coding Journey", description: "No description were added", happeningOn: "2025-05-08T22:00:00+07:00", savedOn: URL(string: "https://google.com")!, durationInSeconds: 3600, reminderEnabled: false)
    CalendarEventView(event: event)
}
