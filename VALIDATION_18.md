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

