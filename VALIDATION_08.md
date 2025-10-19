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

