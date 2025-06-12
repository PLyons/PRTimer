//
//  PersonalSettingsView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct PersonalSettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Retiree Name")
                                .font(.headline)
                            Text("This name will appear throughout the app")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    TextField("Enter name", text: $userSettings.retireeName)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                } header: {
                    Text("Personal Information")
                }
                
                Section {
                    HStack {
                        Image(systemName: "text.quote")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subtitle Message")
                                .font(.headline)
                            Text("Appears below the main title")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    TextField("Enter subtitle", text: $userSettings.subtitleMessage, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                    
                    HStack {
                        Image(systemName: "party.popper.fill")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Celebration Title")
                                .font(.headline)
                            Text("Shown when retirement is reached")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    TextField("Enter celebration message", text: $userSettings.celebrationTitle)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                } header: {
                    Text("Messages")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            Text(userSettings.countdownTitle)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                            
                            Text(userSettings.subtitleMessage)
                                .font(.subheadline)
                                .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                            
                            Text(userSettings.fullCelebrationTitle)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(colorTheme.accentColor)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colorTheme.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                } header: {
                    Text("Preview")
                } footer: {
                    Text("This shows how your customization will appear in the app.")
                }
                
                Section {
                    Button("Reset to Defaults") {
                        withAnimation {
                            userSettings.retireeName = "Paul"
                            userSettings.subtitleMessage = "The final stretch to freedom!"
                            userSettings.celebrationTitle = "has retired!"
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Personal")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    PersonalSettingsView()
        .environmentObject(UserSettings.shared)
        .environmentObject(ColorThemeManager())
}