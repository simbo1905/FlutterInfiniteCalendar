You're absolutely right! Let me revise the AGENTS.md to reflect that tests are **demo-specific** and self-contained in their own folders, while keeping the general framework generic.

# Agent Context: Infinite Scrolling Meal Planner Testing

## Project Structure

This is a **monorepo** containing multiple Flutter demo attempts under `./demo/01/`, `./demo/02/`, etc. Each demo explores different calendar library implementations to find the best solution for the Infinite Scrolling Meal Planner specification.

The automation testing infrastructure lives at the **repository root** in:
- `./mise.toml` - Dependency management and task orchestration

**Key principle:** The automation **framework** is reusable infrastructure. The **tests themselves are demo-specific** because each demo may use different Flutter calendar components with different widget structures, keys, and behaviors.


## Target Platform

We are **testing exclusively on Android** via Android Studio emulator. This is the baseline platform verification strategy:

- ✅ **Necessary but not sufficient**: If it works on Android, the pure Flutter logic should port to iOS and Web with minimal adaptation
- ✅ **Feature validation focus**: Proves drag-and-drop, state management, and card manipulation logic works

## Verification: New Checkout Setup

After cloning this repository, verify the toolchain is correctly installed:

### 1. Install Dependencies

```bash
# From repository root
cd /path/to/FlutterInfiniteCalendar

# Install mise-managed tooling (Node.js)
mise install

mise run bootstrap

# Should show: "Available drivers: flutter-integration@2.0.3"
# Press Ctrl+C to stop
```

### 2. Verify Flutter Integration Driver

```bash
# Check driver installation

# Should show:
# ✔ flutter-integration@2.0.3 [installed (npm)]
```

### 3. Verify Android Environment

```bash
# Check Flutter recognizes Android setup
flutter doctor -v

# Should show:
# [✓] Android toolchain - develop for Android devices
# [✓] Android Studio

# List available emulators
emulator -list-avds

# Should show at least one AVD (e.g., "Medium_Phone_API_36.1" or "Pixel_6_API_33")
```

### 4. Build and Run Demo on Emulator

```bash
# Start emulator (in background)
emulator -avd <your-avd-name> &

# Wait ~30 seconds for boot

# Navigate to a demo
cd demo/01

# Run the Flutter app
flutter run

# App should launch on emulator successfully
# Press 'q' to quit
```

If all four steps succeed, the environment is ready for automation testing.

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


```
automation/
├── package.json           # Shared dependencies
├── screenshots/           # Test evidence output
└── tests/
    ├── 01/                # Tests for demo/01/
    │   ├── 01-hello-world.test.js
    │   └── 02-drag-drop.test.js
    ├── 02/                # Tests for demo/02/
    │   ├── 01-hello-world.test.js
    │   └── 02-drag-drop.test.js
    └── ...
```

**Why demo-specific folders?**
- Different demos may use different Flutter calendar packages
- Widget keys, selectors, and hierarchies will vary between implementations
- Each demo's tests are **self-contained** and don't depend on other demos' test code
- Winning demo's test folder becomes the portable asset

### Test Execution Workflow

   ```bash
   cd /path/to/FlutterInfiniteCalendar
   # Leave running
   ```

2. **Terminal 2**: Build PROFILE APK for target demo
   ```bash
   cd /path/to/FlutterInfiniteCalendar
   DEMO=01 mise run build-demo
   # Produces: demo/01/build/app/outputs/flutter-apk/app-profile.apk
   ```

3. **Terminal 3**: Uninstall old debug version (if exists)
   ```bash
   adb uninstall com.example.meal_planner_demo
   ```

4. **Terminal 3**: Run tests for specific demo
   ```bash
   cd /path/to/FlutterInfiniteCalendar
   DEMO=01 mise run test
   ```

**Important:** Always use profile builds (app-profile.apk), never debug builds (app-debug.apk). Debug mode causes UI freezing and makes testing impossible.

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

When automation is working correctly for a demo:
2. `DEMO=01 mise run build-demo` produces APK at `demo/01/build/app/outputs/flutter-apk/app-profile.apk`
4. Tests pass with green checkmarks and evidence saved to `automation/screenshots/`
5. Console shows structured logs matching `SPEC.md` format: `[TIMESTAMP] [LEVEL] [ACTION] - {DETAILS}`

## Porting Tests to Other Repositories

When a demo proves successful and needs to be integrated into another repository:

3. **Adapt selectors**: Update widget keys/selectors to match target repo's implementation
4. **Update app paths**: Modify APK/app paths to point at target repo's build output
5. **Run validation**: Execute full test suite to ensure portability

The test **patterns** (wait strategies, drag gestures, assertion approaches) remain reusable; only the **selectors** and **paths** need adaptation.