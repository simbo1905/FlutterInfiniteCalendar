#!/usr/bin/env sh
# Simple script to run the DnD test safely with datetime-based logging

# Generate datetime-based log filename: ios_YYYYMMDD_HHMM_XX.log
# where XX is the test number (02 for DnD test)
LOG_DIR=".tmp"
DATE_TIME=$(date '+%Y%m%d_%H%M')
LOG_FILE="$LOG_DIR/ios_${DATE_TIME}_02.log"

# Create log directory
mkdir -p "$LOG_DIR"

echo "=== Running Drag-and-Drop Test 2 ==="
echo "Log file: $LOG_FILE"

# Check if simulator is running
if ! flutter devices | grep -q "iPhone"; then
    echo "Starting iOS simulator..."
    flutter emulators --launch apple_ios_simulator > /dev/null 2>&1
    sleep 30
fi

# Get device ID
DEVICE_ID=$(flutter devices | grep "iPhone" | head -1 | awk -F'•' '{print $2}' | xargs)
echo "Using device: $DEVICE_ID"

# Run the DnD test with timeout and log to file
echo "Running Test 2: Trivial DnD Sanity Test..."
timeout 180 flutter test integration_test/validation_02_dnd_test.dart -d "$DEVICE_ID" > "$LOG_FILE" 2>&1

RESULT=$?
echo ""
echo "=== Test 2 Result ==="
if [ $RESULT -eq 0 ]; then
    echo "✅ TEST 2 PASSED - Drag-and-drop functionality verified!"
    echo "Full log: $LOG_FILE"
else
    echo "❌ TEST 2 FAILED (exit code: $RESULT)"
    echo "Check log: $LOG_FILE"
fi

exit $RESULT