//
//  SettingsView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var colorTheme: ColorThemeManager
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            TabView {
                PersonalSettingsView()
                    .tabItem {
                        Label("Personal", systemImage: "person.circle")
                    }
                
                DateTimeSettingsView()
                    .tabItem {
                        Label("Date & Time", systemImage: "calendar.circle")
                    }
                
                NotificationSettingsView()
                    .tabItem {
                        Label("Notifications", systemImage: "bell.circle")
                    }
                
                AboutSettingsView()
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset All") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("Reset All Settings", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                withAnimation {
                    userSettings.resetToDefaults()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset all settings to their default values. This action cannot be undone.")
        }
    }
    
    @State private var showingResetAlert = false
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var colorTheme: ColorThemeManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable Notifications")
                                .font(.headline)
                            Text("Receive milestone and Friday celebrations")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Toggle("Enable Notifications", isOn: $userSettings.notificationsEnabled)
                        .labelsHidden()
                        .onChange(of: userSettings.notificationsEnabled) { _, enabled in
                            Task {
                                if enabled {
                                    await notificationManager.requestPermissions()
                                }
                            }
                        }
                } header: {
                    Text("Notifications")
                }
                
                if userSettings.notificationsEnabled {
                    Section {
                        HStack {
                            Image(systemName: "clock.circle")
                                .foregroundColor(colorTheme.accentColor)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notification Time")
                                    .font(.headline)
                                Text("Daily time for milestone notifications")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Picker("Hour", selection: $userSettings.notificationHour) {
                                ForEach(0...23, id: \.self) { hour in
                                    Text("\(hour):00")
                                        .tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                            
                            Picker("Minute", selection: $userSettings.notificationMinute) {
                                ForEach([0, 15, 30, 45], id: \.self) { minute in
                                    Text(String(format: ":%02d", minute))
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                        }
                        
                        if !userSettings.isNotificationTimeValid {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Invalid notification time")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    } header: {
                        Text("Timing")
                    }
                    
                    Section {
                        HStack {
                            Text("Authorization Status")
                            Spacer()
                            Text(notificationManager.isAuthorized ? "Authorized" : "Not Authorized")
                                .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                                .fontWeight(.medium)
                        }
                        
                        if !notificationManager.isAuthorized {
                            Button("Request Permission") {
                                Task {
                                    await notificationManager.requestPermissions()
                                }
                            }
                            .foregroundColor(colorTheme.accentColor)
                        }
                    } header: {
                        Text("Status")
                    } footer: {
                        Text("Notifications require permission from iOS. You can also enable them in Settings app.")
                    }
                }
                
                Section {
                    Button("Reset to Defaults") {
                        withAnimation {
                            userSettings.notificationsEnabled = true
                            userSettings.notificationHour = 17
                            userSettings.notificationMinute = 0
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - About Settings View
struct AboutSettingsView: View {
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "timer")
                            .font(.system(size: 60))
                            .foregroundColor(colorTheme.accentColor)
                        
                        Text("PRTimer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Retirement Countdown App")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                } header: {
                    Text("App Information")
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Version")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "calendar", title: "Customizable Countdown", description: "Set your own retirement date and time")
                            FeatureRow(icon: "bell", title: "Smart Notifications", description: "Milestone celebrations and Friday alerts")
                            FeatureRow(icon: "paintbrush", title: "Dynamic Themes", description: "Beautiful themes that change throughout the day")
                            FeatureRow(icon: "briefcase", title: "Working Days", description: "Accurate calculation excluding weekends and holidays")
                            FeatureRow(icon: "star", title: "Milestone Tracking", description: "Celebrate important countdown milestones")
                        }
                    }
                } header: {
                    Text("What's Included")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🤖 Generated with Claude Code")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Text("Co-Authored-By: Claude <noreply@anthropic.com>")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Credits")
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Helper Views
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(colorTheme.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserSettings.shared)
        .environmentObject(ColorThemeManager())
        .environmentObject(NotificationManager.shared)
}