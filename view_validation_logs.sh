#!/usr/bin/env sh
# Quick log viewer for Flutter meal planner tests

LOG_DIR=".tmp"

if [ ! -d "$LOG_DIR" ]; then
    echo "❌ No .tmp directory found. Run tests first!"
    exit 1
fi

echo "=== Flutter Meal Planner Test Logs ==="
echo ""

# List all log files with datetime and sizes
echo "Available log files:"
ls -lah "$LOG_DIR"/ios_*.log 2>/dev/null | awk '{printf "📄 %s (%s bytes)\n", $9, $5}'

if [ $? -ne 0 ]; then
    echo "❌ No test logs found. Run ./run_ios_test_safely.sh or ./run_dnd_test.sh first!"
    exit 1
fi

echo ""
echo "=== Quick Actions ==="
echo "1️⃣ View latest Test 1 (Setup) log:"
echo "   tail -50 \$(ls -t $LOG_DIR/ios_*_01.log | head -1)"
echo ""
echo "2️⃣ View latest Test 2 (DnD) log:"
echo "   tail -50 \$(ls -t $LOG_DIR/ios_*_02.log | head -1)"
echo ""
echo "3️⃣ Follow latest test in real-time:"
echo "   tail -f \$(ls -t $LOG_DIR/ios_*.log | head -1)"
echo ""
echo "4️⃣ Show all test results:"
echo "   grep -h 'TEST.*PASSED\|TEST.*FAILED' $LOG_DIR/ios_*.log"
echo ""

# Show recent test results
echo "=== Recent Test Results ==="
grep -h 'TEST.*PASSED\|TEST.*FAILED\|meal cards found\|drag.*completed' $LOG_DIR/ios_*.log | tail -10