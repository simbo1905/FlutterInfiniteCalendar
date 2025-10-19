### Test 22: Full Meal Planning Workflow
**Objective**: Verify realistic workflow combining multiple operations.

**Steps**:
1. Launch app
2. Add "Oatmeal" to Monday
3. Add "Chicken Salad" to Monday
4. Reorder Monday's cards (swap positions)
5. Save the state
6. Move "Oatmeal" from Monday to Friday
7. Add "Fish and Chips" to Wednesday
8. Delete "Chicken Salad" from Monday
9. Reset

**Expected Results**:
- Each operation works correctly in sequence
- After Reset, state shows:
  - Monday has "Oatmeal" and "Chicken Salad" in swapped order (saved state)
  - Friday has no "Oatmeal" (move reverted)
  - Wednesday has no "Fish and Chips" (add reverted)
  - Monday still has "Chicken Salad" (delete reverted)

---

