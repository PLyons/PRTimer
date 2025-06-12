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
    
    var body: some View {
        ScrollView {
            VStack(spacing: geometry.size.height > 700 ? 25 : 12) {
                // Title section with theme indicator
                HeaderView()
                
                // Main countdown grid
                CountdownGridView(countdownData: viewModel.countdownData)
                    .frame(height: geometry.size.width > geometry.size.height ? 120 : 280)
                
                // Toggle button for days display
                DaysToggleView(viewModel: viewModel)
                    .padding(.top, -8)
                
                // Fridays counter with dynamic color
                FridayCountdownView(countdownData: viewModel.countdownData)
                    .padding(.top, -8)
                
                // Progress bar with dynamic colors
                //ProgressBarView(progress: viewModel.countdownData.progressPercentage)
                //    .padding(.horizontal, 20)
                
                // Test celebration button (for demonstration)
                //Button("🎉 Test Celebration") {
                //    milestoneManager.triggerTestCelebration()
                //}
                //.font(.caption)
                //.foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                //.padding(.top, 10)
                
                if geometry.size.height < 700 {
                    Spacer(minLength: 20)
                } else {
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, geometry.safeAreaInsets.top + 20)
        }
    }
}

#Preview {
    GeometryReader { geometry in
        CountdownLayoutView(geometry: geometry)
            .environmentObject(CountdownViewModel())
            .environmentObject(ColorThemeManager())
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