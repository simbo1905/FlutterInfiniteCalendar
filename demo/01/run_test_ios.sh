#!/usr/bin/env sh
# iOS Test Runner with Platform-Specific Screenshot Handling
# This script runs Flutter tests on iOS with noop screenshots

set -e

# Parse arguments
TEST_NUM="${1:-01}"

# Validate test number
case "$TEST_NUM" in
    01|02)
        ;;
    *)
        echo "❌ Error: Test number must be '01' or '02'. Got: $TEST_NUM"
        exit 1
        ;;
esac

cd "$(dirname "$0")"

# Configuration
TEST_FILE="integration_test/validation_${TEST_NUM}_setup_test.dart"
if [ "$TEST_NUM" = "02" ]; then
    TEST_FILE="integration_test/validation_02_dnd_test.dart"
fi

LOG_DIR=".tmp"
DATE_TIME=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$LOG_DIR/ios_${TEST_NUM}_${DATE_TIME}.log"

# Create log directory
mkdir -p "$LOG_DIR"

echo "🚀 Running Test $TEST_NUM on iOS platform"
echo "📁 Log file: $LOG_FILE"

# Set platform environment variable for screenshot handling
export TEST_PLATFORM="ios"

# Check if simulator is running
if ! flutter devices | grep -q "iPhone"; then
    echo "📱 Starting iOS simulator..."
    flutter emulators --launch apple_ios_simulator > /dev/null 2>&1
    sleep 30
fi

# Get device ID using the proven method from working scripts
DEVICE_ID=$(flutter devices | grep "iPhone" | head -1 | awk -F'•' '{print $2}' | xargs)
echo "📱 Using device: $DEVICE_ID"

# Run the test with timeout and log to file
echo "🎯 Running Test $TEST_NUM..."
echo "📝 Starting test at $(date)" > "$LOG_FILE"
echo "📱 Platform: iOS" >> "$LOG_FILE"
echo "🎯 Test file: $TEST_FILE" >> "$LOG_FILE"
echo "📱 Device: $DEVICE_ID" >> "$LOG_FILE"
echo "=" | head -c 80 >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Run test and append to log
timeout 180 flutter drive \
    --driver=test_driver/integration_driver.dart \
    --target="$TEST_FILE" \
    -d "$DEVICE_ID" >> "$LOG_FILE" 2>&1

# Add completion timestamp
echo "" >> "$LOG_FILE"
echo "=" | head -c 80 >> "$LOG_FILE"
echo "✅ Test completed at $(date)" >> "$LOG_FILE"

RESULT=$?
echo ""
echo "=== Test $TEST_NUM Result ==="
if [ $RESULT -eq 0 ]; then
    echo "✅ TEST $TEST_NUM PASSED!"
    echo "📋 Full log: $LOG_FILE"
else
    echo "❌ TEST $TEST_NUM FAILED (exit code: $RESULT)"
    echo "🔍 Check log: $LOG_FILE"
fi

exit $RESULT