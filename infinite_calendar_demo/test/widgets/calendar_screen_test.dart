import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:infinite_calendar_demo/controllers/calendar_controller.dart';
import 'package:infinite_calendar_demo/data/mock_calendar_repository.dart';
import 'package:infinite_calendar_demo/features/calendar/calendar_screen.dart';

void main() {
  ProviderScope buildApp() {
    final fixedToday = DateTime(2024, 10, 14);
    return ProviderScope(
      overrides: [
        mockCalendarRepositoryProvider.overrideWithValue(
          MockCalendarRepository(now: fixedToday),
        ),
        todayProvider.overrideWithValue(fixedToday),
      ],
      child: const MaterialApp(home: CalendarScreen()),
    );
  }

  testWidgets('renders week headers after data load', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.textContaining('WEEK'), findsWidgets);
    expect(find.textContaining('Total:'), findsWidgets);
  });

  testWidgets('tapping Add opens bottom sheet', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    final addButton = find.text('Add').first;
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Add entry for'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
