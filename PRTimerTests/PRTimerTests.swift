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

}

enum TestError: Error {
    case persistenceFailure(String)
}
