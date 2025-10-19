#!/usr/bin/env sh
# Simple script to run the DnD test safely

echo "=== Running Drag-and-Drop Test 2 ==="

# Check if simulator is running
if ! flutter devices | grep -q "iPhone"; then
    echo "Starting iOS simulator..."
    flutter emulators --launch apple_ios_simulator > /dev/null 2>&1
    sleep 30
fi

# Get device ID
DEVICE_ID=$(flutter devices | grep "iPhone" | head -1 | awk -F'•' '{print $2}' | xargs)
echo "Using device: $DEVICE_ID"

# Run the DnD test with timeout
echo "Running Test 2: Trivial DnD Sanity Test..."
timeout 180 flutter test integration_test/validation_02_dnd_test.dart -d "$DEVICE_ID"

RESULT=$?
echo ""
echo "=== Test 2 Result ==="
if [ $RESULT -eq 0 ]; then
    echo "✅ TEST 2 PASSED - Drag-and-drop functionality verified!"
else
    echo "❌ TEST 2 FAILED (exit code: $RESULT)"
fi

exit $RESULT