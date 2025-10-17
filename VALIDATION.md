# Agent Validation Protocol for Bake-off Demos

IMPORTANT: Kapture is only installed into Microsoft Edge Browser you can only use Kapture MCP with Edge Browser. 

Never sleep for more than 10s once the first screen has loaded and anything taking more than that is a FAIL. 

## 1. Introduction

This document outlines the standardized validation protocol for an AI agent to test and evaluate Flutter demo applications submitted to the "Infinite Scrolling Meal Planner" bake-off. The goal is to ensure each submission is rigorously and consistently tested against the `SPEC.md`.

The agent will follow a detailed, step-by-step procedure, documenting its findings and generating a final report with a grade for the submission.

## 2. Invocation

The validation process is initiated via a slash command:

`/validate [demo-id]`

-   **`[demo-id]`**: A two-digit number (e.g., `01`, `02`) corresponding to the demo folder located at `./demo/[demo-id]/`.

## 3. Phase 1: Setup & Initial Verification

The agent must perform these steps to set up the test environment.

-   [ ] **Step 3.1: Locate Project**
    -   Navigate to the `./demo/[demo-id]/` directory.
    -   Verify the presence of a Flutter project structure and a `README.md` file.

-   [ ] **Step 3.2: Install Dependencies**
    -   Run `flutter pub get` within the project directory.
    -   Report any errors.

-   [ ] **Step 3.3: Launch Application**
    -   Run the application using the Chrome web target: `flutter run -d chrome`.
    -   Wait for the application to fully load in the browser.

-   [ ] **Step 3.4: Initial Screenshot**
    -   Resize the browser window to simulate an "iPhone 16" resolution: **393px width x 852px height**.
    -   Take a full-page screenshot and save it as `initial_view.png`.

-   [ ] **Step 3.5: Initial State Check and Logging Verification**
    -   Verify that the calendar has opened to the current week of the current year.
    -   Verify that the current day is visually highlighted.
    -   Verify that mock meal data is present for the current and following week, as per the initial data generation rules in `SPEC.md`.
    -   **Console Log Verification:**
        -   Capture all console logs from the application start.
        -   Verify the presence and correctness of the `INIT_STATE` log, ensuring it contains the full `persistentState` as defined in `SPEC.md`.
        -   Verify the presence and correctness of the `SCREEN_LOAD` log with `"reason": "Initial Load"`.

## 4. Phase 2: Visual & Layout Validation

Compare `initial_view.png` against the reference `Screenshot.png` and the requirements in `SPEC.md`.

-   [ ] **Step 4.1: Header Layout**
    -   Check for the presence and correct placement of the "Save" and "Reset" buttons.

-   [ ] **Step 4.2: Day Row Layout**
    -   Verify the left-side date indicator format (Day of week, Date).
    -   Verify the horizontal meal carousel on the right.

-   [ ] **Step 4.3: Meal Card Styling**
    -   Check for the colored left tab, icon, title, and quantity fields.
    -   Verify the presence of the faint `[x]` delete button in the top-right corner.
    -   Assess general styling: rounded corners, shadows, and overall aesthetic match.

-   [ ] **Step 4.4: "+ Add" Card**
    -   Verify the `+ Add` card is fixed to the rightmost position of each day's carousel.
    -   Check that its styling is distinct from a regular meal card.

## 5. Phase 3: Functional Validation

**General Logging Verification:** For every action performed in this phase (add, delete, reorder, move), the agent must capture and verify the corresponding console log message as defined in `SPEC.md`. Ensure the `TIMESTAMP`, `LEVEL`, `ACTION`, and `DETAILS` match the expected output and reflect the UI changes accurately.

-   [ ] **Step 5.1: Scrolling**
    -   **Vertical:** Scroll down several screens. Does it load future weeks infinitely? Scroll up past the initial week. Does it load past weeks infinitely? Does the year number change correctly when scrolling from week 52 to 1 (and vice-versa)?
    -   **Horizontal:** On a day with multiple cards, scroll the carousel left and right. Does it function correctly?

-   [ ] **Step 5.2: Delete a Card**
    -   Click the `[x]` on an existing card.
    -   **Verify:** A confirmation dialog appears.
    -   Click "Delete".
    -   **Verify:** The card is removed from the view.

-   [ ] **Step 5.3: Add a Card**
    -   Find a day with no cards and click the `+ Add` card.
    -   **Verify:** The "Add Meal Bottom Sheet" appears, showing meal templates.
    -   Add a meal.
    -   **Verify:** The sheet closes and the new card appears on the correct day.
    -   On a day with existing cards, repeat the process.
    -   **Verify:** The new card is added to the end of the list.

-   [ ] **Step 5.4: Reorder Cards (Horizontal Drag-and-Drop)**
    -   Find a day with at least two cards.
    -   Drag the first card and drop it after the second card.
    -   **Verify:** The order of the cards in the UI is updated correctly.

-   [ ] **Step 5.5: Move Card (Vertical Drag-and-Drop)**
    -   Drag a card from its original day and drop it onto a different day in the same week.
    -   **Verify:** The card is removed from the source day and appears on the destination day.
    -   Drag a card to the bottom edge of the screen.
    -   **Verify:** The calendar auto-scrolls downwards.
    -   Drop the card on a day in a future week.
    -   **Verify:** The card is correctly moved.

## 6. Phase 4: State Management Validation (Save & Reset)

**General Logging Verification:** For every action performed in this phase (Save, Reset), the agent must capture and verify the corresponding console log message as defined in `SPEC.md`. Ensure the `TIMESTAMP`, `LEVEL`, `ACTION`, and `DETAILS` match the expected output and reflect the UI changes accurately.

This phase requires careful state checking with screenshots.

-   [ ] **Step 6.1: Test Reset Functionality**
    1.  From the initial state, move a card from Monday to Tuesday.
    2.  Take a screenshot (`reset_test_state_A.png`).
    3.  Click the "Reset" button.
    4.  **Verify:** The UI reverts to the initial state (card is back on Monday). Take a screenshot (`reset_test_state_B.png`) and compare it with `initial_view.png`.

-   [ ] **Step 6.2: Test Save and Reset Functionality**
    1.  From the initial state, move a card from Wednesday to Thursday.
    2.  Click the "Save" button.
    3.  Take a screenshot of this new saved state (`save_test_state_A.png`).
    4.  Make another change, e.g., delete a different card entirely.
    5.  Click the "Reset" button.
    6.  **Verify:** The UI reverts to the state when "Save" was pressed (the card is on Thursday), not the initial state. Take a screenshot (`save_test_state_B.png`) and confirm it matches `save_test_state_A.png`.

## 7. Phase 5: Reporting

After completing all phases, the agent must generate a `VALIDATION_REPORT.md` file in the demo's directory.

-   **Header:** Include the Demo ID and the final grade.
-   **Checklist:** Copy the checklists from this protocol (`- [ ]`) and mark each item with `[x]` for pass or `[ ]` for fail.
-   **Notes:** For any failed step, provide a detailed explanation of what went wrong, referencing screenshots where applicable.
-   **Screenshots:** List all generated screenshots (`initial_view.png`, `reset_test_state_A.png`, etc.) as evidence.
-   **Final Grade:** Assign a grade (A, B, C, D, F) based on the number of passed checks, with significant weight on core functionality (drag-drop, state management).
    -   **A:** 95-100% pass rate. Fully functional and polished.
    -   **B:** 80-94% pass rate. Mostly functional, minor visual or interaction bugs.
    -   **C:** 60-79% pass rate. Core features work, but with significant bugs.
    -   **D:** 40-59% pass rate. Major features are broken or missing.
    -   **F:** <40% pass rate. Unusable or fails to run.
