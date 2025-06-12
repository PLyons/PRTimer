# PRTimer - Retirement Countdown App

A beautifully designed iOS app that helps you count down to retirement with real-time updates, milestone celebrations, and customizable settings.

## Features

### ⏰ Real-Time Countdown
- **Working Days**: Accurate calculation excluding weekends and holidays
- **Total Days**: Complete calendar countdown to retirement
- **Fridays Remaining**: Special Friday countdown for weekend anticipation
- **Live Timer**: Hours, minutes, and seconds updating in real-time

### 🎨 Dynamic Themes
- Beautiful color themes that change throughout the day
- Animated background gradients
- Particle effects and celebrations
- Adaptive UI that responds to time of day

### 🎉 Milestone Celebrations
- Automatic milestone detection (100 days, 50 days, etc.)
- Animated celebration overlays
- Friday countdown celebrations
- Retirement achievement celebration

### ⚙️ Comprehensive Settings
- **Personal Information**: Customize name and messages
- **Date & Time**: Set career start date, retirement date, and timezone
- **Notifications**: Daily milestone alerts and Friday celebrations
- **Work Schedule**: Configure work day end times for accurate calculations

### 📱 Smart Notifications
- iOS notification permissions integration
- Customizable notification timing
- Milestone and Friday celebration alerts
- Background app refresh support

## Architecture

### MVVM Design Pattern
- **Models**: `UserSettings`, `CountdownData`, `MilestoneManager`
- **ViewModels**: `CountdownViewModel` with real-time updates
- **Views**: Modular SwiftUI components with proper separation of concerns

### Key Components

#### CountdownViewModel
```swift
@MainActor
class CountdownViewModel: ObservableObject {
    @Published var countdownData = CountdownData()
    @Published var isRetired = false
    
    // Real-time timer management
    // Working days calculation
    // Progress tracking
}
```

#### UserSettings (Singleton)
```swift
@MainActor
class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    // Persistent storage with UserDefaults
    // Timezone-aware date handling
    // Validation and error checking
}
```

#### Modular View Structure
- `ContentView`: Main container with navigation
- `CountdownLayoutView`: Layout manager for countdown display
- `HeaderView`: Title and subtitle display
- `TimeBlockView`: Individual time unit display
- `ProgressBarView`: Visual progress indicator
- `SettingsView`: Tabbed settings interface

## Technical Implementation

### Date & Time Calculations
- **Timezone Awareness**: All calculations respect user-selected timezone
- **Working Days**: Excludes weekends using `WorkingDaysCalculator`
- **Real-time Updates**: 1-second timer for live countdown
- **Work Day Logic**: Transitions at configurable work day end time (default 5:00 PM ET)

### Data Persistence
- **UserDefaults Integration**: Automatic saving of all settings
- **Singleton Pattern**: Thread-safe shared UserSettings instance
- **Validation**: Input validation for dates, times, and settings
- **Migration**: Handles app updates and data format changes

### Performance Optimization
- **Launch Optimization**: `LaunchOptimizer` for fast app startup
- **Memory Management**: Efficient cleanup during background states
- **Animation Performance**: Optimized particle systems and transitions
- **Background Processing**: Minimal resource usage when backgrounded

## Installation & Setup

### Requirements
- iOS 18.0+
- Xcode 16.0+
- Swift 5.9+

### Build Instructions
1. Clone the repository
2. Open `PRTimer.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (`⌘+R`)

### Configuration
1. Launch the app
2. Tap the settings gear icon
3. Configure your personal information
4. Set your career start date and retirement date
5. Choose your preferred timezone
6. Enable notifications if desired

## Usage

### Setting Up Your Countdown
1. **Personal Tab**: Enter your name and customize messages
2. **Date & Time Tab**: 
   - Set your career start date (when you first started working)
   - Set your retirement date and time
   - Choose your timezone
   - Configure work day end time
3. **Notifications Tab**: Enable and customize notification preferences

### Understanding the Display
- **Main Counter**: Shows working days remaining by default
- **Toggle Button**: Switch between working days and total days
- **Progress Bar**: Visual representation of career completion
- **Friday Counter**: Special counter for Fridays remaining
- **Time Display**: Live hours, minutes, seconds until retirement

### Celebrations & Milestones
- The app automatically detects significant milestones
- Celebrations trigger at 1000, 500, 100, 50, 25, 10, 5, and 1 working days
- Friday celebrations occur every Friday
- Final retirement celebration when countdown reaches zero

## Testing

### Unit Tests
```bash
# Run all tests
xcodebuild test -scheme PRTimer -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test
xcodebuild test -scheme PRTimer -only-testing PRTimerTests/PRTimerTests/testUserSettingsPersistence
```

### Test Coverage
- **UserSettings Persistence**: Validates data saving/loading
- **Countdown Calculations**: Tests working days, total days, progress
- **Date Validation**: Ensures proper timezone handling
- **Milestone Detection**: Verifies celebration triggers

## Project Structure

```
PRTimer/
├── PRTimer/
│   ├── Models/
│   │   ├── UserSettings.swift          # Core settings management
│   │   ├── CountdownData.swift         # Countdown state data
│   │   ├── MilestoneManager.swift      # Milestone tracking
│   │   └── ColorThemeManager.swift     # Theme management
│   ├── ViewModels/
│   │   └── CountdownViewModel.swift    # Main countdown logic
│   ├── Views/
│   │   ├── ContentView.swift           # Main app container
│   │   ├── CountdownLayoutView.swift   # Countdown display layout
│   │   ├── HeaderView.swift            # Title and subtitle
│   │   ├── TimeBlockView.swift         # Individual time units
│   │   ├── ProgressBarView.swift       # Progress visualization
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift      # Settings container
│   │   │   ├── PersonalSettingsView.swift
│   │   │   ├── DateTimeSettingsView.swift
│   │   │   └── NotificationSettingsView.swift
│   │   └── ...
│   ├── Utilities/
│   │   ├── WorkingDaysCalculator.swift # Business logic
│   │   ├── NotificationManager.swift   # iOS notifications
│   │   └── LaunchOptimizer.swift       # Performance optimization
│   └── PRTimerApp.swift               # App entry point
├── PRTimerTests/
│   └── PRTimerTests.swift             # Unit tests
└── README.md
```

## Key Algorithms

### Working Days Calculation
```swift
// Excludes weekends, respects work day end time
func calculateWorkingDaysRemaining(from currentDate: Date, retirementDateTime: Date) -> Int {
    // Determine if current time is past work day end
    // Calculate from appropriate start date
    // Count only Monday-Friday
    return WorkingDaysCalculator.countWorkingDays(from: startDate, to: retirementDay)
}
```

### Progress Calculation
```swift
func calculateProgressPercentage(workingDaysRemaining: Int) -> Double {
    let totalWorkingDays = WorkingDaysCalculator.totalWorkingDays(
        from: userSettings.startDate,
        to: userSettings.retirementDate
    )
    let workingDaysCompleted = totalWorkingDays - workingDaysRemaining
    return (Double(workingDaysCompleted) / Double(totalWorkingDays)) * 100.0
}
```

## Contributing

### Development Guidelines
1. Follow MVVM architecture patterns
2. Use SwiftUI best practices
3. Maintain thread safety with `@MainActor`
4. Write unit tests for new features
5. Update documentation for API changes

### Code Style
- Swift naming conventions
- Clear, descriptive variable names
- Comprehensive comments for complex logic
- Modular, reusable components

## Troubleshooting

### Common Issues

**Settings Not Persisting**
- Ensure app has proper file system permissions
- Check UserDefaults access in iOS Settings
- Verify timezone settings are correct

**Countdown Not Updating**
- Check if app has background app refresh enabled
- Verify retirement date is in the future
- Ensure work day end time is correctly configured

**Notifications Not Working**
- Grant notification permissions in iOS Settings
- Check notification time settings in app
- Verify app is not in Do Not Disturb mode

### Debug Information
The app includes debug logging accessible through:
```swift
let debugInfo = viewModel.getDebugInfo()
print(debugInfo)
```

## License

This project was created with assistance from Claude AI and is intended for personal use.

## Credits

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>

---

**Version**: 1.0.0  
**Build**: 1  
**iOS Target**: 18.0+  
**Last Updated**: December 2024