# Flutter Testing HOWTO

This guide documents how we exercise the `demo/01` Flutter application using Flutter's modern testing stack. The emphasis is on fast feedback with `flutter test` and the `integration_test` package when we need browser coverage. Legacy `flutter_driver` based flows are intentionally removed.

## Testing Approach

This project uses Flutter's `integration_test` package (and the built-in widget test runner). **Do not use** the deprecated `flutter_driver` APIs or any `flutter drive` commands. All tests run through `flutter test`, and the same commands work for both headless widget tests and browser-based integration tests when we eventually add them back.

## Quick Start for This Repository

1. `cd demo/01`
2. `flutter pub get`
3. Run the widget/unit suite: `flutter test`
4. When web coverage is required: `flutter test integration_test --platform=chrome`

Avoid running tests from the repository root—everything assumes the project root is `demo/01`.

## Prerequisites

- Flutter SDK (3.35 or newer) installed via `mise` per the repository configuration. Confirm with `mise list` before running tests.
- Chrome (stable) for optional web runs. Flutter will launch a headless instance automatically when `--platform=chrome` is requested; no ChromeDriver installation is required.
- A terminal session with enough permissions to run `flutter test` and watch stdout/stderr. No additional helper scripts or PID files are involved.

## Directory Layout Snapshot

```
<repo-root>/
  └── demo/01/
      ├── lib/                 # application source
      ├── test/                # widget and unit tests
      ├── integration_test/    # reserved for future integration_test suites
      ├── pubspec.yaml
      └── ...
```

We currently focus on the `test/` directory for fast widget coverage. New browser-backed integration tests will live under `integration_test/` once authored.

## Running Tests

- **Single file**: `flutter test test/app_test.dart`
- **Entire widget suite**: `flutter test`
- **Browser-backed runs (when needed)**: `flutter test integration_test --platform=chrome`

The last command spins up a local web server and launches Chrome headlessly. It is only necessary when validating behavior specific to the web renderer; most coverage should remain inside the standard widget tests for speed.

## Example: Hello World Flutter Tests

Starting small ensures the toolchain and dependencies are healthy. The following two tests live in `test/app_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner_demo/app.dart';

void main() {
  testWidgets('app loads and shows title', (tester) async {
    await tester.pumpWidget(const MealPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Meal Planner'), findsOneWidget);
  });

  testWidgets('app shows current week on load', (tester) async {
    await tester.pumpWidget(const MealPlannerApp());
    await tester.pumpAndSettle();

    final weekHeaderFinder = find.textContaining('Week');
    expect(weekHeaderFinder, findsAtLeastNWidgets(1));

    const dayAbbreviations = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final hasVisibleDay = dayAbbreviations.any(
      (label) => find.textContaining(label).evaluate().isNotEmpty,
    );

    expect(hasVisibleDay, isTrue, reason: 'Expected at least one day label to render');
  });
}
```

Run them with:

```bash
flutter test test/app_test.dart
```

Once these pass, we can layer deeper scenarios (scrolling, drag-and-drop, save/reset) one at a time.

## Recommended Incremental Test Workflow

1. **Start from a clean slate** – ensure no leftover processes are running (`ps -ef | grep flutter` if needed) and confirm the working tree is tidy (`git status`).
2. **Add one focused test** – extend an existing file or create a new test file with a single new scenario.
3. **Run the full suite** – execute `flutter test` from `demo/01` after every new test. If browser behavior is under development, also run `flutter test integration_test --platform=chrome` once the integration tests exist.
4. **Capture failures immediately** – when a run fails, save the console output to `./demo/01/TEST01_n.md`, incrementing `n` for each distinct cycle before fixes land. Include the failing test names, stack traces, and any relevant logs.
5. **Pause for fixes** – stop adding coverage until the underlying bug is fixed. After a fix merges, rerun the full suite before layering the next test.
6. **Document as you grow** – keep this HOWTO and related specs (see `VALIDATION.md`, `SPEC.md`, `AGENTS.md`) updated so every engineer understands the current expectations and coverage.

## Reference Documentation

Use the Context7 MCP (`context7__resolve-library-id` + `context7__get-library-docs`) to pull Flutter testing guidance. Key references provided by the owner:

- https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Running-Flutter-Driver-tests-with-Web.md (historical context; keep in mind the approach is now deprecated)
- https://github.com/flutter/flutter/blob/master/examples/hello_world/test/hello_test.dart
- https://github.com/flutter/flutter/blob/master/examples/hello_world/test_driver/smoke_web_engine.dart
- https://github.com/flutter/flutter/blob/master/examples/hello_world/test_driver/smoke_web_engine_test.dart

These URLs remain useful for understanding how Flutter structured early samples, even though we now rely on `integration_test` rather than `flutter_driver`.

---

Copy this HOWTO into new Flutter repositories as-needed, tailoring the directory references and test workflow to match each project's structure. Maintain the `flutter test` workflow as the single source of truth for both local development and CI.
