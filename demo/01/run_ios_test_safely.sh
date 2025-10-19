#!/usr/bin/env sh
# Safe iOS Test Runner - POSIX compliant version
# This script safely runs Flutter tests without hanging

# Remove unused variable warning
# DEVICE_NAME="iPhone 16"  # Commented out as unused

set -e

# Configuration
TEST_FILE="integration_test/validation_01_setup_test.dart"
LOG_DIR=".tmp"

# Generate datetime-based log filename: ios_YYYYMMDD_HHMM_XX.log
# where XX is the test number (01 for setup test)
DATE_TIME=$(date '+%Y%m%d_%H%M')
LOG_FILE="$LOG_DIR/ios_${DATE_TIME}_01.log"

SIMULATOR_WAIT=60
TEST_TIMEOUT=120

# Create log directory
mkdir -p "$LOG_DIR"

# Function to check if simulator is running
is_simulator_running() {
    xcrun simctl list devices booted | grep -q "iPhone" && echo "yes" || echo "no"
}

# Function to get current time
current_time() {
    date '+%H:%M:%S'
}

# Step 1: Check simulator status
echo "[$(current_time)] Checking iOS Simulator status..."
if [ "$(is_simulator_running)" = "no" ]; then
    echo "[$(current_time)] Simulator is NOT running. Starting it..."
    
    # Start simulator in background
    timeout 30 flutter emulators --launch apple_ios_simulator > "$LOG_DIR/simulator_launch.log" 2>&1 || true
    
    echo "[$(current_time)] Waiting ${SIMULATOR_WAIT}s for simulator to boot..."
    sleep "$SIMULATOR_WAIT"
else
    echo "[$(current_time)] Simulator is already running"
fi

# Step 2: Verify simulator is actually ready
echo "[$(current_time)] Verifying devices are available..."
timeout 10 flutter devices > "$LOG_DIR/devices.log" 2>&1

if ! grep -q "iPhone" "$LOG_DIR/devices.log"; then
    echo "[$(current_time)] ERROR: No iPhone simulator found after startup"
    echo "Available devices:"
    cat "$LOG_DIR/devices.log"
    exit 1
fi

# Step 3: Get exact device ID
# Extract the UUID from the iPhone line (second field after the bullet)
DEVICE_ID=$(flutter devices | grep "iPhone" | head -1 | awk -F'•' '{print $2}' | xargs)
echo "[$(current_time)] Found device: $DEVICE_ID"

# Step 4: Run the test with timeout
echo "[$(current_time)] Starting test with ${TEST_TIMEOUT}s timeout..."
echo "[$(current_time)] Test output is being written to: $LOG_FILE"
echo "[$(current_time)] To follow along: tail -f $LOG_FILE"
echo ""

# Run test in background with timeout
(
    timeout "$TEST_TIMEOUT" flutter test "$TEST_FILE" -d "$DEVICE_ID" > "$LOG_FILE" 2>&1
    echo "EXIT_CODE=$?" >> "$LOG_FILE"
) &

TEST_PID=$!

# Optional: Start tailing the log in background (user can run tail -f manually)
echo "[$(current_time)] Tip: In another terminal, run: tail -f $LOG_FILE"

# Step 5: Monitor the test (show progress dots)
printf "Running test"
COUNT=0
while kill -0 $TEST_PID 2>/dev/null; do
    printf "."
    sleep 2
    COUNT=$((COUNT + 2))
    
    # Show a status update every 10 seconds
    if [ $((COUNT % 10)) -eq 0 ]; then
        printf " [%ds]" "$COUNT"
    fi
    
    # Safety check - if we've been waiting too long
    if [ "$COUNT" -gt "$TEST_TIMEOUT" ]; then
        echo ""
        echo "[$(current_time)] WARNING: Test exceeded timeout, killing..."
        kill -9 $TEST_PID 2>/dev/null || true
        break
    fi
done
echo ""

# Step 6: Check results
echo ""
echo "[$(current_time)] Test completed. Checking results..."
echo ""

# Extract last 50 lines of log for summary
echo "=== TEST OUTPUT (last 50 lines) ==="
tail -50 "$LOG_FILE" 2>/dev/null || echo "No output captured"
echo ""

# Check if test passed
if grep -q "All tests passed!" "$LOG_FILE" 2>/dev/null; then
    echo "✅ TEST PASSED!"
    exit 0
elif grep -q "+0 -[1-9]" "$LOG_FILE" 2>/dev/null; then
    echo "❌ TEST FAILED - Some tests did not pass"
    echo "Full log: $LOG_FILE"
    exit 1
elif grep -q "error:" "$LOG_FILE" 2>/dev/null; then
    echo "❌ BUILD/RUNTIME ERROR"
    echo "Full log: $LOG_FILE"
    exit 1
else
    echo "⚠️ TEST STATUS UNKNOWN"
    echo "Check full log: $LOG_FILE"
    exit 2
fi