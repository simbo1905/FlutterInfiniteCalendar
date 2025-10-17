import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner_demo/app.dart';

void main() {
  testWidgets('app loads and shows title', (tester) async {
    await tester.pumpWidget(const MealPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Meal Planner'), findsOneWidget);
  });

  testWidgets('app shows current week on load', (tester) async {
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
}
