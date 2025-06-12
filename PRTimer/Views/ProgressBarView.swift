//
//  ProgressBarView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct ProgressBarView: View {
    let progress: Double // 0.0 to 100.0
    @State private var animatedProgress: Double = 0
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                // Background with simple glassmorphism
                RoundedRectangle(cornerRadius: 6)
                    .fill(.ultraThinMaterial)
                    .frame(height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Progress fill with enhanced effects
                RoundedRectangle(cornerRadius: 6)
                    .fill(dynamicProgressGradient)
                    .frame(width: max(0, CGFloat(animatedProgress / 100.0) * UIScreen.main.bounds.width * 0.8), height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(colorTheme.accentColor.opacity(0.8), lineWidth: 1)
                    )
                    .shimmer(intensity: 0.4, speed: 1.5)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .animation(.easeInOut(duration: 1.0), value: animatedProgress)
            }
            
            // Progress percentage text with enhanced styling
            Text(String(format: "%.1f%% Complete", progress))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(colorTheme.accentColor.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Retirement progress: \(String(format: "%.1f", progress)) percent complete")
        .accessibilityValue("\(Int(progress))%")
        .accessibilityAddTraits(.updatesFrequently)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
    
    private var dynamicProgressGradient: LinearGradient {
        LinearGradient(
            colors: [
                colorTheme.accentColor,
                colorTheme.accentColor.opacity(0.8)
            ],
            startPoint: .leading,
            endPoint: .trailing
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
        
        VStack(spacing: 30) {
            ProgressBarView(progress: 73.5)
            ProgressBarView(progress: 25.0)
            ProgressBarView(progress: 90.0)
        }
        .padding()
    }
}
