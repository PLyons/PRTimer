//
//  HolidayManager.swift
//  PRTimer
//
//  Provides dynamic US federal holiday calculation for any year,
//  with user toggles and custom holiday support.
//

import Foundation

// MARK: - HolidayRule

/// Encodes how a holiday's date is calculated each year.
enum HolidayRule: Codable, Equatable {
    /// Fixed calendar date (e.g. July 4). Applies federal observation shift:
    /// Saturday → preceding Friday, Sunday → following Monday.
    case fixed(month: Int, day: Int)

    /// Nth occurrence of a weekday in a month (e.g. 3rd Monday of January).
    /// weekday uses Calendar values: Sunday=1, Monday=2 … Saturday=7.
    case nthWeekday(month: Int, weekday: Int, ordinal: Int)

    /// Last occurrence of a weekday in a month (e.g. last Monday of May).
    case lastWeekday(month: Int, weekday: Int)

    /// User-added annual holiday on a fixed date. No observation shift applied.
    case custom(month: Int, day: Int)

    /// Returns the observed holiday date for the given year.
    func date(in year: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date? {
        switch self {
        case .fixed(let month, let day):
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            guard let rawDate = calendar.date(from: components) else { return nil }
            return Self.applyObservationRules(to: rawDate, calendar: calendar)

        case .nthWeekday(let month, let weekday, let ordinal):
            var components = DateComponents()
            components.year = year
            components.month = month
            components.weekday = weekday
            components.weekdayOrdinal = ordinal
            return calendar.date(from: components)

        case .lastWeekday(let month, let weekday):
            return Self.lastOccurrence(of: weekday, in: month, year: year, calendar: calendar)

        case .custom(let month, let day):
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return calendar.date(from: components)
        }
    }

    /// US federal observation rules: Saturday → preceding Friday, Sunday → following Monday.
    private static func applyObservationRules(to date: Date, calendar: Calendar) -> Date {
        switch calendar.component(.weekday, from: date) {
        case 7: // Saturday → preceding Friday
            return calendar.date(byAdding: .day, value: -1, to: date) ?? date
        case 1: // Sunday → following Monday
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        default:
            return date
        }
    }

    /// Finds the last occurrence of a weekday in the given month and year.
    private static func lastOccurrence(of weekday: Int, in month: Int, year: Int, calendar: Calendar) -> Date? {
        // Build the last day of the target month by going to day 0 of the next month
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.day = 0
        guard let lastDay = calendar.date(from: components) else { return nil }

        // Walk backward up to 6 days to find the target weekday
        for offset in 0..<7 {
            let candidate = calendar.date(byAdding: .day, value: -offset, to: lastDay) ?? lastDay
            if calendar.component(.weekday, from: candidate) == weekday {
                return candidate
            }
        }
        return nil
    }
}

// MARK: - Holiday

struct Holiday: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var rule: HolidayRule
    var isEnabled: Bool
    /// true for the 11 built-in US federal holidays, false for user-added ones.
    let isStandard: Bool

    init(
        id: UUID = UUID(),
        name: String,
        rule: HolidayRule,
        isEnabled: Bool = true,
        isStandard: Bool = true
    ) {
        self.id = id
        self.name = name
        self.rule = rule
        self.isEnabled = isEnabled
        self.isStandard = isStandard
    }
}

// MARK: - HolidayManager

class HolidayManager: ObservableObject {

    static let shared = HolidayManager()

    @Published var holidays: [Holiday]

    private let calendar = Calendar(identifier: .gregorian)
    private let defaultsKey = "holidayManagerHolidays"

    private init() {
        holidays = Self.load() ?? Self.standardHolidays
    }

    // MARK: - Public API

    /// Returns true when the given date falls on any enabled holiday.
    func isHoliday(_ date: Date) -> Bool {
        let year = calendar.component(.year, from: date)
        let startOfDay = calendar.startOfDay(for: date)
        return holidays.lazy.filter(\.isEnabled).contains { holiday in
            guard let holidayDate = holiday.rule.date(in: year, calendar: calendar) else { return false }
            return calendar.isDate(startOfDay, inSameDayAs: holidayDate)
        }
    }

    /// Returns all enabled holiday dates for a given year, sorted ascending.
    func holidayDates(for year: Int) -> [Date] {
        holidays.filter(\.isEnabled).compactMap { holiday in
            holiday.rule.date(in: year, calendar: calendar)
        }.sorted()
    }

    /// Returns the next upcoming observed date for a holiday (today or later).
    func nextOccurrence(of holiday: Holiday) -> Date? {
        let today = calendar.startOfDay(for: Date())
        let currentYear = calendar.component(.year, from: today)
        for yearOffset in 0...1 {
            if let date = holiday.rule.date(in: currentYear + yearOffset, calendar: calendar),
               calendar.startOfDay(for: date) >= today {
                return date
            }
        }
        return nil
    }

    func addCustomHoliday(name: String, month: Int, day: Int) {
        let holiday = Holiday(
            name: name,
            rule: .custom(month: month, day: day),
            isEnabled: true,
            isStandard: false
        )
        holidays.append(holiday)
        save()
    }

    func removeHoliday(id: UUID) {
        holidays.removeAll { $0.id == id }
        save()
    }

    func toggleHoliday(id: UUID) {
        guard let index = holidays.firstIndex(where: { $0.id == id }) else { return }
        holidays[index].isEnabled.toggle()
        save()
    }

    func enableAllStandard() {
        for index in holidays.indices where holidays[index].isStandard {
            holidays[index].isEnabled = true
        }
        save()
    }

    func disableAllStandard() {
        for index in holidays.indices where holidays[index].isStandard {
            holidays[index].isEnabled = false
        }
        save()
    }

    /// Re-enables all standard holidays and removes any custom ones.
    func resetToDefaults() {
        holidays = Self.standardHolidays
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(holidays) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private static func load() -> [Holiday]? {
        guard let data = UserDefaults.standard.data(forKey: "holidayManagerHolidays"),
              let decoded = try? JSONDecoder().decode([Holiday].self, from: data) else {
            return nil
        }
        return decoded
    }

    // MARK: - Standard US Federal Holidays
    //
    // Calendar weekday values: Sunday=1, Monday=2, Tuesday=3,
    //                          Wednesday=4, Thursday=5, Friday=6, Saturday=7

    static let standardHolidays: [Holiday] = [
        Holiday(name: "New Year's Day",
                rule: .fixed(month: 1, day: 1)),
        Holiday(name: "Martin Luther King Jr. Day",
                rule: .nthWeekday(month: 1, weekday: 2, ordinal: 3)),
        Holiday(name: "Presidents' Day",
                rule: .nthWeekday(month: 2, weekday: 2, ordinal: 3)),
        Holiday(name: "Memorial Day",
                rule: .lastWeekday(month: 5, weekday: 2)),
        Holiday(name: "Juneteenth National Independence Day",
                rule: .fixed(month: 6, day: 19)),
        Holiday(name: "Independence Day",
                rule: .fixed(month: 7, day: 4)),
        Holiday(name: "Labor Day",
                rule: .nthWeekday(month: 9, weekday: 2, ordinal: 1)),
        Holiday(name: "Columbus Day",
                rule: .nthWeekday(month: 10, weekday: 2, ordinal: 2)),
        Holiday(name: "Veterans Day",
                rule: .fixed(month: 11, day: 11)),
        Holiday(name: "Thanksgiving Day",
                rule: .nthWeekday(month: 11, weekday: 5, ordinal: 4)),
        Holiday(name: "Christmas Day",
                rule: .fixed(month: 12, day: 25)),
    ]
}
