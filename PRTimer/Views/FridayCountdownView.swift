//
//  FridayCountdownView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct FridayCountdownView: View {
    let countdownData: CountdownData
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Enhanced party emoji
            partyEmojiView
            
            VStack(spacing: 4) {
                // Friday number with enhanced styling
                fridayNumberView
                
                Text("Fridays Left Until Freedom!")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                    .multilineTextAlignment(.center)
                    .shadow(color: colorTheme.currentTheme.textShadowColor, radius: 1, x: 1, y: 1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(colorTheme.accentColor.opacity(0.4), lineWidth: 1.5)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: .infinity)
    }
    
    private var partyEmojiView: some View {
        Text("🎉")
            .font(.system(size: 28))
            .padding(12)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(colorTheme.accentColor.opacity(0.8), lineWidth: 2.5)
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
            .breathing(duration: 2.5, scaleRange: 1.0...1.15)
    }
    
    private var fridayNumberView: some View {
        Text("\(countdownData.formattedFridays)")
            .font(.system(size: 36, weight: .black, design: .monospaced))
            .foregroundColor(colorTheme.currentTheme.primaryTextColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(colorTheme.accentColor.opacity(0.8), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            .breathing(duration: 4.0, scaleRange: 1.0...1.05)
    }
}

#Preview {
    FridayCountdownView(
        countdownData: CountdownData(
            workingDays: 42,
            totalDays: 65,
            fridays: 6,
            hours: 8,
            minutes: 23,
            seconds: 15,
            progress: 73.5
        )
    )
    .environmentObject(ColorThemeManager())
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
    .padding()
}