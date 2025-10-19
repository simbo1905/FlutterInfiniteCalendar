// Test01-1 Debugging Tests
// 
// These tests were written to diagnose and verify the fix for the issue
// reported in Test01-1.md: Reset button not visible in initial state.
//
// Root Cause:
// The Reset button was placed in WeekSection widget, only rendering for week.index == 0.
// In tests, the CustomScrollView positioned at week -1 initially, and auto-scroll
// to week 0 didn't work reliably, so Reset button never appeared.
//
// Fix Applied:
// Moved Reset button to SliverAppBar actions per SPEC.md Section 2.1 which states:
// "Reset Button: Located below the 'Save' button" (in the header).
//
// Implementation:
// - demo/01/lib/features/calendar/meal_calendar_screen.dart:
//   - Added Reset TextButton.icon to SliverAppBar actions (lines 95-106)
//   - Added Key('resetButton') for test accessibility (line 98)
//   - Added Tooltip for accessibility (lines 95-96)
//   - Added explicit foregroundColor for visibility (lines 102-104)
//
// - demo/01/lib/features/calendar/widgets/week_section.dart:
//   - Removed onResetPressed parameter (removed from constructor)
//   - Simplified header layout from Row to Column (lines 25-48)
//   - Removed conditional Reset button rendering logic
//
// Call Site Verification:
// Verified only one call site exists in meal_calendar_screen.dart (line 112-117)
// Updated to remove onResetPressed argument.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner_demo/app.dart';

void main() {
  group('Test01-1 Debugging: Reset Button Visibility', () {
    testWidgets('Reset button appears immediately without scrolling', (tester) async {
      await tester.pumpWidget(const MealPlannerApp());
      await tester.pumpAndSettle();

      // The fix: Reset button now in app bar, always visible
      final resetButton = find.byKey(const Key('resetButton'));
      expect(resetButton, findsOneWidget, 
        reason: 'Reset button should be visible in app bar header');
      
      final resetIcon = find.byIcon(Icons.restore);
      expect(resetIcon, findsOneWidget,
        reason: 'Reset icon should be present');
      
      final resetText = find.text('Reset');
      expect(resetText, findsOneWidget,
        reason: 'Reset text label should be present');
    });

    testWidgets('Save button also has proper visibility', (tester) async {
      await tester.pumpWidget(const MealPlannerApp());
      await tester.pumpAndSettle();

      final saveButton = find.byKey(const Key('saveButton'));
      expect(saveButton, findsOneWidget,
        reason: 'Save button should be visible in app bar header');
      
      final saveText = find.text('Save');
      expect(saveText, findsOneWidget,
        reason: 'Save text should be present');
    });

    testWidgets('Both buttons remain visible after scrolling', (tester) async {
      await tester.pumpWidget(const MealPlannerApp());
      await tester.pumpAndSettle();

      // Scroll down
      final scrollView = find.byType(CustomScrollView);
      await tester.drag(scrollView.first, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Buttons should still be visible (SliverAppBar is pinned)
      expect(find.byKey(const Key('saveButton')), findsOneWidget);
      expect(find.byKey(const Key('resetButton')), findsOneWidget);
      
      // Scroll up
      await tester.drag(scrollView.first, const Offset(0, 300));
      await tester.pumpAndSettle();

      // Still visible
      expect(find.byKey(const Key('saveButton')), findsOneWidget);
      expect(find.byKey(const Key('resetButton')), findsOneWidget);
    });

    testWidgets('Week sections no longer have Reset button', (tester) async {
      await tester.pumpWidget(const MealPlannerApp());
      await tester.pumpAndSettle();

      // Should only find ONE Reset text (in header), not multiple (in week sections)
      final resetTexts = find.text('Reset');
      expect(resetTexts.evaluate().length, equals(1),
        reason: 'Should only have one Reset button in header, not in week sections');
    });
  });
}
