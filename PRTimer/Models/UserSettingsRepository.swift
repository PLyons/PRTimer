//
//  UserSettingsRepository.swift
//  PRTimer
//
//  Handles all UserDefaults reads and writes for UserSettings,
//  keeping persistence concerns out of the observable model.
//

import Foundation

final class UserSettingsRepository {

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Keys

    enum Key: String {
        case retireeName
        case subtitleMessage
        case celebrationTitle
        case startDate
        case retirementDate
        case retirementTimeZone
        case workDayEndHour
        case workDayEndMinute
        case notificationsEnabled
        case notificationHour
        case notificationMinute
        case defaultShowWorkingDays
    }

    // MARK: - Save

    func save(
        retireeName: String,
        subtitleMessage: String,
        celebrationTitle: String,
        startDate: Date,
        retirementDate: Date,
        retirementTimeZone: TimeZone,
        workDayEndHour: Int,
        workDayEndMinute: Int,
        notificationsEnabled: Bool,
        notificationHour: Int,
        notificationMinute: Int,
        defaultShowWorkingDays: Bool
    ) {
        defaults.set(retireeName, forKey: Key.retireeName.rawValue)
        defaults.set(subtitleMessage, forKey: Key.subtitleMessage.rawValue)
        defaults.set(celebrationTitle, forKey: Key.celebrationTitle.rawValue)
        defaults.set(startDate, forKey: Key.startDate.rawValue)
        defaults.set(retirementDate, forKey: Key.retirementDate.rawValue)
        defaults.set(retirementTimeZone.identifier, forKey: Key.retirementTimeZone.rawValue)
        defaults.set(workDayEndHour, forKey: Key.workDayEndHour.rawValue)
        defaults.set(workDayEndMinute, forKey: Key.workDayEndMinute.rawValue)
        defaults.set(notificationsEnabled, forKey: Key.notificationsEnabled.rawValue)
        defaults.set(notificationHour, forKey: Key.notificationHour.rawValue)
        defaults.set(notificationMinute, forKey: Key.notificationMinute.rawValue)
        defaults.set(defaultShowWorkingDays, forKey: Key.defaultShowWorkingDays.rawValue)
    }

    // MARK: - Load (returns nil when a key has never been written)

    var retireeName: String? { defaults.object(forKey: Key.retireeName.rawValue) as? String }
    var subtitleMessage: String? { defaults.object(forKey: Key.subtitleMessage.rawValue) as? String }
    var celebrationTitle: String? { defaults.object(forKey: Key.celebrationTitle.rawValue) as? String }
    var startDate: Date? { defaults.object(forKey: Key.startDate.rawValue) as? Date }
    var retirementDate: Date? { defaults.object(forKey: Key.retirementDate.rawValue) as? Date }

    var retirementTimeZone: TimeZone? {
        guard let identifier = defaults.object(forKey: Key.retirementTimeZone.rawValue) as? String else { return nil }
        return TimeZone(identifier: identifier)
    }

    var workDayEndHour: Int? {
        defaults.object(forKey: Key.workDayEndHour.rawValue) != nil
            ? defaults.integer(forKey: Key.workDayEndHour.rawValue) : nil
    }

    var workDayEndMinute: Int? {
        defaults.object(forKey: Key.workDayEndMinute.rawValue) != nil
            ? defaults.integer(forKey: Key.workDayEndMinute.rawValue) : nil
    }

    var notificationsEnabled: Bool? {
        defaults.object(forKey: Key.notificationsEnabled.rawValue) != nil
            ? defaults.bool(forKey: Key.notificationsEnabled.rawValue) : nil
    }

    var notificationHour: Int? {
        defaults.object(forKey: Key.notificationHour.rawValue) != nil
            ? defaults.integer(forKey: Key.notificationHour.rawValue) : nil
    }

    var notificationMinute: Int? {
        defaults.object(forKey: Key.notificationMinute.rawValue) != nil
            ? defaults.integer(forKey: Key.notificationMinute.rawValue) : nil
    }

    var defaultShowWorkingDays: Bool? {
        defaults.object(forKey: Key.defaultShowWorkingDays.rawValue) != nil
            ? defaults.bool(forKey: Key.defaultShowWorkingDays.rawValue) : nil
    }
}
