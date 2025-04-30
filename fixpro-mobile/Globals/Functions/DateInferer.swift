import Foundation



/// Converts a date to a string in relation to now.
/// Eg. "Last hour", "Yesterday", "This week", "Past week", "This month", "Past month", "This year", "Past year"
/// - Parameter date: The date to convert.
/// - Returns: A string representing the date in relation to now.
/// 
/// The strategy is to progressively chip down the date from the far future to the far past.
func dateToString(date: Date) -> String {
    let now = Date()
    
    return if date > now {
        handleFutureConversion(date: date).rawValue
    } else if date == now {
        RelativeDate.now.rawValue
    } else {
        handlePastConversion(date: date).rawValue
    }
}



fileprivate func handleFutureConversion(date: Date) -> RelativeDate {
    let calendar = Calendar.current
    let now = Date()
    
    if calendar.isDateInTomorrow(date) {
        return .tomorrow
    } else if let hourDifference = calendar.dateComponents([.hour], from: now, to: date).hour, hourDifference < 24 {
        return .nextHour
    } else if let weekDifference = calendar.dateComponents([.weekOfYear], from: now, to: date).weekOfYear, weekDifference == 1 {
        return .nextWeek
    } else if let monthDifference = calendar.dateComponents([.month], from: now, to: date).month, monthDifference == 1 {
        return .nextMonth
    } else if let yearDifference = calendar.dateComponents([.year], from: now, to: date).year, yearDifference == 1 {
        return .nextYear
    } else {
        return .farFuture
    }
}



fileprivate func handlePastConversion(date: Date) -> RelativeDate {
    let calendar = Calendar.current
    let now = Date()
    
    if let hourDifference = calendar.dateComponents([.hour], from: date, to: now).hour, hourDifference < 2 {
        return .lastHour
    } else if let hourDifference = calendar.dateComponents([.hour], from: date, to: now).hour, hourDifference < 24 {
        return .today
    } else if let hourDifference = calendar.dateComponents([.hour], from: date, to: now).hour, hourDifference < 48 {
        return .yesterday
    } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
        return .thisWeek
    } else if let weekDifference = calendar.dateComponents([.weekOfYear], from: date, to: now).weekOfYear, weekDifference == 1 {
        return .lastWeek
    } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
        return .thisMonth
    } else if let monthDifference = calendar.dateComponents([.month], from: date, to: now).month, monthDifference == 1 {
        return .lastMonth
    } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
        return .thisYear
    } else if let yearDifference = calendar.dateComponents([.year], from: date, to: now).year, yearDifference == 1 {
        return .lastYear
    } else {
        return .farPast
    }
}


enum RelativeDate: String {
    case farFuture = "Far future"
    case farPast = "Long ago"
    
    case nextYear = "Next year"
    case thisYear = "This year"
    case lastYear = "Last year"
    
    case nextMonth = "Next month"
    case thisMonth = "This month"
    case lastMonth = "Last month"
    
    case nextWeek = "Next week"
    case thisWeek = "This week"
    case lastWeek = "Last week"
    
    case tomorrow = "Tomorrow"
    case today = "Today"
    case yesterday = "Yesterday"
    
    case nextHour = "Next hour"
    case now = "Now"
    case lastHour = "Last hour"
}
