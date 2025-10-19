### Test 16: Reorder Cards Within Same Day
**Objective**: Verify horizontal drag-and-drop reordering.

**Note**: This repeats Test 2 Part B but as a standalone test for debugging app behavior.

**Steps**:
1. Find a day with at least 2 meal cards
2. Note initial order
3. Log "before" state
4. Drag first card to right past second card
5. Release to drop
6. Wait for UI update
7. Log "after" state

**Expected Results**:
- Card follows drag gesture horizontally
- After drop, cards are reordered
- New order persists
- `[TIMESTAMP] [INFO] [REORDER_MEAL]` log shows old and new order indices

---

