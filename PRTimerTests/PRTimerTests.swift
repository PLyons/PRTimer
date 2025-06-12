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
        
        // Create UserSettings instance
        let settings = UserSettings.shared
        let originalStartDate = settings.startDate
        
        // Modify start date
        let newStartDate = Calendar.current.date(from: DateComponents(year: 2010, month: 6, day: 15, hour: 9, minute: 0)) ?? Date()
        settings.startDate = newStartDate
        
        // Verify it was saved to UserDefaults
        let savedDate = UserDefaults.standard.object(forKey: "startDate") as? Date
        #expect(savedDate != nil, "startDate should be saved to UserDefaults")
        #expect(savedDate == newStartDate, "Saved date should match the new start date")
        
        // Test loading by creating new settings and checking the value persists
        settings.startDate = originalStartDate // Reset temporarily
        
        // Simulate loading from UserDefaults
        if let loadedDate = UserDefaults.standard.object(forKey: "startDate") as? Date {
            #expect(loadedDate == newStartDate, "Loaded date should match the previously saved date")
        } else {
            throw TestError.persistenceFailure("Could not load startDate from UserDefaults")
        }
    }

}

enum TestError: Error {
    case persistenceFailure(String)
}
