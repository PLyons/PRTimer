import Foundation

/// Utility for calculating working days and business day logic
struct WorkingDaysCalculator {
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static let easternTimeZone = TimeZone(identifier: "America/New_York")!
    
    /// Count working days between two dates (exclusive of start date, inclusive of end date)
    /// Excludes weekends and federal holidays
    /// - Parameters:
    ///   - startDate: The start date (exclusive)
    ///   - endDate: The end date (inclusive)
    /// - Returns: Number of working days
    static func countWorkingDays(from startDate: Date, to endDate: Date) -> Int {
        var count = 0
        var currentDate = calendar.startOfDay(for: startDate)
        let finalDate = calendar.startOfDay(for: endDate)
        
        // Move to the next day after start date
        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        
        while currentDate <= finalDate {
            if isWorkingDay(currentDate) {
                count += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return count
    }
    
    /// Count Fridays between two dates (inclusive)
    /// - Parameters:
    ///   - startDate: The start date
    ///   - endDate: The end date
    /// - Returns: Number of Fridays
    static func countFridays(from startDate: Date, to endDate: Date) -> Int {
        var count = 0
        var currentDate = calendar.startOfDay(for: startDate)
        let finalDate = calendar.startOfDay(for: endDate)
        
        while currentDate <= finalDate {
            if calendar.component(.weekday, from: currentDate) == 6 { // Friday is 6
                count += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return count
    }
    
    /// Check if a date is a working day (not weekend, not holiday)
    /// - Parameter date: The date to check
    /// - Returns: True if it's a working day
    static func isWorkingDay(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        
        // Check if it's a weekend (Sunday = 1, Saturday = 7)
        if weekday == 1 || weekday == 7 {
            return false
        }
        
        // Check if it's a federal holiday
        if HolidayCalculator.isFederalHoliday(date) {
            return false
        }
        
        return true
    }
    
    /// Check if today is a working day
    /// - Returns: True if today is a working day
    static func isTodayAWorkingDay() -> Bool {
        return isWorkingDay(Date())
    }
    
    /// Get the next working day after a given date
    /// - Parameter date: The reference date
    /// - Returns: The next working day
    static func nextWorkingDay(after date: Date) -> Date {
        var nextDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        
        while !isWorkingDay(nextDay) {
            nextDay = calendar.date(byAdding: .day, value: 1, to: nextDay) ?? nextDay
        }
        
        return nextDay
    }
    
    /// Calculate total working days in a date range (for progress calculations)
    /// - Parameters:
    ///   - startDate: The start date (inclusive)
    ///   - endDate: The end date (inclusive)
    /// - Returns: Total working days in the range
    static func totalWorkingDays(from startDate: Date, to endDate: Date) -> Int {
        var count = 0
        var currentDate = calendar.startOfDay(for: startDate)
        let finalDate = calendar.startOfDay(for: endDate)
        
        while currentDate <= finalDate {
            if isWorkingDay(currentDate) {
                count += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return count
    }
}
