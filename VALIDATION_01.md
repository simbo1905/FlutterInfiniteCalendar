### Test 1: Trivial Test - Confirms Setup
**Objective**: Verify the automation environment works and the application renders dynamic content.

**Priority**: **CRITICAL** - Must pass before any other testing

**Steps**:
1. Launch the application via Appium
2. Wait for the calendar view to fully render
3. Wait for mock meal data to load dynamically (this is async, not immediate)
4. Count the total number of meal cards visible on screen
5. Log visual state verification

**Expected Results**:
- Application launches without crashes
- Appium successfully connects to the Flutter app
- Test waits successfully for dynamic content (cards) to render
- At least one meal card is counted (per `SPEC.md` initial data requirements)
- Visual state is logged showing the rendered calendar with cards
- Test completes within 30 seconds

**Why this is critical**: If this test fails, the Appium setup, Flutter integration, or app initialization is broken. There's no point testing drag-and-drop if basic rendering doesn't work.

---

