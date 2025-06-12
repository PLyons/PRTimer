//
//  CountdownLayoutView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct CountdownLayoutView: View {
    let geometry: GeometryProxy
    @EnvironmentObject var viewModel: CountdownViewModel
    @EnvironmentObject var colorTheme: ColorThemeManager
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        ScrollView {
            VStack(spacing: geometry.size.height > 700 ? 15 : 8) {
                // Title section with theme indicator
                HeaderView()
                
                // Main countdown grid
                CountdownGridView(countdownData: viewModel.countdownData)
                    .frame(height: geometry.size.width > geometry.size.height ? 120 : 280)
                
                // Fridays counter with dynamic color
                FridayCountdownView(countdownData: viewModel.countdownData)
                    .padding(.top, -12)
                
                // Career Timeline section
                VStack(spacing: 8) {
                    Text("Career Timeline")
                        .font(.headline)
                        .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                        .padding(.top, 20)
                    
                    // Progress bar with dynamic colors
                    ProgressBarView(progress: viewModel.countdownData.progressPercentage)
                        .padding(.horizontal, 20)
                }
                
                // Test celebration button (for demonstration)
                //Button("🎉 Test Celebration") {
                //    milestoneManager.triggerTestCelebration()
                //}
                //.font(.caption)
                //.foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                //.padding(.top, 10)
                
                if geometry.size.height < 700 {
                    Spacer(minLength: 10)
                } else {
                    Spacer(minLength: 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}

#Preview {
    GeometryReader { geometry in
        CountdownLayoutView(geometry: geometry)
            .environmentObject(CountdownViewModel())
            .environmentObject(ColorThemeManager())
            .environmentObject(UserSettings.shared)
    }
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