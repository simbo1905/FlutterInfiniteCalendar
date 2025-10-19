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

