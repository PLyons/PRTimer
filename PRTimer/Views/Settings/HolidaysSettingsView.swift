//
//  HolidaysSettingsView.swift
//  PRTimer
//
//  Settings screen for managing US federal holidays and custom holidays.
//

import SwiftUI

struct HolidaysSettingsView: View {
    @EnvironmentObject var holidayManager: HolidayManager
    @EnvironmentObject var colorTheme: ColorThemeManager

    @State private var showingAddSheet = false
    @State private var showingResetAlert = false

    private let nextDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()

    private var standardHolidays: [Holiday] {
        holidayManager.holidays.filter(\.isStandard)
    }

    private var customHolidays: [Holiday] {
        holidayManager.holidays.filter { !$0.isStandard }
    }

    var body: some View {
        NavigationView {
            Form {

                // MARK: Federal Holidays
                Section {
                    ForEach(standardHolidays) { holiday in
                        Toggle(isOn: Binding(
                            get: { holiday.isEnabled },
                            set: { _ in holidayManager.toggleHoliday(id: holiday.id) }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(holiday.name)
                                    .foregroundColor(holiday.isEnabled ? .primary : .secondary)
                                if let next = holidayManager.nextOccurrence(of: holiday) {
                                    Text(nextDateFormatter.string(from: next))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .tint(colorTheme.accentColor)
                    }
                } header: {
                    Text("Federal Holidays")
                } footer: {
                    Text("Enabled holidays are excluded from your working-day count.")
                }

                // MARK: Custom Holidays
                Section {
                    if customHolidays.isEmpty {
                        Text("No custom holidays added.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(customHolidays) { holiday in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(holiday.name)
                                if let next = holidayManager.nextOccurrence(of: holiday) {
                                    Text(nextDateFormatter.string(from: next))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .onDelete { indexSet in
                            let ids = indexSet.map { customHolidays[$0].id }
                            ids.forEach { holidayManager.removeHoliday(id: $0) }
                        }
                    }

                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Holiday", systemImage: "plus")
                            .foregroundColor(colorTheme.accentColor)
                    }
                } header: {
                    Text("Custom Holidays")
                } footer: {
                    Text("Swipe left on a custom holiday to delete it.")
                }

                // MARK: Quick Actions
                Section {
                    Button("Enable All Federal Holidays") {
                        holidayManager.enableAllStandard()
                    }
                    .foregroundColor(colorTheme.accentColor)

                    Button("Disable All Federal Holidays") {
                        holidayManager.disableAllStandard()
                    }
                    .foregroundColor(.orange)
                } header: {
                    Text("Quick Actions")
                }

                // MARK: Reset
                Section {
                    Button("Reset to Defaults") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                } footer: {
                    Text("Restores all 11 standard holidays as enabled and removes custom holidays.")
                }
            }
            .navigationTitle("Holidays")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddSheet) {
                AddHolidaySheet()
                    .environmentObject(holidayManager)
            }
            .alert("Reset Holidays", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    holidayManager.resetToDefaults()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will re-enable all standard holidays and remove any custom holidays.")
            }
        }
    }
}

// MARK: - Add Holiday Sheet

struct AddHolidaySheet: View {
    @EnvironmentObject var holidayManager: HolidayManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDay = Calendar.current.component(.day, from: Date())

    private let monthSymbols = Calendar.current.monthSymbols

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Holiday Name", text: $name)
                } header: {
                    Text("Name")
                }

                Section {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(monthSymbols[month - 1]).tag(month)
                        }
                    }

                    Picker("Day", selection: $selectedDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                } header: {
                    Text("Date (repeats annually)")
                }
            }
            .navigationTitle("Add Holiday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        holidayManager.addCustomHoliday(
                            name: name.trimmingCharacters(in: .whitespaces),
                            month: selectedMonth,
                            day: selectedDay
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    HolidaysSettingsView()
        .environmentObject(HolidayManager.shared)
        .environmentObject(ColorThemeManager())
}
