#!/usr/bin/env sh
# shellcheck shell=sh
set -eu

# --- Configuration ---
script_path=$0
case $script_path in
  /*) script_dir=$(dirname -- "$script_path") ;;
  *) script_dir=$(cd -- "$(dirname -- "$script_path")" && pwd) ;;
esac
root_dir=$(cd -- "${script_dir}/.." && pwd)

tmp_dir="${root_dir}/.tmp"
pid_file="${tmp_dir}/appium.pid"
log_file="${tmp_dir}/appium.log"

# The command pattern to search for to find the running Appium process.
# This needs to be specific enough to avoid matching other node processes.
appium_cmd_pattern="npm exec appium -- --config ./automation/appium.config.cjs"

# --- Functions ---

# Kills any running Appium server processes started by this script or similar.
# It uses pkill to match against the command line.
kill_existing_processes() {
  echo "Stopping any existing Appium server processes..."
  # The [n] is a trick to prevent pkill from matching its own process.
  pkill -f "[n]pm exec appium" >/dev/null 2>&1 || true
  pkill -f "[m]ise run appium" >/dev/null 2>&1 || true
  # Wait a moment for graceful shutdown.
  sleep 0.5
  # Force kill any that remain.
  pkill -9 -f "[n]pm exec appium" >/dev/null 2>&1 || true
  pkill -9 -f "[m]ise run appium" >/dev/null 2>&1 || true
  echo "Cleanup complete."
}

# --- Main Script ---

# Ensure the temporary directory exists.
mkdir -p "$tmp_dir"

# 1. Clean up any previous runs.
kill_existing_processes
rm -f "$pid_file"
# Truncate the log file for the new run.
: > "$log_file"

# 2. Start the Appium server in the background.
echo "Starting Appium server in the background..."
cd "$root_dir"
export ANDROID_HOME="$HOME/Library/Android/sdk"
nohup npm exec --prefix automation appium -- --config ./automation/appium.config.cjs >"$log_file" 2>&1 &

# 3. Find and verify the correct PID.
echo "Waiting for Appium to launch..."
sleep 4 # Give it a few seconds for the final node process to spawn.

echo "Searching for Appium process PID..."
actual_pid=""
# Use pgrep to find the newest (-n) process that matches the full command (-f).
actual_pid=$(pgrep -n -f "$appium_cmd_pattern")

if [ -z "$actual_pid" ]; then
  echo "ERROR: Failed to find a running Appium process after startup." >&2
  echo "--- Last 20 lines of Appium log ---" >&2
  tail -n 20 "$log_file" >&2
  exit 1
fi

# Final check to ensure the found PID is a running process.
if ! kill -0 "$actual_pid" >/dev/null 2>&1; then
  echo "ERROR: Found PID $actual_pid, but the process is not running." >&2
  echo "--- Last 20 lines of Appium log ---" >&2
  tail -n 20 "$log_file" >&2
  exit 1
fi

# 4. Success: Save PID and report back to the user.
echo "$actual_pid" > "$pid_file"
echo "Appium server started successfully."
echo "PID:         $actual_pid"
echo "PID file:    $pid_file"
echo "Log file:    $log_file"
echo ""
echo "--- Tailing last few lines of log (use 'tail -f $log_file' to monitor) ---"
tail -n 10 "$log_file"