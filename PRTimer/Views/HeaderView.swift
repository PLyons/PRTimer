//
//  HeaderView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var colorTheme: ColorThemeManager
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Enhanced emoji with glassmorphism
                themeEmojiView
                
                Text(userSettings.countdownTitle)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                    .shadow(color: colorTheme.currentTheme.textShadowColor, radius: 2, x: 2, y: 2)
                
                // Enhanced emoji with glassmorphism
                themeEmojiView
            }
            .multilineTextAlignment(.center)
            
            Text(userSettings.subtitleMessage)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .shadow(color: colorTheme.currentTheme.textShadowColor, radius: 1, x: 1, y: 1)
            
            // Spacer to maintain layout spacing where theme indicator was
            Spacer()
                .frame(height: 28) // Approximate height of the removed theme indicator
        }
        .padding(.horizontal, 20)
    }
    
    private var themeEmojiView: some View {
        Text(colorTheme.currentTheme.emoji)
            .font(.title2)
            .padding(10)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(colorTheme.accentColor.opacity(0.6), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HeaderView()
        .environmentObject(ColorThemeManager())
        .environmentObject(UserSettings.shared)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.48, blue: 0.91),
                    Color(red: 0.46, green: 0.29, blue: 0.64)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}