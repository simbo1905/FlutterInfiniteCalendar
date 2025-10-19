#!/bin/bash
set -e

# Usage: ./run_test.sh [platform] [test_number]
# Example: ./run_test.sh ios 01
# Example: ./run_test.sh web 02

PLATFORM="${1:-ios}"
TEST_NUM="${2:-01}"

cd "$(dirname "$0")"

# Validate platform
if [[ "$PLATFORM" != "ios" && "$PLATFORM" != "web" ]]; then
    echo "❌ Error: Platform must be 'ios' or 'web'. Got: $PLATFORM"
    exit 1
fi

# Validate test number
if [[ ! "$TEST_NUM" =~ ^(01|02)$ ]]; then
    echo "❌ Error: Test number must be '01' or '02'. Got: $TEST_NUM"
    exit 1
fi

echo "🚀 Running Test $TEST_NUM on $PLATFORM platform"

# Create .tmp directory
mkdir -p .tmp

# Generate timestamp
TS=$(date +"%Y%m%d_%H%M%S")
LOG_FILE=".tmp/${PLATFORM}_${TEST_NUM}_${TS}.log"

echo "📁 Log file: $LOG_FILE"

# Set platform environment variable
export TEST_PLATFORM="$PLATFORM"

# Determine test target
case "$TEST_NUM" in
    01)
        TEST_TARGET="integration_test/validation_01_setup_test.dart"
        ;;
    02)
        TEST_TARGET="integration_test/validation_02_dnd_test.dart"
        ;;
    *)
        echo "❌ Error: Invalid test number: $TEST_NUM"
        exit 1
        ;;
esac

echo "🎯 Test target: $TEST_TARGET"

# Run the test with appropriate device
if [[ "$PLATFORM" == "ios" ]]; then
    echo "📱 Running on iOS simulator..."
    # Find iOS device ID (UUID)
    DEVICE_ID=$(flutter devices | grep "ios.*simulator" | head -1 | awk -F' • ' '{print $2}')
    if [[ -z "$DEVICE_ID" ]]; then
        echo "❌ Error: No iOS simulator found"
        exit 1
    fi
    echo "📱 Using device: $DEVICE_ID"
    flutter drive \
        --driver=test_driver/integration_driver.dart \
        --target="$TEST_TARGET" \
        -d "$DEVICE_ID" | tee "$LOG_FILE"
else
    echo "🌐 Running on web platform..."
    flutter drive \
        --driver=test_driver/integration_driver.dart \
        --target="$TEST_TARGET" \
        -d web-server \
        --browser-name=chrome | tee "$LOG_FILE"
fi

echo "✅ Test $TEST_NUM on $PLATFORM completed successfully!"
echo "📋 Log file: $LOG_FILE"

# For web platform, also show any generated screenshots
if [[ "$PLATFORM" == "web" ]]; then
    echo "📸 Checking for screenshots..."
    find .tmp -name "*${TS}*screenshots*" -type d 2>/dev/null | head -5
fi