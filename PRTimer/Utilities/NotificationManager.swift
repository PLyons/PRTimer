//
//  NotificationManager.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {}
    
    // MARK: - Permission Management
    
    /// Request notification permissions from the user
    func requestPermissions() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            isAuthorized = granted
            
            if granted {
                await scheduleAllNotifications()
            }
        } catch {
            print("Failed to request notification permissions: \(error)")
            isAuthorized = false
        }
    }
    
    /// Check current notification authorization status
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Notification Scheduling
    
    /// Schedule all milestone notifications
    func scheduleAllNotifications() async {
        guard isAuthorized else { return }
        
        // Clear existing notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        await scheduleFridayNotifications()
        await scheduleMajorMilestones()
        await scheduleWeeklyMilestones()
        await scheduleFridayCountdownMilestones()
    }
    
    /// Schedule weekly Friday celebrations at 5:00 PM ET
    private func scheduleFridayNotifications() async {
        var dateComponents = DateComponents()
        dateComponents.weekday = 6 // Friday
        dateComponents.hour = 17 // 5:00 PM
        dateComponents.minute = 0
        dateComponents.timeZone = TimeZone(identifier: "America/New_York")
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let content = UNMutableNotificationContent()
        content.title = "🎉 It's Friday!"
        content.body = "Another week closer to Paul's retirement! Time to celebrate!"
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(
            identifier: "friday-celebration",
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    /// Schedule major milestone notifications (100, 90, 80, etc. days)
    private func scheduleMajorMilestones() async {
        let majorMilestones = [100, 90, 80, 70, 60, 50, 40, 30, 25, 20, 15, 10, 5, 1]
        let retirementDate = RetirementConstants.retirementDate
        let calendar = Calendar(identifier: .gregorian)
        
        for daysRemaining in majorMilestones {
            // Calculate the date when this milestone will be reached
            guard let milestoneDate = calendar.date(
                byAdding: .day,
                value: -daysRemaining,
                to: retirementDate
            ) else { continue }
            
            // Skip if milestone date is in the past
            if milestoneDate < Date() { continue }
            
            // Schedule notification for 5:00 PM ET on milestone date
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: milestoneDate)
            dateComponents.hour = 17
            dateComponents.minute = 0
            dateComponents.timeZone = TimeZone(identifier: "America/New_York")
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
            
            let content = UNMutableNotificationContent()
            content.title = "\(daysRemaining) Days Left! 🚀"
            content.body = getMilestoneMessage(for: daysRemaining)
            content.sound = .default
            content.badge = 1
            
            let request = UNNotificationRequest(
                identifier: "milestone-\(daysRemaining)-days",
                content: content,
                trigger: trigger
            )
            
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
    
    /// Schedule weekly milestone notifications (every 10 days)
    private func scheduleWeeklyMilestones() async {
        let retirementDate = RetirementConstants.retirementDate
        let calendar = Calendar(identifier: .gregorian)
        
        // Calculate total days until retirement
        let totalDays = calendar.dateComponents([.day], from: Date(), to: retirementDate).day ?? 0
        
        // Schedule notifications for every 10 days (excluding major milestones)
        let majorMilestones = [100, 90, 80, 70, 60, 50, 40, 30, 25, 20, 15, 10, 5, 1]
        
        for days in stride(from: (totalDays / 10) * 10, through: 10, by: -10) {
            // Skip if this is already a major milestone
            if majorMilestones.contains(days) { continue }
            
            guard let milestoneDate = calendar.date(
                byAdding: .day,
                value: -days,
                to: retirementDate
            ) else { continue }
            
            // Skip if milestone date is in the past
            if milestoneDate < Date() { continue }
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: milestoneDate)
            dateComponents.hour = 17
            dateComponents.minute = 0
            dateComponents.timeZone = TimeZone(identifier: "America/New_York")
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
            
            let content = UNMutableNotificationContent()
            content.title = "\(days) Days Milestone! ⭐"
            content.body = "Keep counting down to Paul's retirement!"
            content.sound = .default
            content.badge = 1
            
            let request = UNNotificationRequest(
                identifier: "weekly-milestone-\(days)-days",
                content: content,
                trigger: trigger
            )
            
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
    
    /// Schedule Friday countdown milestone notifications
    private func scheduleFridayCountdownMilestones() async {
        let fridayMilestones = [20, 15, 10, 5, 1]
        let retirementDate = RetirementConstants.retirementDate
        let calendar = Calendar(identifier: .gregorian)
        
        // Calculate total Fridays until retirement
        let totalFridays = WorkingDaysCalculator.countFridays(from: Date(), to: retirementDate)
        
        for fridaysRemaining in fridayMilestones {
            // Skip if we don't have enough Fridays left
            if fridaysRemaining > totalFridays { continue }
            
            // Find the date when we'll have exactly this many Fridays left
            var currentDate = Date()
            var fridayCount = totalFridays
            
            while fridayCount > fridaysRemaining {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                if calendar.component(.weekday, from: currentDate) == 6 { // Friday
                    fridayCount -= 1
                }
            }
            
            // Skip if milestone date is in the past
            if currentDate < Date() { continue }
            
            // Schedule notification for 5:00 PM ET on that Friday
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
            dateComponents.hour = 17
            dateComponents.minute = 0
            dateComponents.timeZone = TimeZone(identifier: "America/New_York")
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
            
            let content = UNMutableNotificationContent()
            content.title = "\(fridaysRemaining) Fridays Left! 📅"
            content.body = "The weekend warrior's countdown continues!"
            content.sound = .default
            content.badge = 1
            
            let request = UNNotificationRequest(
                identifier: "friday-milestone-\(fridaysRemaining)-fridays",
                content: content,
                trigger: trigger
            )
            
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getMilestoneMessage(for days: Int) -> String {
        switch days {
        case 100:
            return "Triple digits! The countdown is real! 💯"
        case 50:
            return "Halfway there! 🎯"
        case 30:
            return "One month to go! 📅"
        case 20:
            return "Less than three weeks! ⏰"
        case 10:
            return "Single digits! Almost there! 🔥"
        case 5:
            return "One work week left! 💼"
        case 1:
            return "FINAL DAY! Tomorrow is FREEDOM! 🎊"
        default:
            return "Another milestone reached on the path to retirement! 🌟"
        }
    }
    
    /// Remove all scheduled notifications
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Get count of pending notifications (for debugging)
    func getPendingNotificationCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }
}