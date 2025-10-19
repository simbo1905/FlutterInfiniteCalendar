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

