//
//  MilestoneManager.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI
import Foundation

class MilestoneManager: ObservableObject {
    @Published var currentMilestone: Milestone?
    @Published var showCelebration = false
    @Published var celebrationType: CelebrationAnimationType = .confetti
    
    private var lastCheckedDays: Int = -1
    private var lastCheckedDate: Date = Date()
    
    // MARK: - Milestone Detection
    
    func checkForMilestones(totalDays: Int, fridaysLeft: Int) {
        let currentDays = totalDays
        let today = Date()
        
        // Check if we should trigger celebrations
        if shouldTriggerMilestone(currentDays: currentDays, today: today) {
            if let milestone = getMilestone(for: currentDays, fridaysLeft: fridaysLeft, date: today) {
                triggerCelebration(milestone: milestone)
            }
        }
        
        lastCheckedDays = currentDays
        lastCheckedDate = today
        
        // Update notifications when milestones change (but not too frequently)
        Task {
            await refreshNotificationsIfNeeded()
        }
    }
    
    /// Refresh notifications if enough time has passed since last update
    private func refreshNotificationsIfNeeded() async {
        let now = Date()
        let lastUpdate = UserDefaults.standard.object(forKey: "lastNotificationUpdate") as? Date ?? Date.distantPast
        
        // Only update notifications once per day to avoid excessive scheduling
        if now.timeIntervalSince(lastUpdate) > 86400 { // 24 hours
            await NotificationManager.shared.scheduleAllNotifications()
            UserDefaults.standard.set(now, forKey: "lastNotificationUpdate")
        }
    }
    
    private func shouldTriggerMilestone(currentDays: Int, today: Date) -> Bool {
        // Don't trigger on first load
        guard lastCheckedDays != -1 else { return false }
        
        // Trigger if days changed or it's a new day
        return currentDays != lastCheckedDays || !Calendar.current.isDate(today, inSameDayAs: lastCheckedDate)
    }
    
    private func getMilestone(for days: Int, fridaysLeft: Int, date: Date) -> Milestone? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Special day milestones (highest priority)
        if weekday == 6 { // Friday
            return Milestone(
                type: .friday,
                title: "It's Friday! 🎉",
                message: "Another week closer to freedom!",
                animation: .fireworks
            )
        }
        
        // Major countdown milestones
        let majorMilestones: [Int] = [100, 90, 80, 70, 60, 50, 40, 30, 25, 20, 15, 10, 5, 1]
        if majorMilestones.contains(days) {
            return Milestone(
                type: .majorCountdown,
                title: "\(days) Days Left! 🚀",
                message: getMilestoneMessage(for: days),
                animation: getAnimationType(for: days)
            )
        }
        
        // Weekly milestones (every 10 days)
        if days % 10 == 0 && days > 0 {
            return Milestone(
                type: .weekly,
                title: "\(days) Days Milestone! ⭐",
                message: "Keep counting down!",
                animation: .sparkles
            )
        }
        
        // Friday countdown milestones
        let fridayMilestones: [Int] = [20, 15, 10, 5, 1]
        if fridayMilestones.contains(fridaysLeft) {
            return Milestone(
                type: .fridayCountdown,
                title: "\(fridaysLeft) Fridays Left! 📅",
                message: "The weekend warrior's countdown!",
                animation: .confetti
            )
        }
        
        return nil
    }
    
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
            return "Another milestone reached! 🌟"
        }
    }
    
    private func getAnimationType(for days: Int) -> CelebrationAnimationType {
        switch days {
        case 100, 50, 10, 1:
            return .fireworks
        case 30, 20:
            return .confetti
        default:
            return .sparkles
        }
    }
    
    // MARK: - Celebration Triggering
    
    private func triggerCelebration(milestone: Milestone) {
        currentMilestone = milestone
        celebrationType = milestone.animation
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showCelebration = true
        }
        
        // Auto-dismiss after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.dismissCelebration()
        }
    }
    
    func dismissCelebration() {
        withAnimation(.easeOut(duration: 0.3)) {
            showCelebration = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.currentMilestone = nil
        }
    }
    
    // MARK: - Manual Celebration (for testing)
    
    //func triggerTestCelebration() {
    //    let testMilestone = Milestone(
    //        type: .majorCountdown,
    //        title: "Test Celebration! 🎉",
    //        message: "This is a test of the celebration system!",
    //        animation: .fireworks
    //    )
    //    triggerCelebration(milestone: testMilestone)
    //}
}

// MARK: - Data Models

struct Milestone {
    let type: MilestoneType
    let title: String
    let message: String
    let animation: CelebrationAnimationType
}

enum MilestoneType {
    case friday
    case majorCountdown
    case weekly
    case fridayCountdown
    case seasonal
}

enum CelebrationAnimationType {
    case confetti
    case fireworks
    case sparkles
    case balloons
}
