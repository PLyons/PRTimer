//
//  BackgroundView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct BackgroundView: View {
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    var body: some View {
        colorTheme.backgroundGradient
            .overlay(animatedOverlays)
            .ignoresSafeArea()
    }
    
    private var animatedOverlays: some View {
        ZStack {
            // Top right glow - adapts to theme
            Circle()
                .fill(RadialGradient(
                    colors: [colorTheme.accentColor.opacity(0.2), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                ))
                .frame(width: 400, height: 400)
                .offset(x: 150, y: -200)
                .animation(.easeInOut(duration: 2.0), value: colorTheme.accentColor)
            
            // Bottom left glow - adapts to theme
            Circle()
                .fill(RadialGradient(
                    colors: [colorTheme.accentColor.opacity(0.15), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 150
                ))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: 250)
                .animation(.easeInOut(duration: 2.0), value: colorTheme.accentColor)
            
            // Center subtle glow
            Circle()
                .fill(RadialGradient(
                    colors: [Color.white.opacity(0.05), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                ))
                .frame(width: 200, height: 200)
        }
    }
}

#Preview {
    BackgroundView()
        .environmentObject(ColorThemeManager())
}