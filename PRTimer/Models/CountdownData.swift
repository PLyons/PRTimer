import Foundation

/// Data structure representing the current countdown state
struct CountdownData {
    let workingDaysRemaining: Int
    let totalDaysRemaining: Int
    let fridaysRemaining: Int
    let hoursRemaining: Int
    let minutesRemaining: Int
    let secondsRemaining: Int
    let progressPercentage: Double
    let isRetired: Bool
    let showWorkingDays: Bool
    
    /// Initialize with all zeros (default state)
    init() {
        self.workingDaysRemaining = 0
        self.totalDaysRemaining = 0
        self.fridaysRemaining = 0
        self.hoursRemaining = 0
        self.minutesRemaining = 0
        self.secondsRemaining = 0
        self.progressPercentage = 0.0
        self.isRetired = false
        self.showWorkingDays = true
    }
    
    /// Initialize with calculated values
    init(workingDays: Int, totalDays: Int, fridays: Int, hours: Int, minutes: Int, seconds: Int, progress: Double, retired: Bool = false, showWorkingDays: Bool = true) {
        self.workingDaysRemaining = workingDays
        self.totalDaysRemaining = totalDays
        self.fridaysRemaining = fridays
        self.hoursRemaining = hours
        self.minutesRemaining = minutes
        self.secondsRemaining = seconds
        self.progressPercentage = progress
        self.isRetired = retired
        self.showWorkingDays = showWorkingDays
    }
}

/// Constants for the retirement countdown
struct RetirementConstants {
    /// The target retirement date and time: October 10, 2025, 5:00 PM EDT
    static let retirementDate: Date = {
        var components = DateComponents()
        components.timeZone = TimeZone(identifier: "America/New_York")
        components.year = 2025
        components.month = 10
        components.day = 10
        components.hour = 17  // 5:00 PM
        components.minute = 0
        components.second = 0
        
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components) ?? Date.distantFuture
    }()
    
    /// The start of the countdown period (beginning of 2025)
    static let countdownStartDate: Date = {
        var components = DateComponents()
        components.timeZone = TimeZone(identifier: "America/New_York")
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components) ?? Date.distantPast
    }()
    
    /// The end date for working days calculation (October 10, 2025 at end of day)
    static let workingDaysEndDate: Date = {
        var components = DateComponents()
        components.timeZone = TimeZone(identifier: "America/New_York")
        components.year = 2025
        components.month = 10
        components.day = 10
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components) ?? Date.distantFuture
    }()
    
    /// Total working days from start of year to retirement (for progress calculation)
    static let totalWorkingDays: Int = {
        return WorkingDaysCalculator.totalWorkingDays(
            from: countdownStartDate,
            to: workingDaysEndDate
        )
    }()
}

/// Helper extension for formatting countdown values
extension CountdownData {
    /// Get formatted string for working days
    var formattedWorkingDays: String {
        return String(format: "%02d", workingDaysRemaining)
    }
    
    /// Get formatted string for total days
    var formattedTotalDays: String {
        return String(format: "%02d", totalDaysRemaining)
    }
    
    /// Get the currently displayed days count based on toggle state
    var displayedDays: Int {
        return showWorkingDays ? workingDaysRemaining : totalDaysRemaining
    }
    
    /// Get formatted string for currently displayed days
    var formattedDisplayedDays: String {
        return String(format: "%02d", displayedDays)
    }
    
    /// Get label for currently displayed days type
    var daysLabel: String {
        return showWorkingDays ? "Working Days" : "Total Days"
    }
    
    /// Get formatted string for fridays
    var formattedFridays: String {
        return String(format: "%02d", fridaysRemaining)
    }
    
    /// Get formatted string for hours
    var formattedHours: String {
        return String(format: "%02d", hoursRemaining)
    }
    
    /// Get formatted string for minutes
    var formattedMinutes: String {
        return String(format: "%02d", minutesRemaining)
    }
    
    /// Get formatted string for seconds
    var formattedSeconds: String {
        return String(format: "%02d", secondsRemaining)
    }
    
    /// Get formatted percentage string
    var formattedProgress: String {
        return String(format: "%.2f%%", progressPercentage)
    }
}
