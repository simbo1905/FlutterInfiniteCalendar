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

