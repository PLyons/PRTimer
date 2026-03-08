import Foundation
import SwiftUI
import Combine

/// ViewModel that manages the countdown state and real-time updates
@MainActor
class CountdownViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var countdownData = CountdownData()
    @Published var isRetired = false
    
    // MARK: - Dependencies
    private let userSettings: UserSettings
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var foregroundObserver: AnyCancellable?
    private let calendar = Calendar(identifier: .gregorian)
    
    // MARK: - Initialization
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        
        // Set up foreground notification observer
        foregroundObserver = NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refreshCountdown()
                }
            }
        
        // Delay timer start to ensure proper initialization
        Task {
            await MainActor.run {
                updateCountdown() // Initial calculation
                startTimer()
            }
        }
    }
    
    // Convenience initializer that uses shared settings
    convenience init() {
        self.init(userSettings: UserSettings.shared)
    }
    
    deinit {
        timer?.cancel()
        timer = nil
        foregroundObserver?.cancel()
        foregroundObserver = nil
    }
    
    // MARK: - Timer Management
    
    /// Start the real-time countdown timer
    func startUpdating() {
        startTimer()
    }
    
    /// Stop the countdown timer
    func stopUpdating() {
        stopTimer()
    }
    
    /// Start the real-time countdown timer
    private func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdown()
            }
    }
    
    /// Stop the countdown timer
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - Countdown Calculations
    
    /// Update the countdown data with current values
    private func updateCountdown() {
        let now = Date()
        let retirementDateTime = userSettings.retirementDate
        
        // Check if retirement time has passed
        if now >= retirementDateTime {
            handleRetirement()
            return
        }
        
        // Calculate time remaining
        let timeInterval = retirementDateTime.timeIntervalSince(now)
        let timeComponents = calculateTimeComponents(from: timeInterval)
        
        // Calculate working days remaining
        let workingDaysRemaining = calculateWorkingDaysRemaining(from: now, retirementDateTime: retirementDateTime)
        
        // Calculate total days remaining
        let totalDaysRemaining = calculateTotalDaysRemaining(from: now, retirementDateTime: retirementDateTime)
        
        // Calculate Fridays remaining
        let fridaysRemaining = calculateFridaysRemaining(from: now, retirementDateTime: retirementDateTime)
        
        // Calculate progress percentage
        let progressPercentage = calculateProgressPercentage(workingDaysRemaining: workingDaysRemaining)
        
        // Update the countdown data
        countdownData = CountdownData(
            workingDays: workingDaysRemaining,
            totalDays: totalDaysRemaining,
            fridays: fridaysRemaining,
            hours: timeComponents.hours,
            minutes: timeComponents.minutes,
            seconds: timeComponents.seconds,
            progress: progressPercentage,
            showWorkingDays: userSettings.defaultShowWorkingDays
        )
    }
    
    /// Calculate working days remaining from current date
    private func calculateWorkingDaysRemaining(from currentDate: Date, retirementDateTime: Date) -> Int {
        let now = currentDate
        
        // If we're past retirement time, return 0
        if now >= retirementDateTime {
            return 0
        }
        
        // Determine the start date for counting working days
        let startDate: Date
        
        // Check if current time is past work day end time today
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        var todayAtWorkEndComponents = todayComponents
        todayAtWorkEndComponents.hour = userSettings.workDayEndHour
        todayAtWorkEndComponents.minute = userSettings.workDayEndMinute
        todayAtWorkEndComponents.second = 0
        todayAtWorkEndComponents.timeZone = userSettings.retirementTimeZone
        
        guard let todayAtWorkEnd = calendar.date(from: todayAtWorkEndComponents) else {
            // Fallback: use start of today if we can't create work end time
            startDate = calendar.startOfDay(for: now)
            let retirementDay = calendar.startOfDay(for: retirementDateTime)
            return WorkingDaysCalculator.countWorkingDays(from: startDate, to: retirementDay)
        }
        
        if now >= todayAtWorkEnd && WorkingDaysCalculator.isWorkingDay(now) {
            // Past work end time today and today is a working day - start counting from tomorrow
            startDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        } else {
            // Before work end time today or today is not a working day - count today
            startDate = calendar.startOfDay(for: now)
        }
        
        // Count working days from start date up to (but not including) retirement date
        let retirementDay = calendar.startOfDay(for: retirementDateTime)
        
        return WorkingDaysCalculator.countWorkingDays(from: startDate, to: retirementDay)
    }
    
    /// Calculate total days remaining from current date
    private func calculateTotalDaysRemaining(from currentDate: Date, retirementDateTime: Date) -> Int {
        let now = currentDate
        
        // If we're past retirement time, return 0
        if now >= retirementDateTime {
            return 0
        }
        
        // Determine the start date for counting total days
        let startDate: Date
        
        // Check if current time is past work day end time today
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        var todayAtWorkEndComponents = todayComponents
        todayAtWorkEndComponents.hour = userSettings.workDayEndHour
        todayAtWorkEndComponents.minute = userSettings.workDayEndMinute
        todayAtWorkEndComponents.second = 0
        todayAtWorkEndComponents.timeZone = userSettings.retirementTimeZone
        
        guard let todayAtWorkEnd = calendar.date(from: todayAtWorkEndComponents) else {
            // Fallback: use start of today if we can't create work end time
            startDate = calendar.startOfDay(for: now)
            let retirementDay = calendar.startOfDay(for: retirementDateTime)
            let components = calendar.dateComponents([.day], from: startDate, to: retirementDay)
            return max(components.day ?? 0, 0)
        }
        
        if now >= todayAtWorkEnd {
            // Past work end time today - start counting from tomorrow
            startDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        } else {
            // Before work end time today - count from today
            startDate = calendar.startOfDay(for: now)
        }
        
        // Count total days from start date up to (but not including) retirement date
        let retirementDay = calendar.startOfDay(for: retirementDateTime)
        let components = calendar.dateComponents([.day], from: startDate, to: retirementDay)
        return max(components.day ?? 0, 0)
    }
    
    /// Calculate Fridays remaining from current date
    private func calculateFridaysRemaining(from currentDate: Date, retirementDateTime: Date) -> Int {
        let now = currentDate
        
        // If we're past retirement time, return 0
        if now >= retirementDateTime {
            return 0
        }
        
        // Determine the start date for counting Fridays
        let startDate: Date
        
        // Check if current time is past work end time today
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        var todayAtWorkEndComponents = todayComponents
        todayAtWorkEndComponents.hour = userSettings.workDayEndHour
        todayAtWorkEndComponents.minute = userSettings.workDayEndMinute
        todayAtWorkEndComponents.second = 0
        todayAtWorkEndComponents.timeZone = userSettings.retirementTimeZone
        
        guard let todayAtWorkEnd = calendar.date(from: todayAtWorkEndComponents) else {
            // Fallback: use start of today if we can't create work end time
            startDate = calendar.startOfDay(for: now)
            let retirementDay = calendar.startOfDay(for: retirementDateTime)
            return WorkingDaysCalculator.countFridays(from: startDate, to: retirementDay)
        }
        
        let weekday = calendar.component(.weekday, from: now)
        let isFriday = (weekday == 6)
        
        if now >= todayAtWorkEnd && isFriday {
            // Past work end time on Friday - start counting from tomorrow
            startDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        } else {
            // Before work end time or not Friday - count from today
            startDate = calendar.startOfDay(for: now)
        }
        
        // Count Fridays from start date up to (but not including) retirement date
        let retirementDay = calendar.startOfDay(for: retirementDateTime)
        
        return WorkingDaysCalculator.countFridays(from: startDate, to: retirementDay)
    }
    
    /// Calculate progress percentage based on working days completed
    private func calculateProgressPercentage(workingDaysRemaining: Int) -> Double {
        // Calculate total working days from user's start date to retirement date
        let totalWorkingDays = WorkingDaysCalculator.totalWorkingDays(
            from: userSettings.startDate,
            to: userSettings.retirementDate
        )
        let workingDaysCompleted = totalWorkingDays - workingDaysRemaining
        
        guard totalWorkingDays > 0 else { return 0.0 }
        
        let percentage = (Double(workingDaysCompleted) / Double(totalWorkingDays)) * 100.0
        return min(max(percentage, 0.0), 100.0) // Clamp between 0 and 100
    }
    
    /// Break down time interval into hours, minutes, and seconds
    private func calculateTimeComponents(from timeInterval: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
        let totalSeconds = Int(timeInterval)
        
        let hours = (totalSeconds % (24 * 3600)) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return (
            hours: max(hours, 0),
            minutes: max(minutes, 0),
            seconds: max(seconds, 0)
        )
    }
    
    /// Handle the retirement state when countdown reaches zero
    private func handleRetirement() {
        stopTimer()
        isRetired = true
        countdownData = CountdownData(
            workingDays: 0,
            totalDays: 0,
            fridays: 0,
            hours: 0,
            minutes: 0,
            seconds: 0,
            progress: 100.0,
            retired: true,
            showWorkingDays: userSettings.defaultShowWorkingDays
        )
    }
    
    // MARK: - Public Methods
    
    /// Manually refresh the countdown (useful for app foreground events)
    func refreshCountdown() {
        updateCountdown()
    }
    
    /// Restart the timer if it was stopped
    func restartTimer() {
        if timer == nil {
            startTimer()
        }
    }
    
    
    /// Get debug information about the countdown
    func getDebugInfo() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        
        let easternTimeZone = TimeZone(identifier: "America/New_York") ?? TimeZone.current
        var retirementComponents = DateComponents()
        retirementComponents.year = 2025
        retirementComponents.month = 10
        retirementComponents.day = 10
        retirementComponents.hour = 17
        retirementComponents.minute = 0
        retirementComponents.second = 0
        retirementComponents.timeZone = easternTimeZone
        
        let retirementDate = Calendar.current.date(from: retirementComponents) ?? Date()
        
        let totalWorkingDays = WorkingDaysCalculator.totalWorkingDays(
            from: userSettings.startDate,
            to: userSettings.retirementDate
        )
        
        return """
        Current Time: \(formatter.string(from: now))
        Start Date: \(formatter.string(from: userSettings.startDate))
        Retirement Date: \(formatter.string(from: retirementDate))
        Total Working Days: \(totalWorkingDays)
        Working Days Remaining: \(countdownData.workingDaysRemaining)
        Progress: \(countdownData.formattedProgress)
        Is Today Working Day: \(WorkingDaysCalculator.isTodayAWorkingDay())
        """
    }
}
