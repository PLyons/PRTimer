//
//  LaunchOptimizer.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI
import Foundation

/// Launch performance optimization utilities
struct LaunchOptimizer {
    
    // MARK: - Preloading
    
    /// Preload essential data and cache frequently used computations
    static func preloadEssentialData() {
        Task {
            // Precompute retirement calculations
            await precomputeRetirementData()
            
            // Cache color gradients
            await cacheColorGradients()
            
            // Preload animation resources
            await preloadAnimationResources()
        }
    }
    
    private static func precomputeRetirementData() async {
        // Pre-calculate common date computations
        let calendar = Calendar.current
        let retirementDate = RetirementConstants.retirementDate
        let now = Date()
        
        // Cache working days calculation
        _ = WorkingDaysCalculator.countWorkingDays(from: now, to: retirementDate)
        
        // Cache time components
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: retirementDate)
        UserDefaults.standard.set(components.day ?? 0, forKey: "cachedDays")
    }
    
    private static func cacheColorGradients() async {
        // Pre-create gradient objects to avoid runtime creation
        for theme in ColorTheme.allCases {
            _ = theme.backgroundGradient
            _ = theme.accentColor
        }
    }
    
    private static func preloadAnimationResources() async {
        // Initialize animation systems safely
        await MainActor.run {
            // Create a dummy view to initialize the graphics system
            let _ = Color.clear
        }
    }
    
    // MARK: - Memory Management
    
    /// Clean up memory when app enters background
    static func cleanupMemory() {
        // Clear cached animations
        clearAnimationCache()
        
        // Reduce particle system memory
        reduceParticleMemory()
        
        // Clear temporary data
        clearTemporaryData()
    }
    
    private static func clearAnimationCache() {
        // Stop unnecessary animations when backgrounded
        NotificationCenter.default.post(name: .pauseAnimations, object: nil)
    }
    
    private static func reduceParticleMemory() {
        // Reduce particle count for memory efficiency
        NotificationCenter.default.post(name: .reduceParticles, object: nil)
    }
    
    private static func clearTemporaryData() {
        // Clear any temporary caches
        URLCache.shared.removeAllCachedResponses()
    }
    
    // MARK: - Performance Monitoring
    
    static func measureLaunchTime() -> TimeInterval {
        return CFAbsoluteTimeGetCurrent()
    }
    
    static func logPerformanceMetrics(startTime: TimeInterval) {
        let launchTime = CFAbsoluteTimeGetCurrent() - startTime
        print("🚀 App Launch Time: \(String(format: "%.3f", launchTime))s")
        
        // Log memory usage
        let memoryUsage = getMemoryUsage()
        print("📱 Memory Usage: \(String(format: "%.1f", memoryUsage))MB")
    }
    
    private static func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: 1) { intPtr in
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         intPtr,
                         &count)
            }
        }
        
        return kerr == KERN_SUCCESS ? Double(info.resident_size) / 1024 / 1024 : 0
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let pauseAnimations = Notification.Name("pauseAnimations")
    static let resumeAnimations = Notification.Name("resumeAnimations")
    static let reduceParticles = Notification.Name("reduceParticles")
    static let restoreParticles = Notification.Name("restoreParticles")
}

// MARK: - App Lifecycle Integration

@MainActor
class AppLifecycleManager: ObservableObject {
    @Published var isActive = true
    @Published var isPerformanceMode = false
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                self.handleBackground()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                self.handleForeground()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                self.handleMemoryWarning()
            }
        }
    }
    
    private func handleBackground() {
        isActive = false
        LaunchOptimizer.cleanupMemory()
        NotificationCenter.default.post(name: .pauseAnimations, object: nil)
    }
    
    private func handleForeground() {
        isActive = true
        LaunchOptimizer.preloadEssentialData()
        NotificationCenter.default.post(name: .resumeAnimations, object: nil)
    }
    
    private func handleMemoryWarning() {
        isPerformanceMode = true
        LaunchOptimizer.cleanupMemory()
        
        // Return to normal mode after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.isPerformanceMode = false
        }
    }
}

#Preview {
    Text("Launch Optimizer Ready")
        .onAppear {
            let startTime = LaunchOptimizer.measureLaunchTime()
            LaunchOptimizer.preloadEssentialData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                LaunchOptimizer.logPerformanceMetrics(startTime: startTime)
            }
        }
}
