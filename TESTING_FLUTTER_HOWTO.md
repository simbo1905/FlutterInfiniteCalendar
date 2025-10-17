# Flutter Web Integration Testing HOWTO

This guide documents the reusable pattern we use to drive Flutter web integration tests from a Bash harness. It is deliberately app-agnostic so you can copy it into any Flutter repository—prototype or production—and wire it into that project's automation without leaking project-specific paths.

## Quick Start For This Repository

The only Flutter application we exercise in this workspace lives under `demo/01`. Always run commands from that directory so tooling picks up the correct `pubspec.yaml`.

1. `cd demo/01`
2. `flutter pub get`
3. Run unit/widget tests: `flutter test`
4. Run Chrome/web tests when needed: `flutter test --platform=chrome`

Avoid running `flutter test` from repository root or other demo folders—the automation and documentation assume `demo/01` is the sole project under test.

## Prerequisites

- Flutter (stable channel) installed via `mise` and pinned per-repo (`mise use flutter@<version>`). Confirm with `mise list` before running tests.
- Chrome installed at the default system location; the Flutter tool will spawn a debug-profile instance automatically.
- `chromedriver` installed (for macOS with Homebrew: `brew install chromedriver`). Keep the driver version aligned with the locally installed Chrome build.
- A dedicated `.tmp/` directory inside the Flutter project root for log and PID files; the script below will create it on demand.

## Directory Layout

```
<repo-root>/
  └── flutter_test_server.sh    # see script template below
  └── .tmp/                     # generated at runtime for logs + PID files
  └── integration_test/         # standard Flutter integration tests
  └── test_driver/              # entry-point used by flutter drive
```

Keep the harness script at the project root (next to `pubspec.yaml`) so relative paths to `integration_test/` and `test_driver/` remain stable.

## Script Template

Place the following content in `flutter_test_server.sh`, make it executable (`chmod +x flutter_test_server.sh`), and update the `FLUTTER_DRIVER_ENTRY` / `FLUTTER_TARGET` variables shown near the bottom to match your integration entry points. Everything else handles process orchestration, crash-proof cleanup, and logging.

```bash
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT_NAME="$(basename "$0")"
TMP_DIR="$ROOT_DIR/.tmp"
LOG_FILE="$TMP_DIR/$SCRIPT_NAME.log"
PID_FILE="$TMP_DIR/$SCRIPT_NAME.pid"
PROJECT_DIR="$SCRIPT_DIR"
CHROMEDRIVER_PORT=4444

# Update these paths to point at your integration driver + target.
FLUTTER_DRIVER_ENTRY="test_driver/integration_test_driver.dart"
FLUTTER_TARGET="integration_test/sample_web_test.dart"

mkdir -p "$TMP_DIR"
touch "$LOG_FILE"
: > "$LOG_FILE"

timestamp() { date +"%Y-%m-%dT%H:%M:%S%z"; }
log() { echo "$(timestamp) $*"; }

tests_passed() { grep -q "All tests passed!" "$LOG_FILE"; }

kill_with_retries() {
  local pid=$1 label=$2 attempts=0 max_attempts=5
  if ! kill -0 "$pid" 2>/dev/null; then
    log "$label (pid $pid) already exited."; return 0
  fi
  log "Stopping $label (pid $pid)."
  kill "$pid" 2>/dev/null || true
  while kill -0 "$pid" 2>/dev/null && (( attempts < max_attempts )); do
    attempts=$((attempts + 1))
    sleep 1
    log "$label still running after ${attempts}s; waiting..."
  done
  if kill -0 "$pid" 2>/dev/null; then
    log "$label unresponsive; sending SIGKILL."
    kill -9 "$pid" 2>/dev/null || true
  else
    log "$label stopped cleanly."
  fi
}

kill_children() {
  local parent=$1 label=$2 child_pids
  child_pids=$(pgrep -P "$parent" || true)
  [[ -z "$child_pids" ]] && return
  log "Terminating ${label} child processes: $child_pids"
  while read -r child; do
    [[ -z "$child" ]] && continue
    kill_with_retries "$child" "$label child"
  done <<< "$child_pids"
}

cleanup_remote_debugging_chrome() {
  local chrome_pids
  chrome_pids=$(pgrep -f "flutter_tools_chrome_device" || pgrep -f ".org.chromium.Chromium." || true)
  if [[ -z "$chrome_pids" ]]; then
    log "No lingering Chrome remote-debugging processes detected."
    return
  fi
  log "Terminating Chrome remote-debugging processes: $chrome_pids"
  while read -r pid; do
    [[ -z "$pid" ]] && continue
    kill_with_retries "$pid" "chrome (remote-debugging)"
  done <<< "$chrome_pids"
}

wait_for_chromedriver() {
  local attempt=0 max_attempts=20
  while (( attempt < max_attempts )); do
    if curl --silent --show-error --max-time 2 "http://127.0.0.1:${CHROMEDRIVER_PORT}/status" | grep -qi '"ready"[[:space:]]*:[[:space:]]*true'; then
      log "Chromedriver reported ready after $((attempt * 2))s."
      return 0
    fi
    attempt=$((attempt + 1))
    log "Waiting for chromedriver readiness (attempt ${attempt}/${max_attempts})."
    sleep 2
  done
  log "ERROR: Chromedriver failed to signal readiness within $((max_attempts * 2))s."
  return 1
}

cleanup() {
  local exit_code=$1
  [[ -n "${CHROMEDRIVER_PID:-}" ]] && kill_with_retries "$CHROMEDRIVER_PID" "chromedriver"
  [[ -n "${FLUTTER_PID:-}" ]] && kill_with_retries "$FLUTTER_PID" "flutter drive"
  cleanup_remote_debugging_chrome
  rm -f "$PID_FILE"
  log "--- Test Run Finished (exit ${exit_code}) ---"
}

run_tests() {
  trap 'cleanup $?' EXIT
  log "--- Starting Test Run (runner pid $$) ---"

  if ! command -v chromedriver >/dev/null 2>&1; then
    log "ERROR: chromedriver not found in PATH."; return 1
  fi

  if pgrep chromedriver >/dev/null 2>&1; then
    log "Previous chromedriver processes detected; terminating."
    pkill chromedriver || true
    sleep 1
  else
    log "No pre-existing chromedriver processes detected."
  fi

  if lsof -ti tcp:"$CHROMEDRIVER_PORT" >/dev/null 2>&1; then
    log "Port $CHROMEDRIVER_PORT currently in use; attempting to free it."
    lsof -ti tcp:"$CHROMEDRIVER_PORT" | while read -r pid; do
      [[ -z "$pid" ]] && continue
      kill_with_retries "$pid" "process on port $CHROMEDRIVER_PORT"
    done
  fi

  chromedriver --port="$CHROMEDRIVER_PORT" >> "$LOG_FILE" 2>&1 &
  CHROMEDRIVER_PID=$!
  log "Chromedriver started with pid $CHROMEDRIVER_PID on port $CHROMEDRIVER_PORT."

  wait_for_chromedriver || return 1
  log "Chromedriver readiness confirmed."

  local start_ts
  start_ts=$(date +%s)
  log "Launching flutter drive at $(timestamp)."

  pushd "$PROJECT_DIR" >/dev/null 2>&1
  flutter drive \
    --driver="$FLUTTER_DRIVER_ENTRY" \
    --target="$FLUTTER_TARGET" \
    -d chrome &
  local flutter_pid=$!
  FLUTTER_PID=$flutter_pid
  log "flutter drive running with pid $flutter_pid."

  local forced_exit_code=""
  while kill -0 "$flutter_pid" 2>/dev/null; do
    sleep 5
    local elapsed=$(( $(date +%s) - start_ts ))
    log "flutter drive still running (elapsed ${elapsed}s)."
    if tests_passed; then
      log "Detected \"All tests passed!\"; terminating flutter drive and Chrome."
      [[ -n "${CHROMEDRIVER_PID:-}" ]] && kill_children "$CHROMEDRIVER_PID" "chromedriver"
      kill_children "$flutter_pid" "flutter drive"
      kill_with_retries "$flutter_pid" "flutter drive after pass"
      [[ -n "${CHROMEDRIVER_PID:-}" ]] && kill_with_retries "$CHROMEDRIVER_PID" "chromedriver after pass"
      forced_exit_code=0
      break
    fi
  done

  local flutter_exit_code
  if [[ -n "$forced_exit_code" ]]; then
    wait "$flutter_pid" 2>/dev/null || true
    flutter_exit_code=$forced_exit_code
  else
    wait "$flutter_pid"
    flutter_exit_code=$?
  fi
  popd >/dev/null 2>&1

  local end_ts=$(date +%s)
  log "flutter drive completed with exit code ${flutter_exit_code} after $(( end_ts - start_ts ))s."
  return $flutter_exit_code
}

printf "\n%s === Invocation started (script pid %s) ===\n" "$(timestamp)" "$$" >> "$LOG_FILE"

run_tests >> "$LOG_FILE" 2>&1 &
TEST_RUNNER_PID=$!
echo "$TEST_RUNNER_PID" > "$PID_FILE"

echo "Test runner started in background."
echo "PID: $TEST_RUNNER_PID"
echo "Log: $LOG_FILE"
```

## Invocation Pattern

Always wrap the script in `timeout` to prevent runaway sessions:

```bash
timeout 180 ./flutter_test_server.sh
```

Key runtime artifacts:

- PID file: `.tmp/flutter_test_server.sh.pid`
- Log file: `.tmp/flutter_test_server.sh.log`
- Chrome debug profile: temporary directory under `/var/folders/.../flutter_tools_*`

Tail the log in another terminal to watch progress:

```bash
tail -f .tmp/flutter_test_server.sh.log
```

The harness prints `All tests passed!` once the integration suite finishes. The script auto-terminates `flutter drive`, `chromedriver`, and any Chrome children. If the suite fails, the exit code surfaces immediately while the log captures the full trace.

## Adapting for Other Repositories

- Set `FLUTTER_DRIVER_ENTRY` and `FLUTTER_TARGET` to the files you want to exercise.
- If you need to run a subset of tests, replace the target path or pass `--dart-define` flags before the trailing `&`.
- Preserve the `.tmp/` layout so any tooling (CI monitors, Playwright, etc.) can tail the same log.
- Wire the script into your chosen task runner (plain shell alias, Makefile, npm script, etc.).

## Troubleshooting Checklist

- **SocketException: Connection refused** — Usually a race while Chrome spins up. Re-run after ensuring no stray `chromedriver` or Chrome instances remain (`pgrep -fl chromedriver` / `pgrep -fl flutter_tools_chrome_device`). The script already clears most cases, but verify manually if failures persist.
- **`mise WARN missing: flutter@...`** — Ensure the requested Flutter toolchain is installed via `mise install` and available on `PATH`.
- **Hanging runs** — Check `.tmp/flutter_test_server.sh.log` for the last timestamp. If the log stalls before tests execute, run `flutter clean` and retry to clear stale build artifacts.
- **CI environments without GUI** — The Flutter tool launches Chrome in headless mode automatically when running on web; no extra flags are required, but make sure the environment allows sandboxed Chrome. If not, add `--no-sandbox` to the `flutter drive` command.

## Related Documentation To Mirror

When transplanting this workflow into another Flutter project, replicate any existing test specs, bug reports, or driver notes so future agents understand:

- Which user flows each integration test covers.
- How to interpret generated screenshots or logs.
- Where to document regressions and fixes.

Keep those documents close to the script (e.g., alongside `integration_test/` or under a `docs/` directory) so the testing story stays discoverable.

---

Copy this HOWTO into new Flutter repositories as-is, then adjust the final sections to reference that project's specific test suites and branching strategy.

## Example: Hello World Flutter Test

Start small before wiring deep scenarios. A single widget smoke test confirms the toolchain, dependencies, and routing all behave:

```bash
cd demo/01
flutter test test/widget_test.dart
```

Example test body:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner_demo/app.dart';

void main() {
  testWidgets('renders hello headline', (tester) async {
    await tester.pumpWidget(const MealPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Meal Planner'), findsOneWidget);
  });
}
```

Pull API details and best practices directly from the Flutter docs using the Context7 MCP (`context7__resolve-library-id` + `context7__get-library-docs`). Recommended references:

- Running Flutter Driver tests on Web: https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Running-Flutter-Driver-tests-with-Web.md
- Sample widget test: https://github.com/flutter/flutter/blob/master/examples/hello_world/test/hello_test.dart
- Web driver entrypoint example: https://github.com/flutter/flutter/blob/master/examples/hello_world/test_driver/smoke_web_engine.dart
- Matching integration test target: https://github.com/flutter/flutter/blob/master/examples/hello_world/test_driver/smoke_web_engine_test.dart

## Recommended Incremental Test Workflow

1. **Reset the workspace** — terminate any prior driver runs, clear `.tmp/` logs if needed, confirm no stray `chromedriver` processes are alive (`pgrep -fl chromedriver`).
2. **Add one test at a time** — create or extend a single test (widget or driver). Keep diffs small and focused.
3. **Run the full suite from `demo/01`** — `flutter test` for unit/widget coverage and `timeout 180 ./flutter_test_server.sh` (or `flutter drive` equivalent) for driver coverage. Never skip the full run even if only one file changed.
4. **Capture outcomes** — on success note the green run; on failure save the console output as `./demo/01/TEST01_n.md`, incrementing `n` for each new cycle before any fixes land. Include failing test names, stack traces, and any relevant console logs.
5. **Document and pause on bugs** — stop development after writing the report so feature engineers can fix the regression before more tests are layered on.
6. **Rinse and repeat** — once fixes land, rerun from step 1 to confirm the suite is green before authoring the next test.

This disciplined rhythm ensures the automation grows predictably, failures are triaged immediately, and each new test has been validated in isolation before stacking additional coverage.
