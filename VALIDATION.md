# Validation Protocol: Infinite Scrolling Meal Planner

## Overview

This document defines the validation requirements for any implementation of the Infinite Scrolling Meal Planner as specified in `SPEC.md`. 

**Prerequisites**: Read `AGENTS.md` first to understand the project structure, monorepo layout, and automation architecture.

## Testing Approach

This protocol describes **behavioral test scenarios** that must be validated for any demo implementation. 

**Important**: The test **scenarios** below are implementation-agnostic. Each demo's actual test code will vary based on the Flutter calendar component used, but all implementations must satisfy these behavioral requirements.

---

## Critical Path Tests

**These two tests are make-or-break. If a demo cannot pass these, it is not worth pursuing further testing.**

- [Test 1: Trivial Test - Confirms Setup](VALIDATION_01.md)
- [Test 2: Trivial DnD Sanity Test](VALIDATION_02.md)

---

## Standard Test Suite

**Only proceed with these tests after Tests 1 and 2 pass reliably.** These tests validate the complete specification but are less likely to uncover showstopper issues. Each test should be as standalone as possible to facilitate independent debugging.

- [Test 3: Application Launch and Initial State](VALIDATION_03.md)
- [Test 4: Console Logging Verification](VALIDATION_04.md)
- [Test 5: Vertical Scrolling - Future Weeks](VALIDATION_05.md)
- [Test 6: Vertical Scrolling - Past Weeks](VALIDATION_06.md)
- [Test 7: Horizontal Scrolling - Meal Carousel](VALIDATION_07.md)
- [Test 8: Add Meal to Empty Day](VALIDATION_08.md)
- [Test 9: Add Meal to Populated Day](VALIDATION_09.md)
- [Test 10: Delete Meal Card with Confirmation](VALIDATION_10.md)
- [Test 11: Cancel Delete Operation](VALIDATION_11.md)
- [Test 12: Move Card Between Days (Same Week)](VALIDATION_12.md)
- [Test 13: Move Card to Empty Day](VALIDATION_13.md)
- [Test 14: Move Card to Future Week (Auto-scroll)](VALIDATION_14.md)
- [Test 15: Move Card to Past Week (Auto-scroll)](VALIDATION_15.md)
- [Test 16: Reorder Cards Within Same Day](VALIDATION_16.md)
- [Test 17: Reorder Cards - Multiple Positions](VALIDATION_17.md)
- [Test 18: Reset to Initial State](VALIDATION_18.md)
- [Test 19: Save State and Reset to Saved State](VALIDATION_19.md)
- [Test 20: Multiple Save Operations](VALIDATION_20.md)
- [Test 21: Reset Without Save](VALIDATION_21.md)
- [Test 22: Full Meal Planning Workflow](VALIDATION_22.md)
- [Test 23: Drag and Drop Error Handling](VALIDATION_23.md)

---

## Planned Meals Counter Validation

- [Test 24: Planned Meals Counter - Initial State](VALIDATION_24.md)
- [Test 25: Planned Meals Counter - Demo Data Load](VALIDATION_25.md)
- [Test 26: Planned Meals Counter - Add Operation](VALIDATION_26.md)
- [Test 27: Planned Meals Counter - Remove Operation](VALIDATION_27.md)
- [Test 28: Planned Meals Counter - Past Day Exclusion](VALIDATION_28.md)
- [Test 29: Planned Meals Counter - Reset to Zero](VALIDATION_29.md)
- [Test 30: Planned Meals Counter - Move Between Days](VALIDATION_30.md)
- [Test 31: Planned Meals Counter - Save and Reset](VALIDATION_31.md)

---

## Grading Criteria

Tests are evaluated on a pass/fail basis. Final grade is calculated as:

- **A (95-100% pass)**: All tests pass, polished UX, no bugs
- **B (80-94% pass)**: Core functionality works, minor visual or interaction issues
- **C (60-79% pass)**: Core features functional but with significant bugs
- **D (40-59% pass)**: Major features broken or incomplete
- **F (<40% pass)**: Application unusable or fails to launch

**CRITICAL tests** (must pass to continue any testing):
- Test 1: Trivial Test - Confirms Setup
- Test 2: Trivial DnD Sanity Test

**High priority tests** (must pass for C or higher):
- Test 3: Application Launch and Initial State
- Test 8: Add Meal to Empty Day
- Test 10: Delete Meal Card
- Test 12: Move Card Between Days
- Test 16: Reorder Cards Within Same Day
- Test 19: Save and Reset

**Standard tests** (must pass for B or higher):
- All remaining Tests 4-23

**Note**: If Tests 1 and 2 fail, **stop testing immediately**. The demo is not viable and further debugging would waste time. Focus on getting the critical path working first.