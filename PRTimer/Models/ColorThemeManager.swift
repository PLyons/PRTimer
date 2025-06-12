//
//  ColorThemeManager.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI
import Foundation

/// Manages dynamic color themes based on time of day
class ColorThemeManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentTheme: ColorTheme = .morning
    @Published var backgroundGradient: LinearGradient = ColorTheme.morning.backgroundGradient
    @Published var accentColor: Color = ColorTheme.morning.accentColor
    
    // MARK: - Private Properties
    private var timer: Timer?
    
    // MARK: - Initialization
    init() {
        // Initialize with a default theme first
        let initialTheme = getCurrentTimeTheme()
        currentTheme = initialTheme
        backgroundGradient = initialTheme.backgroundGradient
        accentColor = initialTheme.accentColor
        
        // Then start the timer for future updates
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Timer Management
    
    /// Start the theme update timer (updates every 5 minutes)
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTheme()
            }
        }
    }
    
    // MARK: - Theme Management
    
    /// Update the current theme based on time of day
    @MainActor
    func updateTheme() {
        let newTheme = getCurrentTimeTheme()
        
        // Only animate if theme actually changed
        if newTheme != currentTheme {
            withAnimation(.easeInOut(duration: 2.0)) {
                currentTheme = newTheme
                backgroundGradient = newTheme.backgroundGradient
                accentColor = newTheme.accentColor
            }
        }
    }
    
    /// Get the appropriate theme for current time
    private func getCurrentTimeTheme() -> ColorTheme {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        switch hour {
        case 6..<11:
            return .morning      // 6 AM - 11 AM: Fresh morning
        case 11..<16:
            return .midday       // 11 AM - 4 PM: Bright midday
        case 16..<20:
            return .evening      // 4 PM - 8 PM: Golden hour
        default:
            return .night        // 8 PM - 6 AM: Deep night
        }
    }
    
    /// Manually force a theme (useful for testing)
    @MainActor
    func setTheme(_ theme: ColorTheme, animated: Bool = true) {
        if animated {
            withAnimation(.easeInOut(duration: 2.0)) {
                currentTheme = theme
                backgroundGradient = theme.backgroundGradient
                accentColor = theme.accentColor
            }
        } else {
            currentTheme = theme
            backgroundGradient = theme.backgroundGradient
            accentColor = theme.accentColor
        }
    }
    
    /// Get debug information about current theme
    func getDebugInfo() -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return """
        Current Time: \(formatter.string(from: Date()))
        Hour: \(hour)
        Theme: \(currentTheme.name)
        Next Theme Change: \(getNextThemeChangeTime())
        """
    }
    
    /// Get when the next theme change will occur
    private func getNextThemeChangeTime() -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        let nextChangeHour: Int
        switch hour {
        case 0..<6:
            nextChangeHour = 6
        case 6..<11:
            nextChangeHour = 11
        case 11..<16:
            nextChangeHour = 16
        case 16..<20:
            nextChangeHour = 20
        default:
            nextChangeHour = 6 // Next day
        }
        
        if nextChangeHour == 6 && hour >= 20 {
            return "6:00 AM tomorrow"
        } else {
            return "\(nextChangeHour):00"
        }
    }
}

// MARK: - Color Theme Definition

/// Represents different color themes for different times of day
enum ColorTheme: String, CaseIterable, Equatable {
    case morning = "morning"
    case midday = "midday"
    case evening = "evening"
    case night = "night"
    
    /// Human-readable name
    var name: String {
        switch self {
        case .morning:
            return "Fresh Morning"
        case .midday:
            return "Bright Midday"
        case .evening:
            return "Golden Hour"
        case .night:
            return "Deep Night"
        }
    }
    
    /// Background gradient for this theme
    var backgroundGradient: LinearGradient {
        switch self {
        case .morning:
            return LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.73, blue: 0.98),  // Light blue #66bbf2
                    Color(red: 0.33, green: 0.65, blue: 0.78) // Teal blue #54a6c7
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .midday:
            return LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.79, blue: 0.34), // Bright gold #feca57
                    Color(red: 0.99, green: 0.55, blue: 0.38)  // Orange #ff8c69
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .evening:
            return LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.55, blue: 0.38), // Orange #ff8c69
                    Color(red: 0.56, green: 0.27, blue: 0.68)  // Purple #8e44ad
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .night:
            return LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.48, blue: 0.91),  // Current purple #667eea
                    Color(red: 0.46, green: 0.29, blue: 0.64) // Current purple #764ba2
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    /// Accent color for progress bars and highlights
    var accentColor: Color {
        switch self {
        case .morning:
            return Color(red: 0.33, green: 0.65, blue: 0.78) // Teal
        case .midday:
            return Color(red: 0.99, green: 0.79, blue: 0.34) // Gold
        case .evening:
            return Color(red: 0.99, green: 0.55, blue: 0.38) // Orange
        case .night:
            return Color(red: 0.99, green: 0.79, blue: 0.34) // Gold (contrasts with purple)
        }
    }
    
    /// Primary text color that contrasts well with this theme
    var primaryTextColor: Color {
        switch self {
        case .morning:
            return .white
        case .midday:
            return Color(red: 0.2, green: 0.2, blue: 0.3) // Dark blue-gray for bright backgrounds
        case .evening:
            return .white
        case .night:
            return .white
        }
    }
    
    /// Secondary text color for less prominent text
    var secondaryTextColor: Color {
        switch self {
        case .morning:
            return .white.opacity(0.8)
        case .midday:
            return Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.7) // Dark blue-gray with opacity
        case .evening:
            return .white.opacity(0.8)
        case .night:
            return .white.opacity(0.8)
        }
    }
    
    /// Text shadow color for better readability
    var textShadowColor: Color {
        switch self {
        case .morning:
            return .black.opacity(0.3)
        case .midday:
            return .white.opacity(0.5) // Light shadow on dark text
        case .evening:
            return .black.opacity(0.3)
        case .night:
            return .black.opacity(0.3)
        }
    }
    
    /// Emoji representing this time of day with good contrast
    var emoji: String {
        switch self {
        case .morning:
            return "🌅"  // Sunrise - good contrast on blue
        case .midday:
            return "⭐"  // Star instead of sun - better contrast on gold/orange
        case .evening:
            return "🌆"  // Cityscape - good contrast on orange/purple
        case .night:
            return "🌙"  // Moon - good contrast on purple
        }
    }
    
    /// Alternative emoji with strong contrast for bright themes
    var contrastEmoji: String {
        switch self {
        case .morning:
            return "🌊"  // Wave - blue theme alternative
        case .midday:
            return "💎"  // Diamond - high contrast on bright background
        case .evening:
            return "🔥"  // Fire - fits golden hour theme
        case .night:
            return "✨"  // Sparkles - fits night theme
        }
    }
    
    /// Emoji background for better visibility
    var emojiBackgroundColor: Color {
        switch self {
        case .morning:
            return Color.clear  // No background needed on blue
        case .midday:
            return Color.black.opacity(0.2)  // Dark background for bright theme
        case .evening:
            return Color.clear  // No background needed
        case .night:
            return Color.clear  // No background needed on dark purple
        }
    }
}
