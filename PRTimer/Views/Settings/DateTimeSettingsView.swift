//
//  DateTimeSettingsView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct DateTimeSettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    @State private var showingTimeZonePicker = false
    
    // Common time zones for easy selection
    private let commonTimeZones: [TimeZone] = [
        TimeZone(identifier: "America/New_York")!,      // Eastern
        TimeZone(identifier: "America/Chicago")!,       // Central
        TimeZone(identifier: "America/Denver")!,        // Mountain
        TimeZone(identifier: "America/Los_Angeles")!,   // Pacific
        TimeZone(identifier: "UTC")!,                   // UTC
        TimeZone(identifier: "Europe/London")!,         // GMT
        TimeZone(identifier: "Europe/Paris")!,          // CET
        TimeZone(identifier: "Asia/Tokyo")!,            // JST
        TimeZone(identifier: "Australia/Sydney")!       // AEST
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Career Start Date")
                                .font(.headline)
                            Text("When you first started working")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    DatePicker(
                        "Select start date",
                        selection: $userSettings.startDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                } header: {
                    Text("Career Timeline")
                }
                
                Section {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Retirement Date & Time")
                                .font(.headline)
                            Text("When your countdown reaches zero")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    DatePicker(
                        "Select date and time",
                        selection: $userSettings.retirementDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    
                    if !userSettings.isRetirementDateValid {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Retirement date should be in the future")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                } header: {
                    Text("Target Date")
                }
                
                Section {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time Zone")
                                .font(.headline)
                            Text("Used for all time calculations")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        showingTimeZonePicker = true
                    }) {
                        HStack {
                            Text(timeZoneDisplayName(userSettings.retirementTimeZone))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Time Zone")
                }
                
                Section {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Work Day End Time")
                                .font(.headline)
                            Text("When working days are considered complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Picker("Hour", selection: $userSettings.workDayEndHour) {
                            ForEach(6...23, id: \.self) { hour in
                                Text("\(hour):00")
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        
                        Picker("Minute", selection: $userSettings.workDayEndMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text(String(format: ":%02d", minute))
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                    }
                    
                    if !userSettings.isWorkDayEndTimeValid {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Work day end time should be between 6 AM and 11 PM")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                } header: {
                    Text("Work Schedule")
                }
                
                Section {
                    HStack {
                        Image(systemName: "briefcase.circle")
                            .foregroundColor(colorTheme.accentColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Default Days Display")
                                .font(.headline)
                            Text("Show working days or total days by default")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Picker("Days Display", selection: $userSettings.defaultShowWorkingDays) {
                        Text("Working Days").tag(true)
                        Text("Total Days").tag(false)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Display Options")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text("Career Start: \(formattedStartDate)")
                                    .font(.subheadline)
                            } icon: {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundColor(colorTheme.accentColor)
                            }
                            
                            Label {
                                Text("Retirement: \(formattedRetirementDate)")
                                    .font(.subheadline)
                            } icon: {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(colorTheme.accentColor)
                            }
                            
                            Label {
                                Text("Time Zone: \(userSettings.retirementTimeZone.abbreviation() ?? "Unknown")")
                                    .font(.subheadline)
                            } icon: {
                                Image(systemName: "globe")
                                    .foregroundColor(colorTheme.accentColor)
                            }
                            
                            Label {
                                Text("Work Day Ends: \(workDayEndTimeString)")
                                    .font(.subheadline)
                            } icon: {
                                Image(systemName: "clock")
                                    .foregroundColor(colorTheme.accentColor)
                            }
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
                    Text("Summary")
                }
                
                Section {
                    Button("Reset Date & Time to Defaults") {
                        withAnimation {
                            userSettings.resetToDefaults()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Date & Time")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingTimeZonePicker) {
                timeZonePickerView
            }
        }
    }
    
    private var timeZonePickerView: some View {
        NavigationView {
            List {
                Section("Common Time Zones") {
                    ForEach(commonTimeZones, id: \.identifier) { timeZone in
                        Button(action: {
                            userSettings.retirementTimeZone = timeZone
                            showingTimeZonePicker = false
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(timeZoneDisplayName(timeZone))
                                        .foregroundColor(.primary)
                                    Text(timeZone.abbreviation() ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if timeZone.identifier == userSettings.retirementTimeZone.identifier {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(colorTheme.accentColor)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Time Zone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingTimeZonePicker = false
                    }
                }
            }
        }
    }
    
    private func timeZoneDisplayName(_ timeZone: TimeZone) -> String {
        switch timeZone.identifier {
        case "America/New_York": return "Eastern Time"
        case "America/Chicago": return "Central Time"
        case "America/Denver": return "Mountain Time"
        case "America/Los_Angeles": return "Pacific Time"
        case "UTC": return "UTC"
        case "Europe/London": return "Greenwich Mean Time"
        case "Europe/Paris": return "Central European Time"
        case "Asia/Tokyo": return "Japan Standard Time"
        case "Australia/Sydney": return "Australian Eastern Time"
        default: return timeZone.localizedName(for: .standard, locale: .current) ?? timeZone.identifier
        }
    }
    
    private var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.timeZone = userSettings.retirementTimeZone
        return formatter.string(from: userSettings.startDate)
    }
    
    private var formattedRetirementDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.timeZone = userSettings.retirementTimeZone
        return formatter.string(from: userSettings.retirementDate)
    }
    
    private var workDayEndTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = userSettings.retirementTimeZone
        
        // Create a complete date for today with the specified time
        let today = Date()
        var components = Calendar.current.dateComponents([.year, .month, .day], from: today)
        components.hour = userSettings.workDayEndHour
        components.minute = userSettings.workDayEndMinute
        components.timeZone = userSettings.retirementTimeZone
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(userSettings.workDayEndHour):\(String(format: "%02d", userSettings.workDayEndMinute))"
    }
}

#Preview {
    DateTimeSettingsView()
        .environmentObject(UserSettings.shared)
        .environmentObject(ColorThemeManager())
}