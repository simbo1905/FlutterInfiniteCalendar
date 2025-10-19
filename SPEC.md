
# Specification: Infinite Scrolling Meal Planner

## 1. Overview

This document specifies the requirements for a "Meal Planner" mobile application. The application will feature an infinitely scrolling calendar interface designed for planning weekly meals. The core UI combines a vertical list of days with horizontally scrolling carousels of "meal cards" for each day.

The primary goal is to create a highly interactive and intuitive interface where users can plan their meals by adding, removing, and rearranging meal cards via drag-and-drop gestures.

This specification will be used as the basis for a "bake-off" to implement demo applications using various Flutter components, targeting both **Web** and **iOS**.

## 2. Visual Design & Layout

The UI is composed of a main screen with a header and a calendar body.

### 2.1. Header
- **Save Button:** Located at the top right. Persists the current meal plan.
- **Reset Button:** Located below the "Save" button. Reverts the meal plan to the last saved state.

### 2.2. Calendar Body
The body is an infinite vertical scroll view of weeks.

- **Week Grouping:** Days should be visually grouped by week, with a clear separator or header for each week (e.g., "Week 42, 2025").
- **Day Row:** Each day is represented by a single row.
    - **Date Indicator (Left):**
        - A fixed-width column on the left displays the day of the week (e.g., "MON", "TUE") and the date (e.g., "20", "21").
        - The current day should be visually highlighted (e.g., different background color, font weight).
        - The "selected" day must have a distinct visual indicator.
    - **Meal Carousel (Right):**
        - A horizontally scrollable container (carousel) that takes the remaining width of the row.
        - Contains the `Meal Cards` for that day.

### 2.3. Meal Card
Represents a single meal entity.
- **Layout:**
    - **Color Tab:** A colored vertical bar on the left edge, indicating the meal type. This should be a subtle gradient.
    - **Icon:** An icon next to the color tab, also representing the meal type.
    - **Title:** The name of the meal (e.g., "Fish and Chips").
    - **Quantity:** A secondary piece of information, representing prep time in minutes (e.g., "30 min").
    - **Delete Button:** A faint `[x]` icon in the top-right corner. It should be subtle but clearly actionable.
- **Styling:** Cards should have rounded corners, a slight shadow to lift them off the background, and a clean, modern aesthetic.

### 2.4. "+ Add" Card
A special, static card at the end of each day's carousel.
- **Appearance:** It should visually match the background of the carousel, with a border and a centered `+ Add` text or icon. It is not a real card and cannot be dragged.
- **Function:** Acts as the button to add a new meal to that day.

### 2.5. Add Meal Bottom Sheet
A panel that slides up from the bottom when the `+ Add` card is tapped.
- **Content:** Lists all available `Meal Templates`.
- **Interaction:** Each item in the list has a `+` button to add an instance of that meal to the selected day.

## 3. Interaction & Behavior

### 3.1. Scrolling
- **Vertical Scroll:** Scrolls through past and future weeks infinitely.
- **Horizontal Scroll:** Scrolls through meal cards within a single day's carousel.

### 3.2. Day Selection
- **Initial State:** The current date is selected by default when the app loads.
- **Mechanism:** A day becomes "selected" when the user:
    1. Taps on the day row's Date Indicator.
    2. Taps the `+ Add` card on a day row.
    3. Drops a `Meal Card` onto a day row.
- **Visuals:** The selected day row must be visually distinct from other rows.

### 3.3. Moving Meals Between Days
- **Long-Press Gesture:** Users can press and hold a `Meal Card` to open an action menu.
- **Action Menu:** A bottom sheet appears with two options:
  - **Move to Another Day** - Opens a date picker
  - **Delete Meal** - Opens delete confirmation dialog
- **Date Picker Flow:**
  1. User taps "Move to Another Day"
  2. A date picker (CupertinoDatePicker) appears in a bottom sheet
  3. User scrolls to select the target date
  4. User taps "Done" to confirm the move
  5. The meal card is removed from the original day and added to the selected day
- **Visual Hint:** Each meal card displays a semi-transparent lightning bolt icon to indicate long-press is available.

### 3.4. Adding a Meal
1. User taps the `+ Add` card on a specific day (this day becomes the "selected day").
2. The "Add Meal Bottom Sheet" appears.
3. User finds a meal template in the sheet and taps its `+` button.
4. The bottom sheet dismisses.
5. A new `Meal Card`, based on the chosen template, appears in the selected day's carousel.

### 3.5. Deleting a Meal
1. User long-presses a `Meal Card` to open the action menu.
2. User taps "Delete Meal" in the action menu.
3. A confirmation dialog appears with "Cancel" and "Delete" options.
4. If "Delete" is chosen, the card is removed from the UI.

### 3.6. State Management (Save/Reset)
- The application maintains two states for the meal plan: a `workingState` and a `persistentState`.
- **Initial Load:**
    - The calendar calculates the current week number (e.g., Week 42).
    - Mock data is generated for the current week and the next week. This data populates the `persistentState`.
    - The `workingState` is created as a deep copy of the `persistentState`.
    - The UI renders based on the `workingState`.
- **User Actions:** All actions (add, delete, move) modify the `workingState` only.
- **Reset Button:** The `workingState` is discarded and replaced with a fresh copy of the `persistentState`. The UI updates to reflect this.
- **Save Button:** The `persistentState` is replaced with the current `workingState`.

## 4. Data Model

### 4.1. Meal Template (Static)
Defines the blueprint for a meal.
- `templateId` (string): A unique identifier for the template (e.g., "breakfast_1").
- `title` (string): The display name of the meal.
- `type` (enum): `Breakfast`, `Lunch`, `Dinner`, `Snack`, `Supper`.
- `quantity` (integer): Prep time in minutes.
- `icon` (string): Identifier for the icon to be displayed.
- `color` (string): Hex code for the color tab.

### 4.2. Meal Instance (Dynamic)
Represents a meal card placed on the calendar.
- `id` (string): A unique UUID for this specific instance.
- `templateId` (string): Foreign key linking to the `MealTemplate`.
- `date` (string): The date the meal is assigned to (e.g., "2025-10-24").
- `order` (integer): The zero-based index for its position in the day's carousel.

### 4.3. State Collections
- `persistentState`: `Map<String, List<MealInstance>>` where the key is the date string and the value is a list of meal instances for that day, sorted by `order`.
- `workingState`: A deep copy of the `persistentState` that the UI operates on.

## 5. Mock Data: Meal Templates

The following templates must be available in the "Add Meal Bottom Sheet".

| templateId    | title              | type       | quantity | icon          | color    |
|---------------|--------------------|------------|----------|---------------|----------|
| `breakfast_1` | "Oatmeal"          | `Breakfast`| 10       | `bowl`        | `#4285F4`|
| `breakfast_2` | "Scrambled Eggs"   | `Breakfast`| 15       | `egg`         | `#4285F4`|
| `lunch_1`     | "Chicken Salad"    | `Lunch`    | 20       | `restaurant`  | `#DB4437`|
| `lunch_2`     | "Tuna Sandwich"    | `Lunch`    | 10       | `fish`        | `#DB4437`|
| `dinner_1`    | "Fish and Chips"   | `Dinner`   | 30       | `fast-food`   | `#F4B400`|
| `dinner_2`    | "Steak and Veg"    | `Dinner`   | 45       | `local-bar`   | `#F4B400`|
| `snack_1`     | "Apple Slices"     | `Snack`    | 5        | `nutrition`   | `#0F9D58`|
| `snack_2`     | "Yogurt"           | `Snack`    | 2        | `ice-cream`   | `#0F9D58`|
| `supper_1`    | "Glass of Milk"    | `Supper`   | 1        | `local-cafe`  | `#AB47BC`|
| `supper_2`    | "Herbal Tea"       | `Supper`   | 5        | `free-breakfast`| `#AB47BC`|

*(Note: Icon names are suggestions, e.g., from Material Icons)*

## 7. Logging Requirements

To facilitate testing and validation, the application must output structured logs to the developer console (`console.log` for web).

### 7.1. Log Format
All logs must follow this consistent format:
`[TIMESTAMP] [LEVEL] [ACTION] - {DETAILS}`

-   **TIMESTAMP**: ISO 8601 format (e.g., `2025-10-17T10:00:00.000Z`).
-   **LEVEL**: `INFO` for user actions and screen events, `DEBUG` for state dumps.
-   **ACTION**: A string identifying the event type.
-   **DETAILS**: A JSON object containing relevant event data.

### 7.2. Log Events

The following events must be logged:

-   **Initial State Dump:**
    -   **When:** Before the main screen is first built.
    -   **Action:** `INIT_STATE`
    -   **Level:** `DEBUG`
    -   **Details:** `{"persistentState": <state>}` where `<state>` is the complete initial `persistentState` map.

-   **Screen Load:**
    -   **When:** Every time the main calendar screen is loaded or reloaded.
    -   **Action:** `SCREEN_LOAD`
    -   **Level:** `INFO`
    -   **Details:** `{"reason": "Initial Load" | "Reset"}`

-   **Add Meal:**
    -   **When:** After a meal is successfully added.
    -   **Action:** `ADD_MEAL`
    -   **Level:** `INFO`
    -   **Details:** `{"meal": <MealInstance>}` where `<MealInstance>` is the full object of the newly added meal.

-   **Delete Meal:**
    -   **When:** After a meal is successfully deleted.
    -   **Action:** `DELETE_MEAL`
    -   **Level:** `INFO`
    -   **Details:** `{"mealId": "<id>"}`

-   **Move Meal (Inter-day):**
    -   **When:** After a meal is successfully moved to a new day.
    -   **Action:** `MOVE_MEAL`
    -   **Level:** `INFO`
    -   **Details:** `{"mealId": "<id>", "from": {"date": "<date>", "order": <index>}, "to": {"date": "<date>", "order": <index>}}`

-   **Reorder Meal (Intra-day):**
    -   **When:** After a meal is successfully reordered within the same day.
    -   **Action:** `REORDER_MEAL`
    -   **Level:** `INFO`
    -   **Details:** `{"mealId": "<id>", "date": "<date>", "from": {"order": <index>}, "to": {"order": <index>}}`

## 8. Use Cases for Testing

- **UC-1 (Initial Load):**
    - Open the app.
    - **Verify:** The calendar opens to the current week.
    - **Verify:** Randomly generated meals for the current and next week are displayed.
    - **Verify:** The current day is highlighted and selected.

- **UC-2 (Navigation):**
    - **Action:** Scroll vertically up and down.
    - **Verify:** The app smoothly scrolls to past and future weeks, loading them as needed.
    - **Action:** Scroll horizontally on a day with multiple meals.
    - **Verify:** The meal carousel scrolls correctly.

- **UC-3 (Add Meal):**
    - **Action:** Scroll to a future day with no meals. Tap `+ Add`.
    - **Verify:** The "Add Meal Bottom Sheet" appears.
    - **Action:** Tap the `+` button next to "Fish and Chips".
    - **Verify:** The sheet closes and a "Fish and Chips" card appears on the correct day.

- **UC-4 (Delete Meal):**
    - **Action:** Tap the `[x]` on the newly added card.
    - **Verify:** A confirmation dialog appears.
    - **Action:** Tap "Delete".
    - **Verify:** The card is removed.

- **UC-5 (Reorder Meal):**
    - **Action:** On a day with at least two meals, drag the first meal to the right of the second meal.
    - **Verify:** The order of the cards is swapped.

- **UC-6 (Move Meal):**
    - **Action:** Drag a meal from "Monday" down to "Wednesday".
    - **Verify:** The card is removed from Monday's carousel and appears in Wednesday's carousel.

- **UC-7 (Save & Reset):**
    - **Action:** Move a meal from Monday to Tuesday.
    - **Action:** Tap "Reset".
    - **Verify:** The meal moves back to Monday.
    - **Action:** Move the meal to Tuesday again. Tap "Save".
    - **Action:** Move the meal to Wednesday. Tap "Reset".
    - **Verify:** The meal moves back to Tuesday (the last saved state), not Monday (the initial state).

## 9. Planned Meals Counter

### 9.1. Display Requirements
- **Position:** Left of Save/Reset buttons, right-justified in the app bar
- **Initial state:** Display "No Planned Meals" when the app first loads
- **Loaded state:** Display "Planned Meals: N" where N is the count of meals on current day and all future days
- **Widget key:** `Key('planned_meals_counter')` for testing purposes

### 9.2. Update Behavior
- Counter must increment by 1 when a meal is added to the current day or any future day
- Counter must decrement by 1 when a meal is removed from the current day or any future day
- Counter must update appropriately on Save/Reset operations
- Counter must display "No Planned Meals" when the count is zero (not "Planned Meals: 0")
- All counter updates must log to console: `print('updating planned meals to N');` where N is the new count
- The log must appear **before** the UI updates

### 9.3. Demo Data Initialization
- The application must load exactly 12 dummy meals on startup
- Meals must follow a fixed distribution pattern by day of week (repeating):
  - Monday: 3 meals
  - Tuesday: 2 meals
  - Wednesday: 1 meal
  - Thursday: 0 meals
  - Friday: 3 meals
  - Saturday: 2 meals
  - Sunday: 1 meal
- This pattern starts from the current week's Monday and extends through the next week
- Total meals across both weeks: 3+2+1+0+3+2+1 = 12 meals
- After demo data loads, the first counter update must set the counter to "Planned Meals: 12"
- Console must log: `updating planned meals to 12` after initialization completes

### 9.4. Implementation Notes
- Initialization logic should be simple, deterministic, and hardcoded
- No random generation for the demo data
- The counter serves dual purposes:
  1. User-facing feature showing upcoming meal count
  2. Test synchronization point for automated testing
