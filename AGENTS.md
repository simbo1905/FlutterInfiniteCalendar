You're absolutely right! Let me revise the AGENTS.md to reflect that tests are **demo-specific** and self-contained in their own folders, while keeping the general framework generic.

# Agent Context: Infinite Scrolling Meal Planner Testing

## Project Structure

This is a **monorepo** containing multiple Flutter demo attempts under `./demo/01/`, `./demo/02/`, etc. Each demo explores different calendar library implementations to find the best solution for the Infinite Scrolling Meal Planner specification.

The automation testing infrastructure lives at the **repository root** in:
- `./mise.toml` - Dependency management and task orchestration

**Key principle:** The automation **framework** is reusable infrastructure. The **tests themselves are demo-specific** because each demo may use different Flutter calendar components with different widget structures, keys, and behaviors.


## Target Platform

We are **testing exclusively on iOS Simulator** for validation tests. This is the baseline platform verification strategy:

- ✅ **Necessary but not sufficient**: If it works on iOS, the pure Flutter logic should port to Android and Web with minimal adaptation
- ✅ **Feature validation focus**: Proves drag-and-drop, state management, and card manipulation logic works
- ✅ **Integration test compatibility**: iOS Simulator works well with Flutter's integration_test package

## Verification: New Checkout Setup

After cloning this repository, verify the toolchain is correctly installed:

### 1. Verify Flutter Environment

```bash
# Check Flutter recognizes iOS setup
flutter doctor -v

# Should show:
# [✓] Flutter (Channel stable, ...)
# [✓] Xcode - develop for iOS and macOS

# List available simulators
xcrun simctl list devices available

# Should show at least one iPhone simulator
```

### 2. Build and Run Demo on Simulator

```bash
# From repository root
cd /path/to/FlutterInfiniteCalendar

# Navigate to a demo
cd demo/01

# Run the Flutter app (simulator will auto-launch if not running)
flutter run

# App should launch on simulator successfully
# Press 'q' to quit
```

If both steps succeed, the environment is ready for validation testing.

## Critical: Build Mode Requirements

### ❌ NEVER Use These (Known Issues)

- ❌ **NEVER use flutter_driver** package - deprecated and obsolete (replaced by integration_test)
- ❌ **NEVER use enableFlutterDriverExtension()** - part of deprecated flutter_driver API

### ✅ ALWAYS Use These (Modern Setup)


### Flutter Build Modes Comparison

|------|------------|-----------|-------------------|-------|
| **Debug** | Slow, janky by design | Full DevTools, hot reload | ❌ **Causes freezing** | UI rendering blocked by debugging protocol |
| **Profile** | Near-release speed | Minimal VM service | ✅ **Works perfectly** | Removes debug overhead, keeps integration server |
| **Release** | Maximum speed | All debugging stripped | ❌ **Cannot connect** | Integration test server removed |

### Platform-Specific Limitations

**iOS:**
- ⚠️ **Profile mode does NOT work on iOS Simulator** - requires physical device
- Debug and release modes work on simulator, but debug causes same freezing issues
- Command: `flutter build ios --profile` (then deploy to connected device)

**Web:**
- Web testing requires different tools (e.g., Selenium WebDriver, Playwright)
- `flutter run -d chrome` causes freezing due to debugging overhead
- For manual web testing: use `flutter run -d web-server --web-port 8080` then open in any browser
- For automated web testing: build with `flutter build web --release` and use standard web automation tools

**Android:**
- ✅ **Works on both emulators and physical devices** with profile builds
- Emulators are recommended for CI/CD automation
- Physical devices recommended for performance validation

### Environment Configuration

**ANDROID_HOME:**
- Required for Android SDK access
- Default macOS location: `$HOME/Library/Android/sdk`
- Default Linux location: `$HOME/Android/Sdk`
- Windows: `%LOCALAPPDATA%\Android\Sdk`
- If using custom SDK location, set environment variable before running tests:
  ```bash
  export ANDROID_HOME="/path/to/your/android/sdk"
  DEMO=01 mise run test
  ```

**Flutter SDK:**
- Must be in PATH and accessible
- Verify with: `flutter doctor -v`
- Ensure Android toolchain is properly configured

### Why Debug Mode Freezes

**The Problem:**
- Flutter's Dart VM runs on a single-threaded isolate
- In debug mode: UI rendering + VM Service Protocol share the same thread
- Debugging operations (DevTools, breakpoints, VM messages) block the event loop
- When event loop is blocked, frames cannot paint
- Chrome DevTools connection adds massive overhead (DWDS, DDS, WebSocket connections)
- **Result:** App freezes, cards don't render, 60+ second delays

**The Solution:**
- Profile mode removes Chrome DevTools overhead
- Profile mode removes hot reload compilation overhead
- Profile mode removes debugging symbol overhead
- Profile mode runs at near-release performance
- UI rendering runs freely without blocking

### Modern Flutter Integration Testing Stack (2025)

**Correct Setup:**
- ✅ Build mode: `flutter build apk --profile`

```dart
import 'package:meal_planner_demo/app.dart';

Future<void> main() async {
  await initializeTest(
    app: const MealPlannerApp(),
  );
}
```

## Test Architecture

This project uses a **two-role testing model** to prevent conflicts and ensure clear ownership of test code.

### Two Testing Roles

| Role | Owns | Cannot Touch | File Pattern | Purpose |
|------|------|--------------|--------------|---------|
| **Tester** | Validation tests | Developer tests | `validation_XX_YY.dart` | Verify spec compliance |
| **Developer** | Unit tests | Validation tests | `developer_*.dart` | Test implementation details |

### Tester Role

**Who**: Agent focused on specification validation and behavioral testing  
**Owns**: `demo/XX/integration_test/validation_XX_YY.dart`

**Responsibilities**:
- ✅ **Create/modify validation tests** for VALIDATION_YY.md requirements
- ✅ **Ensure tests verify behavioral contracts** from specification
- ✅ **Report implementation bugs** when validation tests fail
- ❌ **NEVER modify developer unit tests**
- ❌ **NEVER modify implementation code** (only report issues)

**Naming Convention**: `validation_[DEMO]_[TEST].dart`
- `DEMO` = Demo number (01, 02, etc.)
- `TEST` = VALIDATION_YY.md test number (01-31)
- Example: `validation_01_01.dart` = Demo 01, VALIDATION_01.md test

**Run Tests**: `./run_validation_test.sh [DEMO] [TEST]`

---

### Developer Role

**Who**: Agent focused on implementation and debugging  
**Owns**: `demo/XX/test/developer_*.dart`

**Responsibilities**:
- ✅ **Write unit tests** for helpers, controllers, utilities
- ✅ **Test edge cases** and implementation-specific behavior
- ✅ **Modify implementation code** to fix bugs
- ✅ **Debug and fix** validation test failures by changing implementation
- ❌ **NEVER modify validation tests**
- ❌ **NEVER delete validation tests**

**Naming Convention**: `developer_*.dart`
- Use descriptive names for what's being tested
- Examples: `developer_meal_controller_test.dart`, `developer_drag_logic_test.dart`

**Run Tests**: `cd demo/XX && flutter test`

---

### Visual Overview

```
demo/01/
├── integration_test/          # TESTER ROLE ONLY
│   ├── validation_01_01.dart  # Test for VALIDATION_01.md
│   ├── validation_01_02.dart  # Test for VALIDATION_02.md
│   └── ...                    # (DEVELOPER: READ ONLY)
├── test/                      # DEVELOPER ROLE ONLY
│   ├── developer_meal_controller_test.dart
│   ├── developer_drag_logic_test.dart
│   └── ...                    # (TESTER: HANDS OFF)
├── lib/
│   └── ...                    # Implementation (DEVELOPER edits)
└── .tmp/                      # Test logs
    └── ios_*.log
```

---

### Why Two Roles?

**Problem**: When one agent modifies both validation tests and implementation code, they can:
- Make tests pass by weakening test requirements
- Create circular dependencies (test ↔ implementation)
- Lose objective validation of specification compliance

**Solution**: Separation of concerns
- **Tester** defines "what correct behavior looks like" via tests
- **Developer** makes implementation satisfy those tests
- Neither can cheat by modifying the other's domain

### Test Execution Workflow

#### Running Validation Tests

From repository root:

```bash
# Run validation test 01 for demo 01
./run_validation_test.sh 01 01

# Run validation test 02 for demo 01
./run_validation_test.sh 01 02

# Run validation test 01 for demo 02
./run_validation_test.sh 02 01

# Defaults to demo 01, test 01 if no arguments
./run_validation_test.sh
```

**What happens**:
1. Script checks if iOS Simulator is running, starts it if needed
2. Changes to `demo/XX` directory
3. Finds matching `integration_test/validation_YY_*_test.dart` file
4. Runs test on iOS Simulator with timeout protection
5. Logs output to `demo/XX/.tmp/ios_YYYYMMDD_HHMM_YY.log`
6. Shows test summary and exit status

**Log monitoring**:
```bash
# In another terminal, follow test progress
tail -f demo/01/.tmp/ios_YYYYMMDD_HHMM_01.log
```

#### Running Unit Tests

From demo directory:

```bash
# Navigate to demo
cd demo/01

# Run all unit tests
flutter test

# Run specific test file
flutter test test/meal_controller_test.dart

# Run with verbose output
flutter test --verbose
```

## Test Implementation Guide


### Test 1: Hello World - Card Count Verification


**Purpose:** Baseline smoke test that verifies the Flutter app launches successfully and the calendar screen renders with dynamically loaded meal cards.

**Behavior:**
2. **Wait for dynamic content to load** - The calendar screen fetches and renders mock meal data asynchronously after the app initializes
3. Count the total number of meal cards visible on screen
4. Assert that at least one card is present (per `SPEC.md` initial data requirements)
5. Capture a screenshot for visual verification
6. Log the card count to console

**Critical requirement:** This test must implement proper wait strategies because the card data is **not immediately available** on app launch. The test must poll or wait for widgets to appear before attempting to count them.

**Success criteria:**
- App launches without errors
- Test waits successfully for cards to render
- Accurate card count returned (should match `SPEC.md` mock data for current + next week)
- Screenshot saved to `automation/screenshots/<demo-number>-hello-world.png`

**Demo-specific adaptations needed:**
- Widget keys/selectors for finding meal cards (varies by calendar component used)
- Wait timeouts (may differ based on rendering performance)
- Locator strategies (accessibility IDs, resource IDs, or custom keys)

### Test 2: Drag and Drop - Card Movement Verification


**Purpose:** Validates the core drag-and-drop functionality by moving a meal card from a populated day to an empty day.

**Behavior:**
1. Connect to the Flutter app and wait for calendar to fully render
2. **Identify source card** - Locate a specific meal card on a day that has at least one card
3. **Identify target date** - Locate an empty day row (a day with zero cards)
4. **Capture "before" state** - Take screenshot showing initial card positions
5. **Execute drag operation** - Use W3C Actions API to:
   - Get the center coordinates of the source card
   - Get the center coordinates of the target day's drop zone
   - Perform pointer down → move → up gesture sequence with appropriate timing (300ms pause after down, 1000-1500ms move duration)
6. **Wait for state update** - Pause to allow Flutter to process the drag and update UI
7. **Capture "after" state** - Take screenshot showing final card positions
8. **Verify card moved** - Assert that:
   - Source day now has one fewer card
   - Target day now has exactly one card
   - Console logs show `MOVE_MEAL` action per `SPEC.md` logging requirements

**Critical requirements:**
- Must wait for rendering after each screen interaction
- Drag gesture timing is crucial (not tap/swipe)
- Coordinates must be calculated dynamically from element positions, never hard-coded
- Must handle async state updates with explicit waits

**Success criteria:**
- Card successfully moves from source to target day
- UI reflects the state change accurately
- Before/after screenshots saved to `automation/screenshots/<demo-number>-drag-drop-{before,after}.png`
- Console logs match `SPEC.md` format

**Demo-specific adaptations needed:**
- Selectors for meal cards (varies by calendar package)
- Selectors for day rows/drop zones (different calendar components have different structures)
- Drag gesture parameters (some implementations may need longer durations)
- State verification approach (how to count cards may differ)

## Adding New Tests to a Demo

2. **Create test file** following naming convention: `##-description.test.js`
3. **Import dependencies**: `webdriverio`, `chai` for assertions, `path` for file operations
4. **Use test template structure**:
   ```javascript
   const wdio = require('webdriverio');
   const assert = require('assert');
   const path = require('path');
   
   describe('Demo XX - Feature Name', function() {
       this.timeout(120000);
       let driver;
       
       before(async function() {
           // Initialize WebDriver session with demo-specific app path
           const appPath = process.env.APP_PATH || 
                          path.join(__dirname, `../../../demo/XX/build/app/outputs/flutter-apk/app-profile.apk`);
           
           // WebDriver setup...
       });
       
       after(async function() {
           if (driver) await driver.deleteSession();
       });
       
       it('should perform action', async function() {
           // Test implementation
       });
   });
   ```
5. **Keep tests self-contained**: Don't import utilities from other demo test folders
6. **Follow wait strategies**: Always use explicit waits, never static `pause()` for synchronization
7. **Capture evidence**: Screenshot on failure, save artifacts to `automation/screenshots/`

## Reference Documentation

- **Specification**: `SPEC.md` - Defines application behavior, data model, and logging requirements that **all demos must implement**
- **Validation Protocol**: `VALIDATION.md` - High-level test scenarios and acceptance criteria that **all demos must satisfy** (but implementation details vary)

## What Success Looks Like

When validation testing is working correctly for a demo:

1. Simulator launches automatically when running `./run_validation_test.sh 01 01`
2. Test runs on iOS Simulator without freezing or hanging
3. Test completes within timeout (default 120 seconds)
4. Logs saved to `demo/01/.tmp/ios_YYYYMMDD_HHMM_01.log` with detailed output
5. Console shows clear pass/fail status with emoji indicators (✅/❌)
6. Exit code 0 for pass, non-zero for fail

**Example successful run**:
```
==========================================
Validation Test Runner
Demo: 01
Test: 01
File: integration_test/validation_01_setup_test.dart
==========================================

[14:32:15] Checking iOS Simulator status...
[14:32:15] Simulator is already running
[14:32:15] Found device: iPhone 16
[14:32:15] Starting test with 120s timeout...
Running test.......... [20s].......... [40s]... done

[14:32:58] Test completed. Checking results...

=== TEST OUTPUT (last 50 lines) ===
🎉 [TEST_COMPLETE] Test 1 passed all requirements!
All tests passed!

✅ TEST PASSED!
```

## Porting Demos to Other Repositories

When a demo proves successful and needs to be integrated into another repository:

1. **Copy implementation code**: Copy `demo/XX/lib/` to target repository
2. **Copy validation tests**: Copy `demo/XX/integration_test/` to target repository
3. **Copy test runner script**: Copy `./run_validation_test.sh` to target repository root
4. **Adapt to target structure**: Update paths in script if demo isn't in `./demo/XX/` structure
5. **Run validation**: Execute `./run_validation_test.sh` to ensure tests still pass in new environment

The validation tests provide a portable contract that ensures the implementation behaves correctly in any repository.