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
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Friday number with party emoji inline
            HStack(spacing: 8) {
                Text("🎉")
                    .font(.system(size: 36))
                
                Text("\(countdownData.formattedFridays)")
                    .font(.system(size: 44, weight: .heavy, design: .monospaced))
                    .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                    .shadow(color: colorTheme.currentTheme.textShadowColor, radius: 2, x: 2, y: 2)
                
                Text("🎉")
                    .font(.system(size: 36))
            }
            .frame(height: 50) // Fixed height for alignment
            
            Text("Fridays Left")
                .font(.system(size: 10, weight: .medium, design: .default))
                .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                .textCase(.uppercase)
                .tracking(1)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 40)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorTheme.accentColor.opacity(0.6), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 15)
        )
        .shimmer(intensity: 0.2, speed: 3.0)
        .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onTapGesture {
            // Enhanced tap animation with haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }
        .onHover { hovering in
            isHovered = hovering
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(countdownData.formattedFridays) Fridays Left")
        .accessibilityHint("Friday countdown component")
        .accessibilityAddTraits(.updatesFrequently)
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