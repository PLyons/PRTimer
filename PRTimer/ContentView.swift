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
                        colorTheme.backgroundGradient
                            .overlay(animatedOverlays)
                            .ignoresSafeArea()
                        
                        if viewModel.isRetired {
                            celebrationView
                        } else {
                            countdownView(geometry: geometry)
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
            
            private var celebrationView: some View {
                VStack(spacing: 20) {
                    Text("🎉")
                        .font(.system(size: 100))
                        .scaleEffect(1.2)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                    
                    Text("Paul Has Retired!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                    
                    Text("Congratulations! 🎊")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            }
            
            private func countdownView(geometry: GeometryProxy) -> some View {
                ScrollView {
                    VStack(spacing: geometry.size.height > 700 ? 25 : 12) {
                        // Title section with theme indicator
                        titleSection
                        
                        // Main countdown grid
                        CountdownGridView(countdownData: viewModel.countdownData)
                            .frame(height: geometry.size.width > geometry.size.height ? 120 : 280)
                        
                        // Toggle button for days display
                        VStack(spacing: 6) {
                            Text("Working or Total Days?")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            daysToggleButton
                        }
                        .padding(.top, -8)
                        
                        // Fridays counter with dynamic color
                        fridaysSection
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
            
            private var titleSection: some View {
                VStack(spacing: 12) {
                    HStack {
                        // Enhanced emoji with glassmorphism
                        Text(colorTheme.currentTheme.emoji)
                            .font(.title2)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(colorTheme.accentColor.opacity(0.6), lineWidth: 2)
                                    )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        Text("Paul's Retirement Countdown")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                            .shadow(color: colorTheme.currentTheme.textShadowColor, radius: 2, x: 2, y: 2)
                        
                        // Enhanced emoji with glassmorphism
                        Text(colorTheme.currentTheme.emoji)
                            .font(.title2)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(colorTheme.accentColor.opacity(0.6), lineWidth: 2)
                                    )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .multilineTextAlignment(.center)
                    
                    Text("The final stretch to freedom!")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .shadow(color: colorTheme.currentTheme.textShadowColor, radius: 1, x: 1, y: 1)
                    
                    // Enhanced theme indicator
                    Text(colorTheme.currentTheme.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(colorTheme.accentColor.opacity(0.6), lineWidth: 1.5)
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
                .padding(.horizontal, 20)
            }
            
            private var fridaysSection: some View {
                HStack(spacing: 12) {
                    // Enhanced party emoji
                    Text("🎉")
                        .font(.system(size: 28))
                        .padding(12)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(colorTheme.accentColor.opacity(0.8), lineWidth: 2.5)
                                )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                        .breathing(duration: 2.5, scaleRange: 1.0...1.15)
                    
                    VStack(spacing: 4) {
                        // Friday number with enhanced styling
                        Text("\(viewModel.countdownData.formattedFridays)")
                            .font(.system(size: 36, weight: .black, design: .monospaced))
                            .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(colorTheme.accentColor.opacity(0.8), lineWidth: 2)
                                    )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                            .breathing(duration: 4.0, scaleRange: 1.0...1.05)
                        
                        Text("Fridays Left Until Freedom!")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                            .multilineTextAlignment(.center)
                            .shadow(color: colorTheme.currentTheme.textShadowColor, radius: 1, x: 1, y: 1)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(colorTheme.accentColor.opacity(0.4), lineWidth: 1.5)
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .frame(maxWidth: .infinity)
            }
            
            private var daysToggleButton: some View {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.toggleDaysDisplay()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: viewModel.showWorkingDays ? "briefcase.fill" : "calendar")
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
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showWorkingDays)
            }
        }

        #Preview {
            ContentView()
        }
