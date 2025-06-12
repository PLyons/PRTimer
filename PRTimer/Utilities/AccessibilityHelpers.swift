//
//  AccessibilityHelpers.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI
import Foundation

/// Accessibility utilities and helpers
struct AccessibilityHelpers {
    
    // MARK: - Accessibility Labels
    
    static func countdownLabel(days: Int, hours: Int, minutes: Int, seconds: Int) -> String {
        var components: [String] = []
        
        if days > 0 {
            components.append("\(days) \(days == 1 ? "day" : "days")")
        }
        if hours > 0 {
            components.append("\(hours) \(hours == 1 ? "hour" : "hours")")
        }
        if minutes > 0 {
            components.append("\(minutes) \(minutes == 1 ? "minute" : "minutes")")
        }
        if seconds > 0 {
            components.append("\(seconds) \(seconds == 1 ? "second" : "seconds")")
        }
        
        if components.isEmpty {
            return "Retirement time has arrived!"
        }
        
        return "Time remaining until retirement: " + components.joined(separator: ", ")
    }
    
    static func progressLabel(percentage: Double) -> String {
        return "Retirement progress: \(String(format: "%.1f", percentage)) percent complete"
    }
    
    static func fridaysLabel(count: Int) -> String {
        if count == 0 {
            return "No Fridays remaining until retirement"
        } else if count == 1 {
            return "One Friday remaining until retirement"
        } else {
            return "\(count) Fridays remaining until retirement"
        }
    }
    
    static func themeLabel(themeName: String) -> String {
        return "Current theme: \(themeName)"
    }
    
    // MARK: - Dynamic Type Support
    
    static func adaptiveFont(style: Font.TextStyle, maxSize: CGFloat? = nil) -> Font {
        if maxSize != nil {
            return .system(style).weight(.medium)
        } else {
            return .system(style)
        }
    }
    
    // MARK: - Motion Sensitivity
    
    static var shouldReduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    static var shouldReduceTransparency: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }
    
    // MARK: - High Contrast Support
    
    static func contrastAwareColor(
        normal: Color,
        highContrast: Color? = nil
    ) -> Color {
        if UIAccessibility.isDarkerSystemColorsEnabled {
            return highContrast ?? normal
        }
        return normal
    }
}

// MARK: - Accessibility View Modifiers

extension View {
    /// Add comprehensive accessibility support
    func accessibleCountdown(
        days: Int,
        hours: Int,
        minutes: Int,
        seconds: Int
    ) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilityHelpers.countdownLabel(
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: seconds
            ))
            .accessibilityAddTraits(.updatesFrequently)
    }
    
    /// Add progress accessibility
    func accessibleProgress(percentage: Double) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilityHelpers.progressLabel(percentage: percentage))
            .accessibilityValue("\(Int(percentage))%")
            .accessibilityAddTraits(.updatesFrequently)
    }
    
    /// Add Fridays counter accessibility
    func accessibleFridays(count: Int) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilityHelpers.fridaysLabel(count: count))
            .accessibilityAddTraits(.updatesFrequently)
    }
    
    /// Add theme accessibility
    func accessibleTheme(name: String) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilityHelpers.themeLabel(themeName: name))
    }
    
    /// Add celebration accessibility
    func accessibleCelebration(milestone: String) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Celebration: \(milestone)")
            .accessibilityAddTraits(.playsSound)
            .accessibilityHint("Tap to dismiss")
    }
    
    /// Motion-sensitive animations
    func motionSafeAnimation<V: Equatable>(
        _ animation: Animation?,
        value: V
    ) -> some View {
        self.animation(
            AccessibilityHelpers.shouldReduceMotion ? nil : animation,
            value: value
        )
    }
    
    /// Transparency-aware backgrounds
    func transparencyAwareBackground<S: ShapeStyle>(
        _ style: S,
        fallback: S? = nil
    ) -> some View {
        self.background(
            AccessibilityHelpers.shouldReduceTransparency ?
                (fallback ?? style) : style
        )
    }
    
    /// Contrast-aware text
    func contrastAwareText(
        color: Color,
        highContrastColor: Color? = nil
    ) -> some View {
        self.foregroundColor(
            AccessibilityHelpers.contrastAwareColor(
                normal: color,
                highContrast: highContrastColor
            )
        )
    }
    
    /// Dynamic type support
    func supportsDynamicType() -> some View {
        self.font(.body)
    }
}

// MARK: - Accessible Color Schemes

extension Color {
    static let accessibleGreen = Color(red: 0.0, green: 0.7, blue: 0.0)
    static let accessibleBlue = Color(red: 0.0, green: 0.0, blue: 0.8)
    static let accessibleRed = Color(red: 0.8, green: 0.0, blue: 0.0)
    static let accessibleOrange = Color(red: 1.0, green: 0.5, blue: 0.0)
}

// MARK: - Voice Over Helpers

struct VoiceOverHelper {
    static func announce(_ text: String) {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }
    
    static func screenChanged() {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .screenChanged, argument: nil)
        }
    }
    
    static func layoutChanged() {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("89")
            .font(.largeTitle)
            .accessibleCountdown(days: 89, hours: 3, minutes: 45, seconds: 12)
        
        ProgressView(value: 0.65)
            .accessibleProgress(percentage: 65.0)
        
        Text("19 Fridays Left")
            .accessibleFridays(count: 19)
    }
    .padding()
}
