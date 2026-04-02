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
