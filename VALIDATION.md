# Validation Protocol: Infinite Scrolling Meal Planner

## Overview

This document defines the validation requirements for any implementation of the Infinite Scrolling Meal Planner as specified in `SPEC.md`. 

**Prerequisites**: Read `AGENTS.md` first to understand the project structure, monorepo layout, and automation architecture.

## Testing Approach

This protocol describes **behavioral test scenarios** that must be validated for any demo implementation. These tests can be executed:

- **Manually** by a human tester following the steps below
- **Automated** using Appium tests written in JavaScript

### Automated Test Implementation

Each demo has its own isolated test suite under `automation/tests/<demo-number>/` containing demo-specific Appium test implementations. Tests are written in JavaScript using WebDriverIO and the Flutter Integration Driver.

**To run automated tests for a demo**:

```bash
# From repository root
DEMO=01 mise run test
```

This executes all test files in `automation/tests/01/` against the built APK for demo 01. Test results and screenshots are saved to `automation/screenshots/`.

**Important**: The test **scenarios** below are implementation-agnostic. Each demo's actual test code will vary based on the Flutter calendar component used, but all implementations must satisfy these behavioral requirements.

---

## Critical Path Tests

**These two tests are make-or-break. If a demo cannot pass these, it is not worth pursuing further testing.**

### Test 1: Trivial Test - Confirms Setup
**Objective**: Verify the automation environment works and the application renders dynamic content.

**Priority**: **CRITICAL** - Must pass before any other testing

**Steps**:
1. Launch the application via Appium
2. Wait for the calendar view to fully render
3. Wait for mock meal data to load dynamically (this is async, not immediate)
4. Count the total number of meal cards visible on screen
5. Take a screenshot

**Expected Results**:
- Application launches without crashes
- Appium successfully connects to the Flutter app
- Test waits successfully for dynamic content (cards) to render
- At least one meal card is counted (per `SPEC.md` initial data requirements)
- Screenshot is saved showing the rendered calendar with cards
- Test completes within 30 seconds

**Why this is critical**: If this test fails, the Appium setup, Flutter integration, or app initialization is broken. There's no point testing drag-and-drop if basic rendering doesn't work.

---

### Test 2: Trivial DnD Sanity Test
**Objective**: Verify both vertical (inter-day) and horizontal (intra-day) drag-and-drop functionality works at a basic level.

**Priority**: **CRITICAL** - Must pass before considering this demo viable

**Steps**:

**Part A: Vertical Drag (Move Between Days)**
1. Wait for calendar to fully render with cards
2. Identify a meal card on one day (e.g., Monday)
3. Identify a target day (e.g., Tuesday - can be empty or populated)
4. Capture "before" screenshot
5. Drag the card from source day to target day
6. Wait for UI to update
7. Capture "after" screenshot
8. Verify the card moved:
   - Source day has one fewer card (or is now empty)
   - Target day has the card (as first, last, or only card)

**Part B: Horizontal Drag (Reorder Within Day)**
1. Find a day with at least 2 meal cards
2. Note the initial order of the first two cards
3. Capture "before" screenshot
4. Drag the first card to the right past the second card
5. Wait for UI to update
6. Capture "after" screenshot
7. Verify the cards are now in reversed order

**Expected Results**:
- Both vertical and horizontal drag gestures are recognized (not interpreted as taps or swipes)
- Cards visually follow the drag gesture
- UI updates to reflect the new positions
- Screenshots show clear before/after state changes
- Console logs show `[MOVE_MEAL]` (for Part A) and `[REORDER_MEAL]` (for Part B) per `SPEC.md`
- Test completes within 60 seconds

**Why this is critical**: Drag-and-drop is the hardest functionality to get working. If this test fails, the demo's calendar component doesn't support proper DnD, and debugging all the other tests will be wasted effort. All other meal management features (add, delete, save/reset) are comparatively trivial once DnD works.

---

## Standard Test Suite

**Only proceed with these tests after Tests 1 and 2 pass reliably.** These tests validate the complete specification but are less likely to uncover showstopper issues. Each test should be as standalone as possible to facilitate independent debugging.

### Test 3: Application Launch and Initial State
**Objective**: Verify detailed initial state requirements from `SPEC.md`.

**Steps**:
1. Launch the application
2. Wait for calendar view to fully render
3. Check the displayed week indicator
4. Check for current day highlighting
5. Examine visible meal cards across current and next week

**Expected Results**:
- Calendar opens to the current week (matching system date)
- Current day is visually highlighted or selected
- Week indicator shows correct week number and year
- Current week contains randomly generated meal cards
- Following week contains randomly generated meal cards
- Each meal card displays: colored tab, icon, title, and quantity (prep time)

---

### Test 4: Console Logging Verification
**Objective**: Verify structured logging is implemented per `SPEC.md`.

**Steps**:
1. Open browser/device developer console
2. Review logs from application startup
3. Verify log format and required entries

**Expected Results**:
- `[TIMESTAMP] [DEBUG] [INIT_STATE]` log present with full `persistentState` dump
- `[TIMESTAMP] [INFO] [SCREEN_LOAD]` log present with `"reason": "Initial Load"`
- All logs follow format: `[TIMESTAMP] [LEVEL] [ACTION] - {DETAILS}`
- Timestamps are in ISO 8601 format

---

### Test 5: Vertical Scrolling - Future Weeks
**Objective**: Verify infinite scrolling loads future weeks dynamically.

**Steps**:
1. From initial state, scroll down continuously
2. Observe new weeks loading
3. Continue scrolling for at least 10 weeks into the future
4. Check week number and year transitions

**Expected Results**:
- Calendar smoothly loads future weeks on demand
- Week numbers increment correctly
- Year changes appropriately when crossing from Week 52 to Week 1
- No performance degradation or crashes

---

### Test 6: Vertical Scrolling - Past Weeks
**Objective**: Verify infinite scrolling loads past weeks dynamically.

**Steps**:
1. From initial state, scroll up continuously
2. Observe past weeks loading
3. Continue scrolling for at least 10 weeks into the past
4. Check week number and year transitions

**Expected Results**:
- Calendar smoothly loads past weeks on demand
- Week numbers decrement correctly
- Year changes appropriately when crossing from Week 1 to Week 52
- No performance degradation or crashes

---

### Test 7: Horizontal Scrolling - Meal Carousel
**Objective**: Verify day carousels scroll horizontally when multiple cards are present.

**Steps**:
1. Find a day with at least 3 meal cards
2. Scroll the meal carousel left and right
3. Observe card visibility and behavior

**Expected Results**:
- Carousel scrolls smoothly in both directions
- Cards remain properly aligned
- "+ Add" card stays fixed at rightmost position
- No cards are cut off or overlapping incorrectly

---

### Test 8: Add Meal to Empty Day
**Objective**: Verify meals can be added to days with no existing cards.

**Steps**:
1. Find a day with zero meal cards
2. Tap the "+ Add" card on that day
3. Verify bottom sheet appears
4. Select a meal template (e.g., "Fish and Chips")
5. Tap the "+" button next to the template

**Expected Results**:
- Bottom sheet displays all meal templates from `SPEC.md`
- After selection, bottom sheet closes
- New meal card appears on the selected day
- Card displays correct icon, title, color, and quantity
- `[TIMESTAMP] [INFO] [ADD_MEAL]` log appears with full meal instance data

---

### Test 9: Add Meal to Populated Day
**Objective**: Verify meals can be added to days that already have cards.

**Steps**:
1. Find a day with at least one existing meal card
2. Tap the "+ Add" card
3. Select a different meal template
4. Add the meal

**Expected Results**:
- New card added to end of carousel (before "+ Add")
- Existing cards remain unchanged
- Carousel scrolls if necessary to show new card
- `[ADD_MEAL]` log appears

---

### Test 10: Delete Meal Card with Confirmation
**Objective**: Verify meals can be deleted with user confirmation.

**Steps**:
1. Locate any meal card
2. Tap the "[x]" delete button
3. Observe confirmation dialog
4. Tap "Delete" to confirm

**Expected Results**:
- Confirmation dialog appears with "Cancel" and "Delete" options
- After confirming, card is removed from UI
- Other cards on same day shift/reflow appropriately
- `[TIMESTAMP] [INFO] [DELETE_MEAL]` log appears with meal ID

---

### Test 11: Cancel Delete Operation
**Objective**: Verify delete confirmation can be cancelled.

**Steps**:
1. Tap "[x]" delete button on a meal card
2. Tap "Cancel" in confirmation dialog

**Expected Results**:
- Dialog closes
- Card remains unchanged
- No delete log appears

---

### Test 12: Move Card Between Days (Same Week)
**Objective**: Verify vertical drag-and-drop between different days.

**Note**: This repeats Test 2 Part A but as a standalone test for debugging app behavior (not test infrastructure).

**Steps**:
1. Wait for calendar to fully render
2. Find a card on one day (e.g., Monday)
3. Note card details
4. Capture "before" screenshot
5. Drag card to a different day in the same week (e.g., Wednesday)
6. Release to drop
7. Wait for UI update
8. Capture "after" screenshot

**Expected Results**:
- Card visually follows drag gesture
- Card disappears from source day
- Card appears in target day
- `[TIMESTAMP] [INFO] [MOVE_MEAL]` log shows correct dates and order indices

---

### Test 13: Move Card to Empty Day
**Objective**: Verify cards can be moved to days with no existing cards.

**Steps**:
1. Find an empty day (zero cards)
2. Find a card on a different day
3. Drag card to empty day
4. Drop

**Expected Results**:
- Card moves successfully
- Card is only card on target day
- Source day updates correctly
- `[MOVE_MEAL]` log appears

---

### Test 14: Move Card to Future Week (Auto-scroll)
**Objective**: Verify drag-to-edge auto-scrolling and cross-week movement.

**Steps**:
1. Find a card in currently visible week
2. Press and hold card
3. Drag to bottom edge of viewport
4. Hold at edge until calendar auto-scrolls down
5. Continue to day in future week
6. Drop

**Expected Results**:
- Calendar auto-scrolls downward smoothly when card held at bottom edge
- Card can be dropped on day in future week
- Card moves from source to target week correctly
- `[MOVE_MEAL]` log reflects cross-week move

---

### Test 15: Move Card to Past Week (Auto-scroll)
**Objective**: Verify upward auto-scrolling for past week movement.

**Steps**:
1. Find a card in currently visible week
2. Drag to top edge of viewport
3. Hold until calendar auto-scrolls up
4. Drop on day in past week

**Expected Results**:
- Calendar auto-scrolls upward smoothly
- Card moves to past week correctly
- `[MOVE_MEAL]` log appears with correct date change

---

### Test 16: Reorder Cards Within Same Day
**Objective**: Verify horizontal drag-and-drop reordering.

**Note**: This repeats Test 2 Part B but as a standalone test for debugging app behavior.

**Steps**:
1. Find a day with at least 2 meal cards
2. Note initial order
3. Capture "before" screenshot
4. Drag first card to right past second card
5. Release to drop
6. Wait for UI update
7. Capture "after" screenshot

**Expected Results**:
- Card follows drag gesture horizontally
- After drop, cards are reordered
- New order persists
- `[TIMESTAMP] [INFO] [REORDER_MEAL]` log shows old and new order indices

---

### Test 17: Reorder Cards - Multiple Positions
**Objective**: Verify cards can be dragged to any carousel position.

**Steps**:
1. Find a day with at least 3 meal cards
2. Drag third card to first position
3. Verify reordering
4. Drag second card to last position
5. Verify reordering

**Expected Results**:
- Each drag operation updates order correctly
- UI reflects changes immediately
- Multiple `[REORDER_MEAL]` logs appear, one per operation

---

### Test 18: Reset to Initial State
**Objective**: Verify Reset button reverts to initial state before any saves.

**Steps**:
1. From initial state, move a card from Monday to Tuesday
2. Verify the move
3. Tap "Reset" button
4. Observe UI

**Expected Results**:
- Card returns to original Monday position
- UI matches initial state exactly
- `[TIMESTAMP] [INFO] [SCREEN_LOAD]` log with `"reason": "Reset"`
- No changes persist after reset

---

### Test 19: Save State and Reset to Saved State
**Objective**: Verify Save creates new persistent state and Reset reverts to it.

**Steps**:
1. From initial state, move card from Monday to Tuesday
2. Tap "Save" button
3. Make another change: move different card from Wednesday to Thursday
4. Tap "Reset" button

**Expected Results**:
- After Reset, first change persists (Monday→Tuesday remains)
- Second change reverted (Wednesday→Thursday undone)
- UI shows state when "Save" was pressed
- `[SCREEN_LOAD]` log with `"reason": "Reset"`

---

### Test 20: Multiple Save Operations
**Objective**: Verify Save can be pressed multiple times.

**Steps**:
1. Make change A (move a card)
2. Tap "Save"
3. Make change B (delete a card)
4. Tap "Save"
5. Make change C (add a card)
6. Tap "Reset"

**Expected Results**:
- After Reset, changes A and B persist
- Change C reverted
- Reset always reverts to most recent Save point

---

### Test 21: Reset Without Save
**Objective**: Verify Reset works when no Save has been performed.

**Steps**:
1. Launch application
2. Make several changes (add, move, delete cards)
3. Do NOT tap "Save"
4. Tap "Reset"

**Expected Results**:
- All changes reverted
- Calendar returns to initial generated state
- No user changes persist

---

### Test 22: Full Meal Planning Workflow
**Objective**: Verify realistic workflow combining multiple operations.

**Steps**:
1. Launch app
2. Add "Oatmeal" to Monday
3. Add "Chicken Salad" to Monday
4. Reorder Monday's cards (swap positions)
5. Save the state
6. Move "Oatmeal" from Monday to Friday
7. Add "Fish and Chips" to Wednesday
8. Delete "Chicken Salad" from Monday
9. Reset

**Expected Results**:
- Each operation works correctly in sequence
- After Reset, state shows:
  - Monday has "Oatmeal" and "Chicken Salad" in swapped order (saved state)
  - Friday has no "Oatmeal" (move reverted)
  - Wednesday has no "Fish and Chips" (add reverted)
  - Monday still has "Chicken Salad" (delete reverted)

---

### Test 23: Drag and Drop Error Handling
**Objective**: Verify drag operations handle edge cases gracefully.

**Steps**:
1. Try dragging card and releasing outside calendar area
2. Try dragging card and pressing "Back" or "Home" mid-drag
3. Try dragging while rapidly scrolling

**Expected Results**:
- Invalid drops cancel operation (card returns to source)
- No crashes or UI corruption
- State remains consistent

---

## Grading Criteria

Tests are evaluated on a pass/fail basis. Final grade is calculated as:

- **A (95-100% pass)**: All tests pass, polished UX, no bugs
- **B (80-94% pass)**: Core functionality works, minor visual or interaction issues
- **C (60-79% pass)**: Core features functional but with significant bugs
- **D (40-59% pass)**: Major features broken or incomplete
- **F (<40% pass)**: Application unusable or fails to launch

**CRITICAL tests** (must pass to continue any testing):
- Test 1: Trivial Test - Confirms Setup
- Test 2: Trivial DnD Sanity Test

**High priority tests** (must pass for C or higher):
- Test 3: Application Launch and Initial State
- Test 8: Add Meal to Empty Day
- Test 10: Delete Meal Card
- Test 12: Move Card Between Days
- Test 16: Reorder Cards Within Same Day
- Test 19: Save and Reset

**Standard tests** (must pass for B or higher):
- All remaining Tests 4-23

**Note**: If Tests 1 and 2 fail, **stop testing immediately**. The demo is not viable and further debugging would waste time. Focus on getting the critical path working first.

---

## Planned Meals Counter Validation

### Test 24: Planned Meals Counter - Initial State
**Objective**: Verify counter displays correct initial state before data loads.

**Steps**:
1. Launch application
2. Observe counter widget in app bar before data loads

**Expected Results**:
- Counter displays "No Planned Meals"
- Text is visible and properly positioned left of Save/Reset buttons
- Widget has key `planned_meals_counter`

---

### Test 25: Planned Meals Counter - Demo Data Load
**Objective**: Verify counter updates to 12 after demo data initialization.

**Steps**:
1. Launch application
2. Wait for demo data to load
3. Observe counter update
4. Check console logs

**Expected Results**:
- Counter updates from "No Planned Meals" to "Planned Meals: 12"
- Console shows: `updating planned meals to 12`
- All 12 meals follow distribution pattern: 3,2,1,0,3,2,1 (Mon-Sun repeating)
- Pattern starts from current week's Monday

---

### Test 26: Planned Meals Counter - Add Operation
**Objective**: Verify counter increments when adding meals to future days.

**Steps**:
1. From initial state with 12 meals
2. Add a meal to a future day (e.g., next Monday)
3. Verify counter increments
4. Check console log

**Expected Results**:
- Counter updates to "Planned Meals: 13"
- Console shows: `updating planned meals to 13`
- UI updates immediately after add operation

---

### Test 27: Planned Meals Counter - Remove Operation
**Objective**: Verify counter decrements when removing meals from current/future days.

**Steps**:
1. From state with 12 meals
2. Delete a meal from current or future day
3. Verify counter decrements
4. Check console log

**Expected Results**:
- Counter updates to "Planned Meals: 11"
- Console shows: `updating planned meals to 11`
- UI updates immediately after delete operation

---

### Test 28: Planned Meals Counter - Past Day Exclusion
**Objective**: Verify counter only counts current and future meals.

**Steps**:
1. Navigate to a past week
2. Add meals to past days
3. Observe counter value

**Expected Results**:
- Counter does not increment for past day meals
- Only meals on current day and future days are counted
- Console logs reflect accurate count excluding past meals

---

### Test 29: Planned Meals Counter - Reset to Zero
**Objective**: Verify counter displays "No Planned Meals" when count reaches zero.

**Steps**:
1. Delete all 12 meals one by one
2. Observe counter after each deletion
3. Observe counter when last meal is deleted

**Expected Results**:
- Counter decrements: 12 → 11 → 10 → ... → 1 → 0
- When count reaches 0, display changes to "No Planned Meals" (not "Planned Meals: 0")
- Console shows: `updating planned meals to 0` after last deletion

---

### Test 30: Planned Meals Counter - Move Between Days
**Objective**: Verify counter updates correctly when meals are moved between days.

**Steps**:
1. Move a meal from future day to another future day
2. Move a meal from future day to past day
3. Move a meal from past day to future day

**Expected Results**:
- Moving between future days: counter unchanged
- Moving from future to past: counter decrements by 1
- Moving from past to future: counter increments by 1
- Each boundary cross logs the new count

---

### Test 31: Planned Meals Counter - Save and Reset
**Objective**: Verify counter updates correctly on Save/Reset operations.

**Steps**:
1. From initial 12 meals, add 2 meals (counter shows 14)
2. Tap "Save"
3. Add 1 more meal (counter shows 15)
4. Tap "Reset"
5. Observe counter

**Expected Results**:
- After Reset, counter returns to 14 (saved state)
- Console logs the count update on reset
- Counter reflects the restored state accurately