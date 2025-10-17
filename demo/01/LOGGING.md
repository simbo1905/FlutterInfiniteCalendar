# Logging Implementation Summary

## Overview

Structured logging has been implemented per SPEC.md Section 7 requirements. All user actions and state changes are logged to the developer console in a standardized format.

## Log Format

`[TIMESTAMP] [LEVEL] [ACTION] - {DETAILS}`

- **TIMESTAMP**: ISO 8601 format (e.g., `2025-10-17T10:00:00.000Z`)
- **LEVEL**: `INFO` for user actions, `DEBUG` for state dumps
- **ACTION**: Event type identifier
- **DETAILS**: JSON object with event data

## Implementation Details

### Logger Utility (`lib/util/app_logger.dart`)

Created a centralized logging utility with methods for each event type:

```dart
class AppLogger {
  static void initState(Map<String, dynamic> persistentState)
  static void screenLoad(String reason)
  static void addMeal(Map<String, dynamic> mealInstance)
  static void deleteMeal(String mealId)
  static void moveMeal({...})
  static void reorderMeal({...})
}
```

### Logged Events

#### 1. INIT_STATE (DEBUG)
**When**: Before main screen is first built
**Where**: `lib/data/meal_repository.dart` - After initialization
**Details**: Complete `persistentState` map with all meal instances

```json
{
  "persistentState": {
    "2025-10-17": [
      {
        "id": "...",
        "templateId": "breakfast_1",
        "date": "2025-10-17",
        "order": 0,
        "title": "Oatmeal",
        "quantity": 10
      }
    ]
  }
}
```

#### 2. SCREEN_LOAD (INFO)
**When**: Calendar screen loads/reloads
**Where**: `lib/features/calendar/meal_calendar_screen.dart`
**Reasons**: "Initial Load" or "Reset"

```json
{
  "reason": "Initial Load"
}
```

#### 3. ADD_MEAL (INFO)
**When**: After meal is successfully added
**Where**: `lib/controllers/meal_controller.dart` - `addMealFromTemplate()`
**Details**: Complete meal instance object

```json
{
  "meal": {
    "id": "...",
    "templateId": "dinner_1",
    "date": "2025-10-17",
    "order": 2,
    "title": "Fish and Chips",
    "quantity": 30
  }
}
```

#### 4. DELETE_MEAL (INFO)
**When**: After meal is successfully deleted
**Where**: `lib/controllers/meal_controller.dart` - `removeMeal()`
**Details**: Meal ID

```json
{
  "mealId": "..."
}
```

#### 5. MOVE_MEAL (INFO)
**When**: After inter-day move (different dates)
**Where**: `lib/controllers/meal_controller.dart` - `moveMeal()`
**Details**: Meal ID, from/to date and order

```json
{
  "mealId": "...",
  "from": {
    "date": "2025-10-17",
    "order": 1
  },
  "to": {
    "date": "2025-10-18",
    "order": 0
  }
}
```

#### 6. REORDER_MEAL (INFO)
**When**: After intra-day reorder (same date)
**Where**: `lib/controllers/meal_controller.dart` - `moveMeal()`
**Details**: Meal ID, date, from/to order

```json
{
  "mealId": "...",
  "date": "2025-10-17",
  "from": {
    "order": 0
  },
  "to": {
    "order": 2
  }
}
```

## Files Modified

1. **New File**: `lib/util/app_logger.dart` - Logger utility
2. **Modified**: `lib/data/meal_repository.dart` - INIT_STATE logging
3. **Modified**: `lib/features/calendar/meal_calendar_screen.dart` - SCREEN_LOAD logging
4. **Modified**: `lib/controllers/meal_controller.dart` - ADD_MEAL, DELETE_MEAL, MOVE_MEAL, REORDER_MEAL logging

## How to View Logs

### Web (Chrome DevTools)
1. Run: `flutter run -d chrome`
2. Open DevTools: Press F12
3. Navigate to Console tab
4. Logs appear with "MealPlanner" source

### Mobile/Desktop
1. Run: `flutter run`
2. View terminal output
3. Logs appear in console with timestamps

## Testing the Logs

### Test Sequence
1. **App Launch**: See INIT_STATE (DEBUG) with initial data
2. **Screen Load**: See SCREEN_LOAD (INFO) with "Initial Load"
3. **Add Meal**: Tap + Add → See ADD_MEAL (INFO)
4. **Delete Meal**: Tap [x] → See DELETE_MEAL (INFO)
5. **Reorder**: Drag within day → See REORDER_MEAL (INFO)
6. **Move**: Drag to different day → See MOVE_MEAL (INFO)
7. **Reset**: Tap Reset → See SCREEN_LOAD (INFO) with "Reset"

All events follow the exact format specified in SPEC.md Section 7.
