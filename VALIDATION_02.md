### Test 2: Move and Delete Functionality Test
**Objective**: Verify move-via-date-picker and delete-via-action-menu functionality works correctly.

**Priority**: **CRITICAL** - Must pass before considering this demo viable

**Steps**:

**Part A: Move Meal Between Days**
1. Wait for calendar to fully render with meal cards
2. Find first meal card (identified by long-press hint icon)
3. Count total cards before move
4. Long-press the meal card to open action menu
5. Verify action menu appears with "Move to Another Day" and "Delete Meal" options
6. Tap "Move to Another Day"
7. Verify date picker (CupertinoDatePicker) appears
8. Tap "Done" to confirm move to selected date
9. Wait for UI update
10. Verify card count remains the same (card moved, not deleted)
11. Log verification that move completed successfully

**Part B: Delete Meal**
1. Find another meal card
2. Count total cards before delete
3. Long-press the meal card to open action menu
4. Tap "Delete Meal"
5. Verify delete confirmation dialog appears
6. Tap "Delete" button to confirm
7. Wait for UI update
8. Verify card count decreased by one
9. Log verification that delete completed successfully

**Expected Results**:
- Long-press action menu appears correctly
- "Move to Another Day" opens date picker with CupertinoDatePicker
- Date picker "Done" button triggers move operation
- State changes are correct:
  - Move: Card count stays same, card relocates to new date
  - Delete: Card count decreases by one
- Console logs show `[MOVE_MEAL]` (for Part A) and `[DELETE_MEAL]` (for Part B) per `SPEC.md`
- Test completes within 60 seconds

**Why this is critical**: This test verifies the replacement for drag-and-drop functionality. The button-based UI with explicit actions (Move via date picker, Delete via confirmation) is easier to test, more reliable, and provides better user feedback than gesture-based drag-and-drop. State management correctness (meals actually moving between days, proper deletion) is the core requirement.

---
