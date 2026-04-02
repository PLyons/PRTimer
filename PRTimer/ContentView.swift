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
            @EnvironmentObject var notificationManager: NotificationManager
            @Environment(\.scenePhase) private var scenePhase

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
                        if viewModel.milestoneManager.showCelebration,
                           let milestone = viewModel.milestoneManager.currentMilestone {
                            CelebrationOverlay(
                                milestone: milestone,
                                isShowing: Binding(
                                    get: { viewModel.milestoneManager.showCelebration },
                                    set: { viewModel.milestoneManager.showCelebration = $0 }
                                )
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
                .environmentObject(viewModel.milestoneManager)
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
                .onChange(of: scenePhase) { _, phase in
                    switch phase {
                    case .active:
                        viewModel.refreshCountdown()
                        viewModel.restartTimer()
                    case .background:
                        viewModel.stopUpdating()
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
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
