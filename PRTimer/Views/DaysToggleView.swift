//
//  DaysToggleView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct DaysToggleView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @EnvironmentObject var colorTheme: ColorThemeManager
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Working or Total Days?")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                .textCase(.uppercase)
                .tracking(0.5)
            
            toggleButton
        }
    }
    
    private var toggleButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                userSettings.defaultShowWorkingDays.toggle()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: userSettings.defaultShowWorkingDays ? "briefcase.fill" : "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colorTheme.accentColor)
                
                Text(viewModel.countdownData.daysLabel)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                
                Image(systemName: "arrow.2.squarepath")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colorTheme.accentColor.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(colorTheme.accentColor.opacity(0.6), lineWidth: 1.5)
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: userSettings.defaultShowWorkingDays)
    }
}

#Preview {
    DaysToggleView(viewModel: CountdownViewModel())
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
        .padding()
}