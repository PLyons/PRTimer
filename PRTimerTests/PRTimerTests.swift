//
//  PRTimerTests.swift
//  PRTimerTests
//
//  Created by Paul Lyons on 6/5/25.
//

import Testing
import Foundation
@testable import PRTimer

struct PRTimerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test @MainActor func testUserSettingsPersistence() async throws {
        // Clear any existing UserDefaults for clean test
        let keys = ["retireeName", "subtitleMessage", "celebrationTitle", "startDate", "retirementDate", "retirementTimeZone", "workDayEndHour", "workDayEndMinute", "notificationsEnabled", "notificationHour", "notificationMinute", "defaultShowWorkingDays"]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Force synchronization
        UserDefaults.standard.synchronize()
        
        // Create UserSettings instance
        let settings = UserSettings.shared
        let originalStartDate = settings.startDate
        
        // Modify start date
        let newStartDate = Calendar.current.date(from: DateComponents(year: 2010, month: 6, day: 15, hour: 9, minute: 0)) ?? Date()
        settings.startDate = newStartDate
        
        // Force synchronization after save
        UserDefaults.standard.synchronize()
        
        // Verify it was saved to UserDefaults
        let savedDate = UserDefaults.standard.object(forKey: "startDate") as? Date
        #expect(savedDate != nil, "startDate should be saved to UserDefaults")
        #expect(savedDate == newStartDate, "Saved date should match the new start date")
        
        // Test by checking UserDefaults directly without modifying settings
        UserDefaults.standard.synchronize()
        if let directLoadedDate = UserDefaults.standard.object(forKey: "startDate") as? Date {
            #expect(directLoadedDate == newStartDate, "Direct UserDefaults load should match the saved date")
        } else {
            throw TestError.persistenceFailure("Could not load startDate directly from UserDefaults")
        }
    }
    
    @Test @MainActor func testStartDateSpecificPersistence() async throws {
        // Clear startDate specifically
        UserDefaults.standard.removeObject(forKey: "startDate")
        UserDefaults.standard.synchronize()
        
        // Get settings instance
        let settings = UserSettings.shared
        
        // Set a specific test date
        let testDate = Calendar.current.date(from: DateComponents(year: 2015, month: 3, day: 10, hour: 8, minute: 0)) ?? Date()
        
        // Log before change
        print("Before change - Settings startDate: \(settings.startDate)")
        print("Before change - UserDefaults startDate: \(UserDefaults.standard.object(forKey: "startDate") ?? "nil")")
        
        // Change the date
        settings.startDate = testDate
        
        // Force sync
        UserDefaults.standard.synchronize()
        
        // Log after change
        print("After change - Settings startDate: \(settings.startDate)")
        print("After change - UserDefaults startDate: \(UserDefaults.standard.object(forKey: "startDate") ?? "nil")")
        
        // Verify persistence
        let persistedDate = UserDefaults.standard.object(forKey: "startDate") as? Date
        #expect(persistedDate != nil, "startDate should exist in UserDefaults")
        #expect(persistedDate == testDate, "Persisted date should match test date")
        #expect(settings.startDate == testDate, "Settings startDate should match test date")
    }
    
    @Test @MainActor func testCompleteResetToDefaults() async throws {
        let settings = UserSettings.shared
        
        // First, modify all settings to non-default values
        settings.retireeName = "TestUser"
        settings.subtitleMessage = "Custom message"
        settings.celebrationTitle = "custom celebration"
        settings.startDate = Calendar.current.date(from: DateComponents(year: 2010, month: 5, day: 15)) ?? Date()
        settings.retirementDate = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31)) ?? Date()
        settings.retirementTimeZone = TimeZone(identifier: "America/Los_Angeles") ?? TimeZone.current
        settings.workDayEndHour = 18
        settings.workDayEndMinute = 30
        settings.notificationsEnabled = false
        settings.notificationHour = 9
        settings.notificationMinute = 15
        settings.defaultShowWorkingDays = false
        
        // Force synchronization
        UserDefaults.standard.synchronize()
        
        // Verify non-default values are set
        #expect(settings.retireeName == "TestUser")
        #expect(settings.subtitleMessage == "Custom message")
        #expect(settings.notificationsEnabled == false)
        #expect(settings.workDayEndHour == 18)
        
        // Perform reset
        settings.resetToDefaults()
        
        // Force synchronization
        UserDefaults.standard.synchronize()
        
        // Verify all defaults are restored
        #expect(settings.retireeName == "Your Name", "Name should reset to placeholder default")
        #expect(settings.subtitleMessage == "The final stretch to freedom!", "Subtitle should reset to default")
        #expect(settings.celebrationTitle == "has retired!", "Celebration title should reset to default")
        
        // Check smart date defaults (dynamic based on current year)
        let currentYear = Calendar.current.component(.year, from: Date())
        
        var expectedStartComponents = DateComponents()
        expectedStartComponents.year = currentYear - 5
        expectedStartComponents.month = 1
        expectedStartComponents.day = 1
        expectedStartComponents.hour = 8
        expectedStartComponents.minute = 0
        expectedStartComponents.timeZone = TimeZone.current
        let expectedStartDate = Calendar.current.date(from: expectedStartComponents)
        
        var expectedRetirementComponents = DateComponents()
        expectedRetirementComponents.year = (currentYear - 5) + 30  // 30-year career
        expectedRetirementComponents.month = 12
        expectedRetirementComponents.day = 31
        expectedRetirementComponents.hour = 17
        expectedRetirementComponents.minute = 0
        expectedRetirementComponents.timeZone = TimeZone.current
        let expectedRetirementDate = Calendar.current.date(from: expectedRetirementComponents)
        
        #expect(Calendar.current.isDate(settings.startDate, inSameDayAs: expectedStartDate ?? Date()), "Start date should reset to smart default (5 years ago)")
        #expect(Calendar.current.isDate(settings.retirementDate, inSameDayAs: expectedRetirementDate ?? Date()), "Retirement date should reset to smart default (30-year career)")
        
        // Check timezone (should use device timezone)
        #expect(settings.retirementTimeZone.identifier == TimeZone.current.identifier, "Timezone should reset to device timezone")
        
        // Check work settings
        #expect(settings.workDayEndHour == 17, "Work day end hour should reset to 17")
        #expect(settings.workDayEndMinute == 0, "Work day end minute should reset to 0")
        
        // Check notification settings
        #expect(settings.notificationsEnabled == true, "Notifications should be enabled by default")
        #expect(settings.notificationHour == 17, "Notification hour should reset to 17")
        #expect(settings.notificationMinute == 0, "Notification minute should reset to 0")
        
        // Check display settings
        #expect(settings.defaultShowWorkingDays == true, "Should default to showing working days")
    }
    
    @Test @MainActor func testUserDefaultsClearingOnReset() async throws {
        let settings = UserSettings.shared
        
        // Set custom values
        settings.retireeName = "CustomName"
        settings.workDayEndHour = 19
        settings.notificationsEnabled = false
        
        // Verify values are saved in UserDefaults
        UserDefaults.standard.synchronize()
        #expect(UserDefaults.standard.string(forKey: "retireeName") == "CustomName")
        #expect(UserDefaults.standard.integer(forKey: "workDayEndHour") == 19)
        #expect(UserDefaults.standard.bool(forKey: "notificationsEnabled") == false)
        
        // Reset to defaults
        settings.resetToDefaults()
        UserDefaults.standard.synchronize()
        
        // Verify UserDefaults now contain smart default values
        #expect(UserDefaults.standard.string(forKey: "retireeName") == "Your Name")
        #expect(UserDefaults.standard.integer(forKey: "workDayEndHour") == 17)
        #expect(UserDefaults.standard.bool(forKey: "notificationsEnabled") == true)
    }
    
    @Test @MainActor func testNewUserDefaults() async throws {
        // First clear UserDefaults and reset settings to simulate new user
        let allKeys = ["retireeName", "subtitleMessage", "celebrationTitle", "startDate", "retirementDate", "retirementTimeZone", "workDayEndHour", "workDayEndMinute", "notificationsEnabled", "notificationHour", "notificationMinute", "defaultShowWorkingDays"]
        
        for key in allKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
        
        // Reset the singleton to defaults to simulate fresh initialization
        let settings = UserSettings.shared
        settings.resetToDefaults()  // This will set the smart defaults
        
        // These should be the smart default values a new user sees
        #expect(settings.retireeName == "Your Name", "Default name should prompt for personalization")
        #expect(settings.subtitleMessage == "The final stretch to freedom!", "Default subtitle should be motivational")
        #expect(settings.notificationsEnabled == true, "Notifications should be enabled by default")
        #expect(settings.workDayEndHour == 17, "Default work day should end at 5 PM")
        #expect(settings.defaultShowWorkingDays == true, "Should show working days by default")
        
        // Check that timezone uses device timezone (better localization)
        #expect(settings.retirementTimeZone.identifier == TimeZone.current.identifier, "Should use device timezone")
        
        // Check that dates are set to smart dynamic values
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let startYear = calendar.component(.year, from: settings.startDate)
        let retirementYear = calendar.component(.year, from: settings.retirementDate)
        
        #expect(startYear == currentYear - 5, "Default start year should be 5 years ago")
        #expect(retirementYear == (currentYear - 5) + 30, "Default retirement year should be 30-year career from start")
    }

}

enum TestError: Error {
    case persistenceFailure(String)
}
