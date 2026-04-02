# PRTimer Refactoring Plan

This document outlines code review findings and planned improvements.
Items are grouped by priority. No changes have been made yet — this is a review document only.

---

## Part 1: Code Review Findings (Advisory)

These issues were identified during a review of the codebase. They are not blockers,
but represent technical debt worth addressing in future work.

### MVVM Structure Issues

**1. Milestone checking in the View layer**
- File: `PRTimer/Views/ContentView.swift` lines 61–66
- Problem: `ContentView` directly calls `milestoneManager.checkForMilestones(...)` inside an `onReceive` block. Business logic like milestone detection belongs in `CountdownViewModel`, not in a View.
- Recommendation: Move the milestone check call into `CountdownViewModel.updateCountdown()` so the ViewModel drives milestone state.

**2. `UserSettings` has dual responsibility**
- File: `PRTimer/Models/UserSettings.swift`
- Problem: The class acts as both a data model and a persistence layer (12 `@Published` properties each with a `didSet` that writes to `UserDefaults`). This violates the Single Responsibility Principle and makes it hard to test.
- Recommendation: Extract persistence into a `UserSettingsRepository` service that `UserSettings` calls, keeping settings as a pure observable model.

**3. Inconsistent `didSet` guards on `UserSettings` properties**
- File: `PRTimer/Models/UserSettings.swift` line 48 vs line 23
- Problem: `startDate.didSet` guards with `!isInitializing && hasLoadedFromDefaults`, while every other property only checks `!isInitializing`. This asymmetry risks premature saves being skipped or triggered unexpectedly.
- Recommendation: Apply the same guard logic consistently to all properties.

**4. Duplicate default-date calculation logic**
- File: `PRTimer/Models/UserSettings.swift` lines 133–155 (init) and 326–343 (resetToDefaults)
- Problem: The same date-building code is copy-pasted in two places. Any future change must be made in both locations.
- Recommendation: Extract the default-date calculation into a private helper method and call it from both `init()` and `resetToDefaults()`.

---

### Best Practice Issues

**5. `RetirementConstants` is dead code with hardcoded 2025 dates**
- File: `PRTimer/Models/CountdownData.swift` lines 43–96
- Problem: `RetirementConstants` contains hardcoded October 10, 2025 dates that are no longer used by `CountdownViewModel` (which correctly uses `userSettings`). However, `LaunchOptimizer` and `NotificationManager` still reference `RetirementConstants.retirementDate`, meaning their logic is also pinned to 2025.
- Recommendation: Remove `RetirementConstants`. Update `LaunchOptimizer` and `NotificationManager` to accept or read from `UserSettings`.

**6. Hardcoded 2025 date in `getDebugInfo()`**
- File: `PRTimer/ViewModels/CountdownViewModel.swift` lines 322–331
- Problem: `getDebugInfo()` creates a local `retirementDate` with a hardcoded 2025 date, then uses this instead of `userSettings.retirementDate`. The debug output would always show the wrong retirement date for any user with a different retirement year.
- Recommendation: Remove the local `retirementComponents` block and use `userSettings.retirementDate` directly in the formatted output.

**7. Force-unwrap of `TimeZone` identifier**
- File: `PRTimer/Utilities/WorkingDaysCalculator.swift` line 7
- Problem: `TimeZone(identifier: "America/New_York")!` will crash if the identifier is ever unrecognized (e.g., if future OS changes affect time zone availability).
- Recommendation: Replace with `?? TimeZone.current` as a safe fallback.

**8. Timer does not pause in background**
- File: `PRTimer/ContentView.swift` lines 83–84
- Problem: The `.background` and `.inactive` scene phase cases are no-ops, so the 1-second timer keeps running even when the app is backgrounded. The timer is correctly restarted on `.active`, so there's no correctness issue, but it wastes CPU and battery while backgrounded.
- Recommendation: Call `viewModel.stopUpdating()` on `.background` and let the existing `.active` handler restart it.

---

## Part 2: Holiday Feature — Implementation Steps

### Overview

Replace the hardcoded `HolidayCalculator` (3 holidays, 2025 only) with a dynamic
`HolidayManager` that:
- Calculates all 11 US federal holidays correctly for any year
- Respects US federal weekend-observation rules (Saturday → Friday, Sunday → Monday)
- Lets the user toggle each standard holiday on or off
- Lets the user add custom annual holidays (name + month/day)
- Persists user preferences in `UserDefaults`

---

### Step 1 — Create `HolidayManager.swift`
**File:** `PRTimer/PRTimer/Models/HolidayManager.swift` *(new file)*

**Types to define:**

`HolidayRule` — `enum`, `Codable`, `Equatable`
Encodes how a holiday's date is calculated:
- `.fixed(month: Int, day: Int)` — e.g., July 4th, Christmas
  - Applies federal observation: Saturday → Friday, Sunday → Monday
- `.nthWeekday(month: Int, weekday: Int, ordinal: Int)` — e.g., 3rd Monday of January
  - Uses `Calendar.dateComponents` with `weekdayOrdinal`
- `.lastWeekday(month: Int, weekday: Int)` — e.g., last Monday of May
  - Finds the last occurrence of a weekday in a given month
- `.custom(month: Int, day: Int)` — user-added annual holidays (same calc as `.fixed` but no observation shift)

`Holiday` — `struct`, `Identifiable`, `Codable`, `Equatable`
- `id: UUID`
- `name: String`
- `rule: HolidayRule`
- `isEnabled: Bool`
- `isStandard: Bool` — `true` for built-in US holidays, `false` for user-added

`HolidayManager` — `class`, `ObservableObject`
- `static let shared: HolidayManager`
- `@Published var holidays: [Holiday]` — all standard + custom holidays
- `func isHoliday(_ date: Date) -> Bool` — used by `WorkingDaysCalculator`
- `func holidayDates(for year: Int) -> [Date]` — used by the settings view for display
- `func addCustomHoliday(name: String, month: Int, day: Int)`
- `func removeHoliday(id: UUID)`
- `func toggleHoliday(id: UUID)`
- `func resetToDefaults()` — re-enables all standard holidays, removes custom ones
- Persistence via `UserDefaults` with JSON encoding/decoding

**Standard US Federal Holidays (default `isEnabled = true`):**

| # | Holiday | Rule |
|---|---------|------|
| 1 | New Year's Day | `.fixed(month: 1, day: 1)` |
| 2 | Martin Luther King Jr. Day | `.nthWeekday(month: 1, weekday: 2, ordinal: 3)` |
| 3 | Presidents' Day | `.nthWeekday(month: 2, weekday: 2, ordinal: 3)` |
| 4 | Memorial Day | `.lastWeekday(month: 5, weekday: 2)` |
| 5 | Juneteenth National Independence Day | `.fixed(month: 6, day: 19)` |
| 6 | Independence Day | `.fixed(month: 7, day: 4)` |
| 7 | Labor Day | `.nthWeekday(month: 9, weekday: 2, ordinal: 1)` |
| 8 | Columbus Day | `.nthWeekday(month: 10, weekday: 2, ordinal: 2)` |
| 9 | Veterans Day | `.fixed(month: 11, day: 11)` |
| 10 | Thanksgiving Day | `.nthWeekday(month: 11, weekday: 5, ordinal: 4)` |
| 11 | Christmas Day | `.fixed(month: 12, day: 25)` |

*(weekday values follow `Calendar.weekday`: Sunday=1, Monday=2 … Saturday=7)*

---

### Step 2 — Create `HolidaysSettingsView.swift`
**File:** `PRTimer/PRTimer/Views/Settings/HolidaysSettingsView.swift` *(new file)*

A `Form`-based settings screen with:

**Section: "Federal Holidays"**
- One row per standard holiday
- Each row: `Toggle` (enable/disable) + holiday name + next occurrence date (e.g., "Jan 20, 2026")
- Disabled holidays are still listed but grayed out

**Section: "Custom Holidays"**
- Lists user-added holidays with swipe-to-delete
- "Add Holiday" button that opens an add sheet

**Add Holiday sheet:**
- `TextField` for holiday name
- Month picker (1–12, displayed as month names)
- Day picker (1–31)
- "Save" / "Cancel" buttons

**Section: "Quick Actions"**
- "Enable All Federal Holidays" button
- "Disable All Federal Holidays" button

**Section: "Reset"**
- "Reset to Defaults" button (confirms with alert)

---

### Step 3 — Update `WorkingDaysCalculator.swift`
**File:** `PRTimer/PRTimer/Utilities/WorkingDaysCalculator.swift`

Changes:
- In `isWorkingDay(_ date:)`, replace:
  ```swift
  if HolidayCalculator.isFederalHoliday(date) { return false }
  ```
  with:
  ```swift
  if HolidayManager.shared.isHoliday(date) { return false }
  ```
- Fix force-unwrap on line 7:
  ```swift
  // Before:
  private static let easternTimeZone = TimeZone(identifier: "America/New_York")!
  // After:
  private static let easternTimeZone = TimeZone(identifier: "America/New_York") ?? TimeZone.current
  ```

---

### Step 4 — Remove `HolidayCalculator.swift`
**File:** `PRTimer/PRTimer/Models/HolidayCalculator.swift`

Delete this file entirely. It is fully superseded by `HolidayManager`.

---

### Step 5 — Update `SettingsView.swift`
**File:** `PRTimer/PRTimer/Views/Settings/SettingsView.swift`

- Add a "Holidays" tab item between "Date & Time" and "Notifications":
  ```swift
  HolidaysSettingsView()
      .tabItem {
          Label("Holidays", systemImage: "calendar.badge.checkmark")
      }
  ```
- Ensure `HolidayManager` is available as an environment object in this view

---

### Step 6 — Wire up `HolidayManager` in app lifecycle
**Files:** `PRTimer/PRTimer/PRTimerApp.swift`, `PRTimer/PRTimer/ContentView.swift`

`PRTimerApp.swift`:
- Add `@StateObject private var holidayManager = HolidayManager.shared`
- Inject: `.environmentObject(holidayManager)`

`ContentView.swift`:
- Pass `holidayManager` to the settings sheet:
  ```swift
  .sheet(isPresented: $showingSettings) {
      SettingsView()
          .environmentObject(userSettings)
          .environmentObject(colorTheme)
          .environmentObject(notificationManager)
          .environmentObject(holidayManager)   // add this
  }
  ```

---

### Step 7 — Fix hardcoded date in `getDebugInfo()`
**File:** `PRTimer/PRTimer/ViewModels/CountdownViewModel.swift` lines 316–346

Remove the local `retirementComponents` block (lines 322–331) that creates a hardcoded 2025 date.
Update the debug string to use `userSettings.retirementDate` via the existing `formatter`.

---

## Verification Checklist

After implementation, verify each of the following:

- [ ] Project builds without errors or warnings
- [ ] `HolidaysSettingsView` preview renders correctly
- [ ] Toggling a holiday on/off persists across app restarts
- [ ] Adding a custom holiday persists and appears in working-day calculations
- [ ] Deleting a custom holiday removes it from calculations
- [ ] "Reset to Defaults" restores all 11 standard holidays enabled, removes custom holidays
- [ ] Working days count decreases when a holiday in the range is enabled
- [ ] Working days count increases when a holiday in the range is disabled
- [ ] Holiday dates calculate correctly for multiple years (spot-check below):
  - Memorial Day 2026 → May 25
  - Independence Day 2026 → July 3 (July 4 is Saturday → observed Friday)
  - Thanksgiving 2026 → November 26
  - Christmas 2026 → December 25
  - New Year's Day 2028 → January 3 (Jan 1 is Saturday → observed Friday)
- [ ] Existing unit tests pass without regressions
