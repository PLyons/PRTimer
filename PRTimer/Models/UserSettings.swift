//
//  UserSettings.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import Foundation
import SwiftUI

@MainActor
class UserSettings: ObservableObject {
    
    // MARK: - Private Properties
    private var isInitializing = true
    private let repository = UserSettingsRepository()
    
    // MARK: - Published Properties
    
    // Personal Information
    @Published var retireeName: String {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    @Published var subtitleMessage: String {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    @Published var celebrationTitle: String {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    // Date & Time Settings
    @Published var startDate: Date {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    @Published var retirementDate: Date {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    @Published var retirementTimeZone: TimeZone {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    @Published var workDayEndHour: Int {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    @Published var workDayEndMinute: Int {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    // Notification Settings
    @Published var notificationsEnabled: Bool {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    @Published var notificationHour: Int {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    @Published var notificationMinute: Int {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    // Display Preferences
    @Published var defaultShowWorkingDays: Bool {
        didSet { 
            if !isInitializing {
                saveToUserDefaults() 
            }
        }
    }
    
    // MARK: - Singleton
    static let shared = UserSettings()
    
    // MARK: - Initialization
    private init() {
        // Initialize with smart defaults, then load from UserDefaults
        retireeName = "Your Name"
        subtitleMessage = "The final stretch to freedom!"
        celebrationTitle = "has retired!"
        
        // Use user's current timezone for better localization
        let defaultTimeZone = TimeZone.current
        let dates = Self.defaultDates(timezone: defaultTimeZone)
        startDate = dates.start
        retirementDate = dates.retirement
        retirementTimeZone = defaultTimeZone
        workDayEndHour = 17
        workDayEndMinute = 0
        
        notificationsEnabled = true
        notificationHour = 17
        notificationMinute = 0
        
        defaultShowWorkingDays = true
        
        // Load saved settings
        loadFromUserDefaults()
        
        // Mark initialization as complete
        isInitializing = false
    }
    
    // MARK: - Private Helpers

    /// Calculates the smart default start and retirement dates relative to today.
    /// Used by both init() and resetToDefaults() to avoid duplicated logic.
    private static func defaultDates(timezone: TimeZone) -> (start: Date, retirement: Date) {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)

        var startComponents = DateComponents()
        startComponents.year = currentYear - 5
        startComponents.month = 1
        startComponents.day = 1
        startComponents.hour = 8
        startComponents.minute = 0
        startComponents.timeZone = timezone
        let start = calendar.date(from: startComponents) ?? currentDate

        var retirementComponents = DateComponents()
        retirementComponents.year = (currentYear - 5) + 30
        retirementComponents.month = 12
        retirementComponents.day = 31
        retirementComponents.hour = 17
        retirementComponents.minute = 0
        retirementComponents.timeZone = timezone
        let retirement = calendar.date(from: retirementComponents) ?? currentDate

        return (start, retirement)
    }

    // MARK: - Computed Properties
    
    /// Full countdown title combining name with "Retirement Countdown"
    var countdownTitle: String {
        "\(retireeName)'s Retirement Countdown"
    }
    
    /// Full celebration message combining name with celebration title
    var fullCelebrationTitle: String {
        "\(retireeName) \(celebrationTitle)"
    }
    
    /// Work day end time as Date components
    var workDayEndTime: DateComponents {
        var components = DateComponents()
        components.hour = workDayEndHour
        components.minute = workDayEndMinute
        components.timeZone = retirementTimeZone
        return components
    }
    
    /// Notification time as Date components
    var notificationTime: DateComponents {
        var components = DateComponents()
        components.hour = notificationHour
        components.minute = notificationMinute
        components.timeZone = retirementTimeZone
        return components
    }
    
    // MARK: - Validation
    
    /// Validate that retirement date is in the future
    var isRetirementDateValid: Bool {
        retirementDate > Date()
    }
    
    /// Validate work day end time is reasonable (6 AM to 11 PM)
    var isWorkDayEndTimeValid: Bool {
        workDayEndHour >= 6 && workDayEndHour <= 23
    }
    
    /// Validate notification time is reasonable
    var isNotificationTimeValid: Bool {
        notificationHour >= 0 && notificationHour <= 23 &&
        notificationMinute >= 0 && notificationMinute <= 59
    }
    
    // MARK: - Persistence

    private func saveToUserDefaults() {
        repository.save(
            retireeName: retireeName,
            subtitleMessage: subtitleMessage,
            celebrationTitle: celebrationTitle,
            startDate: startDate,
            retirementDate: retirementDate,
            retirementTimeZone: retirementTimeZone,
            workDayEndHour: workDayEndHour,
            workDayEndMinute: workDayEndMinute,
            notificationsEnabled: notificationsEnabled,
            notificationHour: notificationHour,
            notificationMinute: notificationMinute,
            defaultShowWorkingDays: defaultShowWorkingDays
        )
    }

    private func loadFromUserDefaults() {
        if let v = repository.retireeName { retireeName = v }
        if let v = repository.subtitleMessage { subtitleMessage = v }
        if let v = repository.celebrationTitle { celebrationTitle = v }
        if let v = repository.startDate { startDate = v }
        if let v = repository.retirementDate { retirementDate = v }
        if let v = repository.retirementTimeZone { retirementTimeZone = v }
        if let v = repository.workDayEndHour { workDayEndHour = v }
        if let v = repository.workDayEndMinute { workDayEndMinute = v }
        if let v = repository.notificationsEnabled { notificationsEnabled = v }
        if let v = repository.notificationHour { notificationHour = v }
        if let v = repository.notificationMinute { notificationMinute = v }
        if let v = repository.defaultShowWorkingDays { defaultShowWorkingDays = v }
    }
    
    // MARK: - Reset to Defaults
    
    func resetToDefaults() {
        retireeName = "Your Name"
        subtitleMessage = "The final stretch to freedom!"
        celebrationTitle = "has retired!"
        
        // Reset to user's current timezone for better localization
        retirementTimeZone = TimeZone.current
        let dates = Self.defaultDates(timezone: retirementTimeZone)
        startDate = dates.start
        retirementDate = dates.retirement
        
        workDayEndHour = 17
        workDayEndMinute = 0
        
        notificationsEnabled = true
        notificationHour = 17
        notificationMinute = 0
        
        defaultShowWorkingDays = true
    }
}