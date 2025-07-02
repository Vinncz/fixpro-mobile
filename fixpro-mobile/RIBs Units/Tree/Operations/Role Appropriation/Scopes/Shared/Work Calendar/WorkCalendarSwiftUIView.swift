import SwiftUI
import VinUtility


fileprivate struct SectionView: View, Identifiable {
    
    
    var id = UUID()
    
    
    var day: String
    
    
    var events: [FPCalendarEvent]
    
    
    var body: some View {
        Section(header: Text(day)) {
            ForEach(events) { event in
                NavigationLink(destination: CalendarEventView(event: event)) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                                .lineLimit(2)
                            Text(event.description)
                                .foregroundStyle(.secondary)
                                .lineLimit(1...2)
                        }
                    }
                }
            }
        }
    }
    
}


/// The SwiftUI View that is bound to be presented in ``WorkCalendarViewController``.
struct WorkCalendarSwiftUIView: View {
    
    
    /// Two-ways communicator between ``WorkCalendarInteractor`` and self.
    @Bindable var viewModel: WorkCalendarSwiftUIViewModel
    
    
    var body: some View {
        NavigationStack {
            if viewModel.events.count > 0 {
                List {
                    ForEach(groupedByMonth(), id: \.key) { month, monthEvents in
                        Section(header: Text(month.prefix(month.count - 5))) {
                            ForEach(groupedByDay(events: monthEvents), id: \.key) { day, dayEvents in
                                SectionView(day: day, events: dayEvents)
                            }
                        }
                    }
                }
                .refreshable { 
                    await viewModel.didIntendToRefresh?()
                }
                .navigationTitle("Work Calendar")
                .navigationBarTitleDisplayMode(.large)
                
            } else {
                List {
                    ContentUnavailableView("No Event Planned", 
                                           systemImage: "calendar.badge.checkmark", 
                                           description: Text(
                                            """
                                            When an important event occur, we'll make an event through this calendar, so you can add them to your own.
                                            """
                                            ))
                }
                .refreshable { 
                    await viewModel.didIntendToRefresh?()
                }
                .navigationTitle("Work Calendar")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
    
    // MARK: - Grouping Helpers
    
    private func groupedByMonth() -> [(key: String, value: [FPCalendarEvent])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy" // e.g., April 2025
        
        let grouped = Dictionary(grouping: viewModel.events) { event in
            formatter.string(from: (try? Date(event.happeningOn, strategy: .iso8601)) ?? .now)
        }
        
        return grouped.sorted { lhs, rhs in
            // Reconstruct dates to sort
            let lhsDate = dateFromMonthYear(lhs.key)
            let rhsDate = dateFromMonthYear(rhs.key)
            return lhsDate < rhsDate
        }
    }
    
    private func groupedByDay(events: [FPCalendarEvent]) -> [(key: String, value: [FPCalendarEvent])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy" // e.g., 10 April 2025
        
        let grouped = Dictionary(grouping: events) { event in
            formatter.string(from: (try? Date(event.happeningOn, strategy: .iso8601)) ?? .now)
        }
        
        return grouped.sorted { lhs, rhs in
            dateFromFullDate(lhs.key) < dateFromFullDate(rhs.key)
        }
    }
    
    private func dateFromMonthYear(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.date(from: string) ?? .distantPast
    }
    
    private func dateFromFullDate(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.date(from: string) ?? .distantPast
    }
    
    private func dayDateComponents(_ date: Date) -> DateComponents {
        Calendar.current.dateComponents([.day, .weekday], from: date)
    }
    
    private func weekdayNameFrom(weekdayNumber: Int) -> String {
        Calendar.current.weekdaySymbols[safe: weekdayNumber - 1] ?? ""
    }
    
}


func weekdayNameFrom(weekdayNumber: Int) -> String {
    let calendar = Calendar.current
    let dayIndex = ((weekdayNumber - 1) + (calendar.firstWeekday - 1)) % 7
    return calendar.weekdaySymbols[dayIndex]
} 


extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}



#Preview {
    @Previewable var viewModel = WorkCalendarSwiftUIViewModel()
    WorkCalendarSwiftUIView(viewModel: viewModel)
}
