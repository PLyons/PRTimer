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
    private var hasLoadedFromDefaults = false
    
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
            if !isInitializing && hasLoadedFromDefaults {
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
        
        // Smart default start date: 5 years ago from today
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        
        var startComponents = DateComponents()
        startComponents.year = currentYear - 5
        startComponents.month = 1
        startComponents.day = 1
        startComponents.hour = 8
        startComponents.minute = 0
        startComponents.timeZone = defaultTimeZone
        startDate = Calendar.current.date(from: startComponents) ?? Date()
        
        // Smart default retirement date: 30 years from career start (typical career length)
        var retirementComponents = DateComponents()
        retirementComponents.year = (currentYear - 5) + 30  // 30-year career from start
        retirementComponents.month = 12
        retirementComponents.day = 31
        retirementComponents.hour = 17
        retirementComponents.minute = 0
        retirementComponents.timeZone = defaultTimeZone
        retirementDate = Calendar.current.date(from: retirementComponents) ?? Date()
        
        retirementTimeZone = defaultTimeZone
        workDayEndHour = 17
        workDayEndMinute = 0
        
        notificationsEnabled = true
        notificationHour = 17
        notificationMinute = 0
        
        defaultShowWorkingDays = true
        
        // Load saved settings
        loadFromUserDefaults()
        
        // Mark loading and initialization as complete
        hasLoadedFromDefaults = true
        isInitializing = false
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
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let retireeName = "retireeName"
        static let subtitleMessage = "subtitleMessage"
        static let celebrationTitle = "celebrationTitle"
        static let startDate = "startDate"
        static let retirementDate = "retirementDate"
        static let retirementTimeZone = "retirementTimeZone"
        static let workDayEndHour = "workDayEndHour"
        static let workDayEndMinute = "workDayEndMinute"
        static let notificationsEnabled = "notificationsEnabled"
        static let notificationHour = "notificationHour"
        static let notificationMinute = "notificationMinute"
        static let defaultShowWorkingDays = "defaultShowWorkingDays"
    }
    
    // MARK: - Persistence
    
    private func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        
        defaults.set(retireeName, forKey: UserDefaultsKeys.retireeName)
        defaults.set(subtitleMessage, forKey: UserDefaultsKeys.subtitleMessage)
        defaults.set(celebrationTitle, forKey: UserDefaultsKeys.celebrationTitle)
        defaults.set(startDate, forKey: UserDefaultsKeys.startDate)
        defaults.set(retirementDate, forKey: UserDefaultsKeys.retirementDate)
        defaults.set(retirementTimeZone.identifier, forKey: UserDefaultsKeys.retirementTimeZone)
        defaults.set(workDayEndHour, forKey: UserDefaultsKeys.workDayEndHour)
        defaults.set(workDayEndMinute, forKey: UserDefaultsKeys.workDayEndMinute)
        defaults.set(notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled)
        defaults.set(notificationHour, forKey: UserDefaultsKeys.notificationHour)
        defaults.set(notificationMinute, forKey: UserDefaultsKeys.notificationMinute)
        defaults.set(defaultShowWorkingDays, forKey: UserDefaultsKeys.defaultShowWorkingDays)
    }
    
    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        if let savedName = defaults.object(forKey: UserDefaultsKeys.retireeName) as? String {
            retireeName = savedName
        }
        
        if let savedSubtitle = defaults.object(forKey: UserDefaultsKeys.subtitleMessage) as? String {
            subtitleMessage = savedSubtitle
        }
        
        if let savedCelebration = defaults.object(forKey: UserDefaultsKeys.celebrationTitle) as? String {
            celebrationTitle = savedCelebration
        }
        
        if let savedStartDate = defaults.object(forKey: UserDefaultsKeys.startDate) as? Date {
            startDate = savedStartDate
        }
        
        if let savedDate = defaults.object(forKey: UserDefaultsKeys.retirementDate) as? Date {
            retirementDate = savedDate
        }
        
        if let savedTimeZoneId = defaults.object(forKey: UserDefaultsKeys.retirementTimeZone) as? String,
           let timeZone = TimeZone(identifier: savedTimeZoneId) {
            retirementTimeZone = timeZone
        }
        
        if defaults.object(forKey: UserDefaultsKeys.workDayEndHour) != nil {
            workDayEndHour = defaults.integer(forKey: UserDefaultsKeys.workDayEndHour)
        }
        
        if defaults.object(forKey: UserDefaultsKeys.workDayEndMinute) != nil {
            workDayEndMinute = defaults.integer(forKey: UserDefaultsKeys.workDayEndMinute)
        }
        
        if defaults.object(forKey: UserDefaultsKeys.notificationsEnabled) != nil {
            notificationsEnabled = defaults.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        }
        
        if defaults.object(forKey: UserDefaultsKeys.notificationHour) != nil {
            notificationHour = defaults.integer(forKey: UserDefaultsKeys.notificationHour)
        }
        
        if defaults.object(forKey: UserDefaultsKeys.notificationMinute) != nil {
            notificationMinute = defaults.integer(forKey: UserDefaultsKeys.notificationMinute)
        }
        
        if defaults.object(forKey: UserDefaultsKeys.defaultShowWorkingDays) != nil {
            defaultShowWorkingDays = defaults.bool(forKey: UserDefaultsKeys.defaultShowWorkingDays)
        }
    }
    
    // MARK: - Reset to Defaults
    
    func resetToDefaults() {
        retireeName = "Your Name"
        subtitleMessage = "The final stretch to freedom!"
        celebrationTitle = "has retired!"
        
        // Reset to user's current timezone for better localization
        retirementTimeZone = TimeZone.current
        
        // Smart default start date: 5 years ago from today
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        
        var startComponents = DateComponents()
        startComponents.year = currentYear - 5
        startComponents.month = 1
        startComponents.day = 1
        startComponents.hour = 8
        startComponents.minute = 0
        startComponents.timeZone = retirementTimeZone
        startDate = Calendar.current.date(from: startComponents) ?? Date()
        
        // Smart default retirement date: 30 years from career start (typical career length)
        var retirementComponents = DateComponents()
        retirementComponents.year = (currentYear - 5) + 30  // 30-year career from start
        retirementComponents.month = 12
        retirementComponents.day = 31
        retirementComponents.hour = 17
        retirementComponents.minute = 0
        retirementComponents.timeZone = retirementTimeZone
        retirementDate = Calendar.current.date(from: retirementComponents) ?? Date()
        
        workDayEndHour = 17
        workDayEndMinute = 0
        
        notificationsEnabled = true
        notificationHour = 17
        notificationMinute = 0
        
        defaultShowWorkingDays = true
    }
}