# Testing Quick Reference

## Two-Role Testing Model

This project uses separate **Tester** and **Developer** roles to ensure clear ownership and prevent conflicts.

| Role | File Pattern | Location | Run Command | Can Modify |
|------|--------------|----------|-------------|------------|
| **Tester** | `validation_XX_YY.dart` | `demo/XX/integration_test/` | `./run_validation_test.sh XX YY` | Only validation tests |
| **Developer** | `developer_*.dart` | `demo/XX/test/` | `cd demo/XX && flutter test` | Only developer tests & implementation |

---

## Tester Role: Validation Tests

### File Naming
**Pattern**: `validation_[DEMO]_[TEST].dart`
- `DEMO` = Demo number (01, 02, etc.)
- `TEST` = VALIDATION_YY.md number (01-31)
- Example: `validation_01_01.dart` = Demo 01, test for VALIDATION_01.md

### Location
`demo/XX/integration_test/validation_XX_YY.dart`

### Purpose
Verify specification compliance from VALIDATION_*.md files

### Run Commands
```bash
# From repository root

# Run validation test 01 for demo 01
./run_validation_test.sh 01 01

# Run validation test 02 for demo 01
./run_validation_test.sh 01 02

# View logs for test 01, demo 01
./view_validation_logs.sh 01 01

# Use defaults (demo 01, test 01)
./run_validation_test.sh
```

### Logs
`demo/XX/.tmp/ios_YYYYMMDD_HHMM_YY.log`

### Tester Responsibilities
- ✅ **Create/modify validation tests** for VALIDATION_*.md requirements
- ✅ **Report bugs** when validation tests fail
- ❌ **NEVER modify developer tests**
- ❌ **NEVER modify implementation code**

---

## Developer Role: Unit Tests

### File Naming
**Pattern**: `developer_*.dart`
- Use descriptive names for what's being tested
- Examples: `developer_meal_controller_test.dart`, `developer_drag_logic_test.dart`

### Location
`demo/XX/test/developer_*.dart`

### Purpose
Test implementation details, edge cases, and internal logic

### Run Commands
```bash
# From demo directory
cd demo/01

# Run all developer tests
flutter test

# Run specific test file
flutter test test/developer_meal_controller_test.dart

# Verbose output
flutter test --verbose
```

### Developer Responsibilities
- ✅ **Write unit tests** for helpers, controllers, utilities
- ✅ **Test edge cases** and implementation-specific behavior
- ✅ **Modify implementation code** to fix bugs
- ✅ **Fix code when validation tests fail**
- ❌ **NEVER modify validation tests**
- ❌ **NEVER delete validation tests**

---

## Quick Start

### First Time Setup
```bash
# Verify Flutter and iOS setup
flutter doctor -v

# Should show Xcode and iOS toolchain installed

# List available simulators
xcrun simctl list devices available
```

### Running Your First Test
```bash
# From repository root
./run_validation_test.sh 01 01
```

**Expected Output**:
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
Running test.......... [20s]... done

✅ TEST PASSED!
```

---

## Troubleshooting

### Simulator Not Found
```bash
# Check if simulator is running
xcrun simctl list devices booted

# If none, the script will auto-launch one
# Wait 60 seconds for boot to complete
```

### Test File Not Found
```bash
# Check what validation tests exist
ls demo/01/integration_test/validation_*.dart

# Use correct test number
./run_validation_test.sh 01 02  # for validation_02_*.dart
```

### Test Timeout
- Default timeout: 120 seconds
- Check logs: `demo/01/.tmp/ios_*.log`
- Look for freezing or compilation errors

### View Logs in Real-Time
```bash
# In another terminal while test runs
tail -f demo/01/.tmp/ios_$(date +%Y%m%d)_*.log
```

---

## Reference Documentation

- **AGENTS.md**: Complete testing architecture and agent guidelines
- **VALIDATION.md**: All validation test requirements (VALIDATION_01 through VALIDATION_31)
- **SPEC.md**: Application specification and behavior contracts

---

## Quick Command Cheat Sheet

```bash
# Validation Tests (from repo root)
./run_validation_test.sh 01 01          # Run specific test
./run_validation_test.sh                # Run default (01, 01)

# Unit Tests (from demo directory)
cd demo/01
flutter test                            # All unit tests
flutter test test/filename_test.dart    # Specific test

# Manual App Run (from demo directory)
cd demo/01
flutter run                             # Launch on simulator

# Check Environment
flutter doctor -v                       # Flutter setup
xcrun simctl list devices available     # iOS simulators

# View Logs
tail -f demo/01/.tmp/ios_*.log         # Follow test logs
ls demo/01/.tmp/                        # List all logs
```
