//
//  TimeBlockView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct TimeBlockView: View {
    let value: String
    let label: String
    @State private var isPressed = false
    @State private var isHovered = false
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Animated number with particle effects
            AnimatedNumberView(value: value)
                .frame(height: 50) // Fixed height for number alignment
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .default))
                .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                .textCase(.uppercase)
                .tracking(1)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion for wrapping
                .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 40) // Give more space for wrapping
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
        .breathing(duration: 6.0, scaleRange: 1.0...1.01, opacityRange: 0.95...1.0)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(value) \(label)")
        .accessibilityHint("Countdown component")
        .accessibilityAddTraits(.updatesFrequently)
    }
    
    private var glassmorphismBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 15)
    }
    
    private var shimmerOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask(
                Rectangle()
                    .frame(height: 2)
                    .frame(maxWidth: .infinity, alignment: .top)
            )
            .animation(
                Animation.linear(duration: 2)
                    .repeatForever(autoreverses: false),
                value: UUID()
            )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.48, blue: 0.91),
                Color(red: 0.46, green: 0.29, blue: 0.64)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        HStack(spacing: 20) {
            TimeBlockView(value: "42", label: "Working Days")
            TimeBlockView(value: "08", label: "Hours")
        }
        .padding()
    }
}
