# Infinite Scroll Event Calendar (Flutter Demo)

A cross-platform Flutter concept demonstrating an infinite scrolling weekly calendar with reusable, domain-agnostic event cards. The demo mirrors the provided reference screenshot and keeps all data in memory so you can explore UX flows quickly on both iOS and Android.

> **Domain neutral:** The calendar renders generic cards that expect only `title`, `quantity`, `color`, and `icon`. Any vertical—meal planning, training, production scheduling—can map its data to those four fields without changing the widgets.

## Features
- Sliver-based infinite scroll that prefetches previous and next weeks as you near the edges.
- Sticky week headers with dynamic totals and reset affordance matching the reference layout.
- Day rows with “today” highlighting, empty states, inline `+ Add` affordance, and card stacking.
- Reusable event cards featuring a colored stripe, compact metadata row, and drag handle zone.
- Long-press drag & drop between days (including cross-week) with visual drop feedback.
- Modal add panel that filters mock suggestions and inserts cards with undo support.
- Tap cards to view a details sheet with delete control.
- Save/Reset toolbar actions that snapshot the current layout and let you revert to the last saved baseline instantly.
- Event mutation log that records every add/move/delete, making conflict resolution and future syncing flows idempotent.
- Material 3 theming with light/dark palettes and platform-aware touches (bounce physics on iOS, ripples on Android).
- Riverpod-powered state management, keeping the calendar reusable as a package in larger apps.

## Screenshot
The UI aligns with the supplied design reference (`Screenshot.png`).

## Getting Started

### Prerequisites
Install Flutter (3.35+). On macOS with Homebrew:

```bash
brew install --cask flutter
export PATH="$PATH:/opt/homebrew/bin"
flutter doctor
```

### Project setup
```bash
flutter pub get
flutter analyze
flutter test
```

### Running on simulators/devices
- **iOS (via command line):** `flutter run` (choose an iOS Simulator from the prompt).
- **Android:** `flutter run` (select an Android emulator or device).

### Running on the web (Chrome)
```bash
flutter config --enable-web    # one-time setup
flutter run -d chrome          # launches the interactive web build
```
The automated suite also exercises the widgets in Chrome with `flutter test --platform=chrome`.

#### Launching from Xcode
1. From the project root, run `flutter pub get` (already done above) so that Xcode sees the generated Flutter artifacts.
2. Open the generated workspace: `open ios/Runner.xcworkspace`.
3. In Xcode:
   - Select the `Runner` scheme (default).
   - Choose your target device or simulator from the device picker.
   - Press **Cmd+R** (or click the Run ▶️ button).
4. The Flutter app will build, launch the selected simulator/device, and display the infinite calendar screen.

> Tip: the first build may take a minute while CocoaPods dependencies are compiled. If Xcode reports pod issues, run `cd ios && pod install`, then reopen `Runner.xcworkspace`.

The project uses in-memory data only; no additional services or emulators are required.

## Data Model
Each calendar card is backed by a `CalendarEvent`:

| Field   | Type        | Usage                                              |
|--------|-------------|----------------------------------------------------|
| title  | `String`    | Primary label (e.g., “Planning Session”).          |
| quantity | `String`  | Secondary value (distance, duration, servings, …). |
| color  | `Color`     | Stripe accent for categories/status.               |
| icon   | `IconData`  | Compact glyph reinforcing the quantity meaning.    |

Each interaction generates a `CalendarMutationRecord` (add/remove) stamped
with a time-ordered UUID. Replaying the ordered records reconstitutes the
per-day collections deterministically—even if the sequence contains duplicate
adds or missing deletes—making it safe for eventual multi-device syncing.

Mock data lives in `lib/data/mock_calendar_repository.dart` and is easily replaced with real sources.

## Architecture Overview
```
lib/
├── app.dart                      # MaterialApp + theming
├── controllers/
│   └── calendar_controller.dart  # Riverpod Notifier, paging, mutations
├── data/
│   └── mock_calendar_repository.dart
├── features/
│   └── calendar/
│       ├── calendar_screen.dart
│       └── widgets/
│           ├── week_section.dart
│           ├── day_row.dart
│           ├── event_card_tile.dart
│           ├── add_event_sheet.dart
│           └── loading_week_placeholder.dart
├── models/
│   └── event_entry.dart
└── theme/
    └── app_theme.dart
```
Key points:
- `CalendarController` centralizes infinite scroll, drag/drop, and optimistic updates.
- Widgets stay presentation-only and accept callbacks so they can be dropped into other apps.
- Theme tokens live in `app_theme.dart`, allowing downstream overrides through `ThemeData`.

## Testing
All tests run locally (no simulator required):

```bash
flutter test
flutter test --platform=chrome
```

Test coverage includes:
- Calendar controller behaviors (initial load, paging, add, move, remove).
- Widget smoke tests for calendar rendering and add-sheet interaction.

## Extending the Demo
- Swap the mock repository with real APIs or local stores by implementing the same interface.
- Override theme tokens or supply your own `ColorScheme` to match brand palettes.
- Inject custom search panels or card renderers by wrapping `CalendarScreen` with your own feature shell.

## License
This demo is provided as-is for internal exploration and future reuse across domain-specific apps.
