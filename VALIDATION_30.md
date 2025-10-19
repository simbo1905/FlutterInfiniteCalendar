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

