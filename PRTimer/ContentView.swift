        //
        //  ContentView.swift
        //  PRTimer
        //
        //  Created by Paul Lyons on 6/5/25.
        //

        import SwiftUI

        struct ContentView: View {
            @StateObject private var viewModel = CountdownViewModel()
            @StateObject private var colorTheme = ColorThemeManager()
            @StateObject private var milestoneManager = MilestoneManager()
            @EnvironmentObject var notificationManager: NotificationManager
            
            var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        // Dynamic background with animated overlays
                        BackgroundView()
                        
                        if viewModel.isRetired {
                            RetirementCelebrationView()
                        } else {
                            CountdownLayoutView(geometry: geometry)
                                .environmentObject(viewModel)
                        }
                        
                        // Milestone celebration overlay
                        if milestoneManager.showCelebration,
                           let milestone = milestoneManager.currentMilestone {
                            CelebrationOverlay(
                                milestone: milestone,
                                isShowing: $milestoneManager.showCelebration
                            )
                            .environmentObject(colorTheme)
                            .zIndex(1000)
                        }
                    }
                }
                .environmentObject(colorTheme)
                .environmentObject(milestoneManager)
                .onReceive(viewModel.$countdownData) { data in
                    // Check for milestones whenever countdown data updates
                    milestoneManager.checkForMilestones(
                        totalDays: data.workingDaysRemaining,
                        fridaysLeft: data.fridaysRemaining
                    )
                }
                .onAppear {
                    viewModel.startUpdating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.refreshCountdown()
                        colorTheme.updateTheme()
                    }
                }
                .onDisappear {
                    viewModel.stopUpdating()
                }
            }
        }

        #Preview {
            ContentView()
                .environmentObject(NotificationManager.shared)
        }
