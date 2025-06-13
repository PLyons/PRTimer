# PRTimer - Development Context & Session Continuity Reference

**For Claude AI Assistant** - Comprehensive project understanding and session continuity

---

## 📋 Project Overview

**PRTimer** is a SwiftUI iOS retirement countdown app that helps users track their progress toward retirement with real-time calculations, milestone celebrations, and smart default settings.

### Key Stats
- **Platform**: iOS 18.0+ (Native SwiftUI)
- **Language**: Swift 5.9+
- **Architecture**: MVVM with Combine framework
- **Testing**: Swift Testing framework with 100% pass rate
- **Status**: Production-ready with comprehensive test coverage

## 🏗️ Architecture Deep Dive

### MVVM Implementation
```
UserSettings (Model/Singleton)
    ↓
CountdownViewModel (@MainActor)
    ↓  
SwiftUI Views (Modular Components)
```

### Key Design Patterns
1. **Singleton Pattern**: `UserSettings.shared` for global state
2. **Publisher/Subscriber**: Combine framework with `@Published` properties
3. **Modular Views**: Separation of concerns with dedicated view components
4. **Thread Safety**: `@MainActor` annotations throughout

### Data Flow
```
UserSettings → CountdownViewModel → Views
     ↓              ↓               ↓
UserDefaults    Real-time       UI Updates
Persistence     Calculations    & Animations
```

## 🔧 Critical Technical Implementation

### 1. UserSettings Race Condition Solution (MAJOR FIX)
**Problem**: Career start date persistence failing due to `didSet` triggers during initialization.

**Solution**: Dual-flag protection system
```swift
private var isInitializing = true
private var hasLoadedFromDefaults = false

@Published var startDate: Date {
    didSet { 
        if !isInitializing && hasLoadedFromDefaults {
            saveToUserDefaults() 
        }
    }
}
```

**Impact**: Resolved major persistence bug affecting user data integrity.

### 2. Smart Defaults System (ENHANCEMENT)
**Before**: Hard-coded values (Paul, Eastern timezone, October 2025)
**After**: Dynamic, device-aware defaults

```swift
// Smart date calculation
let currentYear = calendar.component(.year, from: Date())
startDate = // currentYear - 5 (5 years ago)
retirementDate = // (currentYear - 5) + 30 (30-year career)
retirementTimeZone = TimeZone.current // Device timezone
```

### 3. Work Day End Time Logic (BUG FIX)
**Problem**: Total days and working days calculations inconsistent.
**Solution**: Unified logic respecting work day end time.

```swift
if now >= todayAtWorkEnd {
    startDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
} else {
    startDate = calendar.startOfDay(for: now)
}
```

## 📁 Project Structure & Key Files

### Critical Files for Understanding
1. **`PRTimer/Models/UserSettings.swift`**
   - Singleton pattern with UserDefaults persistence
   - Dual-flag race condition protection
   - Smart default calculation logic
   - Comprehensive validation methods

2. **`PRTimer/ViewModels/CountdownViewModel.swift`**
   - Real-time countdown calculations
   - Work day end time logic implementation
   - Progress percentage calculations
   - Timer management and lifecycle

3. **`PRTimerTests/PRTimerTests.swift`**
   - Comprehensive test coverage
   - Smart defaults validation
   - Persistence testing with race condition protection
   - Reset functionality verification

### Architecture Layers
```
PRTimer/
├── Models/              # Data layer
│   ├── UserSettings.swift      # Core settings management (SINGLETON)
│   ├── CountdownData.swift     # Data structures
│   └── MilestoneManager.swift  # Milestone logic
├── ViewModels/          # Business logic layer  
│   └── CountdownViewModel.swift # Main countdown logic (@MainActor)
├── Views/               # UI layer (SwiftUI)
│   ├── ContentView.swift       # Main container
│   ├── CountdownLayoutView.swift # Layout management
│   └── Settings/               # Settings UI components
└── Utilities/           # Helper classes
    ├── WorkingDaysCalculator.swift # Business calculations
    └── NotificationManager.swift   # iOS integration
```

## 🧪 Testing Strategy & Coverage

### Test Categories
1. **Persistence Tests**: UserDefaults saving/loading with race condition protection
2. **Smart Defaults Tests**: Dynamic date calculation validation
3. **Reset Functionality Tests**: Complete data cleanup verification
4. **Date Logic Tests**: Timezone and work day end time handling
5. **New User Experience Tests**: First-launch behavior validation

### Test Execution
```bash
# Run all tests
xcodebuild test -scheme PRTimer -destination 'platform=iOS Simulator,name=iPhone 16'

# Key tests for debugging
xcodebuild test -scheme PRTimer -only-testing PRTimerTests/PRTimerTests/testUserSettingsPersistence
xcodebuild test -scheme PRTimer -only-testing PRTimerTests/PRTimerTests/testNewUserDefaults
```

## 🐛 Major Issues Resolved

### 1. Career Start Date Persistence (CRITICAL)
- **Symptoms**: Settings not saving across app launches
- **Root Cause**: `didSet` observers triggering during UserDefaults loading
- **Solution**: Dual-flag protection preventing saves during initialization
- **Status**: ✅ RESOLVED - All persistence tests passing

### 2. Total Days Calculation Inconsistency
- **Symptoms**: Total days not decreasing at 5:00 PM ET as expected
- **Root Cause**: Different logic for working days vs total days
- **Solution**: Unified work day end time logic for both calculations
- **Status**: ✅ RESOLVED - Consistent behavior confirmed

### 3. iPhone Build Errors
- **Symptoms**: Swift compilation errors about 'self' usage during initialization
- **Root Cause**: Property access before stored properties initialized
- **Solution**: Local variable usage during initialization
- **Status**: ✅ RESOLVED - Builds successfully on iPhone

### 4. Hard-coded Defaults
- **Symptoms**: Poor new user experience with outdated/inappropriate defaults
- **Root Cause**: Static values inappropriate for global audience
- **Solution**: Dynamic, device-aware smart defaults
- **Status**: ✅ RESOLVED - Smart defaults implemented and tested

## 🎯 User Experience Enhancements

### Smart Defaults Implementation
- **Name**: "Your Name" (encourages personalization)
- **Timezone**: Device timezone (automatic localization)
- **Career Start**: Current year - 5 (realistic recent start)
- **Retirement**: 30-year career from start (industry standard)

### Benefits
1. **Localization**: Automatic timezone detection
2. **Relevance**: Always-current dates that adapt over time
3. **User-Friendly**: Clear indicators for personalization needed
4. **Future-Proof**: Calculations remain valid as years progress

## 🔄 Development Workflow Understanding

### Session Continuity Context
When continuing development:

1. **Current State**: Production-ready with all major issues resolved
2. **Test Status**: 100% pass rate across comprehensive test suite
3. **Smart Defaults**: Fully implemented and validated
4. **Architecture**: Stable MVVM implementation with proper separation

### Common Development Tasks
1. **Adding New Features**: Follow MVVM pattern, add tests
2. **UI Changes**: Modify SwiftUI views, maintain modular structure
3. **Settings Changes**: Update UserSettings model and persistence
4. **Testing**: Use Swift Testing framework with #expect syntax

### Git Workflow
```bash
# Check current status
git status

# Review recent commits
git log --oneline -10

# Run tests before commits
xcodebuild test -scheme PRTimer
```

## 🚨 Critical Knowledge for Future Sessions

### UserSettings Singleton Pattern
- **Never recreate**: Always use `UserSettings.shared`
- **Thread Safety**: All access via `@MainActor`
- **Persistence**: Automatic via `didSet` observers (after initialization)
- **Race Conditions**: Protected by dual-flag system

### Date Calculation Logic
- **Work Day End**: Critical for daily transitions
- **Timezone Awareness**: All calculations respect user timezone
- **Weekend Exclusion**: Working days exclude Saturday/Sunday
- **Smart Defaults**: Dynamic calculation based on current year

### Test-Driven Development
- **Always run tests**: Before and after changes
- **Test Categories**: Persistence, defaults, reset, date logic
- **Validation**: Both unit tests and manual iPhone testing
- **Coverage**: All major functionality covered

### Performance Considerations
- **Timer Management**: Efficient 1-second intervals
- **Memory Usage**: Optimized singleton and observer patterns
- **Background Behavior**: Proper cleanup during app backgrounding

## 📋 Quick Reference Commands

### Build & Test
```bash
# Full test suite
xcodebuild test -scheme PRTimer -destination 'platform=iOS Simulator,name=iPhone 16'

# Build for iPhone
xcodebuild build -scheme PRTimer -destination 'platform=iOS,name=<device-name>'

# Clean build
xcodebuild clean -scheme PRTimer
```

### Git Operations
```bash
# Status and recent changes
git status
git diff

# Commit with proper message format
git add .
git commit -m "Description

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## 🎯 Future Development Priorities

### Immediate (Next Session)
1. **Onboarding Flow**: First-launch setup wizard
2. **Settings Validation**: Real-time input feedback
3. **UI Polish**: Animation refinements and accessibility

### Medium Term
1. **Widget Support**: iOS home screen integration
2. **Enhanced Notifications**: Rich notification content
3. **Data Export**: CSV/PDF progress reports

### Long Term
1. **Platform Expansion**: iPad, Apple Watch, macOS
2. **Advanced Features**: Achievement system, analytics
3. **App Store**: Preparation for distribution

## 🧠 Development Philosophy & Patterns

### Code Quality Standards
- **Clarity over Cleverness**: Readable, maintainable code
- **Test-Driven**: Comprehensive coverage for reliability
- **User-Centric**: Smart defaults and intuitive UX
- **Performance**: Efficient algorithms and memory usage

### Technical Decisions
- **Native iOS**: SwiftUI over cross-platform solutions
- **Local Storage**: UserDefaults over external databases
- **Privacy First**: No tracking or external dependencies
- **Accessibility**: VoiceOver and Dynamic Type support

---

**Last Updated**: June 13, 2025  
**Session Context**: Smart defaults implementation and comprehensive testing completed  
**Status**: Ready for future enhancement work  
**AI Assistant**: Claude (Anthropic) - Expert in iOS/SwiftUI development