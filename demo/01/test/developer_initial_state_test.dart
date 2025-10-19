import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner_demo/app.dart';

void main() {
  group('VALIDATION Phase 4 – Visual & Layout (Step 4.1)', () {
    testWidgets('[Step 4.1] App bar shows Meal Planner title and Save action', (tester) async {
      // VALIDATION Step 4.1: Header layout requires Save button and title placement.
      await tester.pumpWidget(const MealPlannerApp());
      await tester.pumpAndSettle();

      expect(find.text('Meal Planner'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('VALIDATION Phase 3 – Setup & Initial Verification (Step 3.5)', () {
    testWidgets('[Step 3.5] Week header and day indicators render on first load', (tester) async {
      // VALIDATION Step 3.5: Initial state must highlight the current week/day grid.
      await tester.pumpWidget(const MealPlannerApp());
      await tester.pumpAndSettle();

      final weekHeaderFinder = find.textContaining('Week');
      expect(weekHeaderFinder, findsAtLeastNWidgets(1));

      const dayAbbreviations = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      final hasVisibleDay = dayAbbreviations.any(
        (label) => find.textContaining(label).evaluate().isNotEmpty,
      );

      expect(hasVisibleDay, isTrue, reason: 'Expected at least one day label to render');
    });
  });

  group('VALIDATION Phase 4 – Visual & Layout (Step 4.1)', () {
    testWidgets('[Step 4.1] Reset action visible for active week', (tester) async {
      // VALIDATION Step 4.1: Header layout includes Reset control for the active week section.
      await tester.pumpWidget(const MealPlannerApp());
      await tester.pumpAndSettle();

      // Scroll into the current week so the first-week reset control is rendered.
      final verticalScroll = find.byWidgetPredicate(
        (widget) => widget is CustomScrollView && widget.scrollDirection == Axis.vertical,
      );
      await tester.drag(verticalScroll.first, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restore), findsOneWidget);
    });
  });
}
