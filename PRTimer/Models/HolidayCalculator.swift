import Foundation

/// Handles federal holiday calculations for 2025
struct HolidayCalculator {
    
    /// Federal holidays in 2025 that fall on weekdays and are between now and October 10
    private static let federalHolidays2025: [Date] = {
        var holidays: [Date] = []
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.timeZone = TimeZone(identifier: "America/New_York")
        
        // Memorial Day: Last Monday in May (May 26, 2025)
        components.year = 2025
        components.month = 5
        components.day = 26
        if let memorialDay = calendar.date(from: components) {
            holidays.append(memorialDay)
        }
        
        // Independence Day: July 4 (Friday in 2025)
        components.month = 7
        components.day = 4
        if let independenceDay = calendar.date(from: components) {
            holidays.append(independenceDay)
        }
        
        // Labor Day: First Monday in September (September 1, 2025)
        components.month = 9
        components.day = 1
        if let laborDay = calendar.date(from: components) {
            holidays.append(laborDay)
        }
        
        return holidays
    }()
    
    /// Check if a given date is a federal holiday
    /// - Parameter date: The date to check
    /// - Returns: True if the date is a federal holiday
    static func isFederalHoliday(_ date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        
        // Convert input date to start of day for comparison
        let dateStartOfDay = calendar.startOfDay(for: date)
        
        return federalHolidays2025.contains { holiday in
            let holidayStartOfDay = calendar.startOfDay(for: holiday)
            return calendar.isDate(dateStartOfDay, inSameDayAs: holidayStartOfDay)
        }
    }
    
    /// Get all federal holidays for display purposes
    /// - Returns: Array of federal holiday dates
    static func getAllHolidays() -> [Date] {
        return federalHolidays2025
    }
    
    /// Get formatted holiday names for debugging/display
    /// - Returns: Dictionary mapping dates to holiday names
    static func getHolidayNames() -> [Date: String] {
        let calendar = Calendar(identifier: .gregorian)
        var holidayNames: [Date: String] = [:]
        
        for holiday in federalHolidays2025 {
            let components = calendar.dateComponents([.month, .day], from: holiday)
            switch (components.month, components.day) {
            case (5, 26):
                holidayNames[holiday] = "Memorial Day"
            case (7, 4):
                holidayNames[holiday] = "Independence Day"
            case (9, 1):
                holidayNames[holiday] = "Labor Day"
            default:
                holidayNames[holiday] = "Federal Holiday"
            }
        }
        
        return holidayNames
    }
}
