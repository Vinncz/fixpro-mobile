import Foundation



enum FPTimeLoggedSection: String, CaseIterable {
    
    
    case today = "Today"
    
    
    case yesterday = "Yesterday"
    
    
    case thisWeek = "This Week"
    
    
    case thisMonth = "This Month"
    
    
    case thisYear = "This Year"
    
    
    case older = "Older"
    
    
    /// Returns the appropriate section for a given date.
    static func category(for date: Date) -> FPTimeLoggedSection {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return .today
        } else if calendar.isDateInYesterday(date) {
            return .yesterday
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            return .thisWeek
        } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
            return .thisMonth
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            return .thisYear
        } else {
            return .older
        }
    }
    
}
