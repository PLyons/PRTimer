        //
        //  ContentView.swift
        //  PRTimer
        //
        //  Created by Paul Lyons on 6/5/25.
        //

        import SwiftUI

        struct ContentView: View {
            @EnvironmentObject var userSettings: UserSettings
            @StateObject private var colorTheme = ColorThemeManager()
            @StateObject private var milestoneManager = MilestoneManager()
            @EnvironmentObject var notificationManager: NotificationManager
            
            @State private var showingSettings = false
            @StateObject private var viewModel = CountdownViewModel()
            
            var body: some View {
                NavigationView {
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
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                            }
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
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                        .environmentObject(userSettings)
                        .environmentObject(colorTheme)
                        .environmentObject(notificationManager)
                }
            }
        }

        #Preview {
            ContentView()
                .environmentObject(UserSettings.shared)
                .environmentObject(NotificationManager.shared)
        }
