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

