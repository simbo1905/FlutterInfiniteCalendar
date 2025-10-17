import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:infinite_calendar_demo/controllers/calendar_controller.dart';
import 'package:infinite_calendar_demo/data/mock_calendar_repository.dart';

void main() {
  group('CalendarController', () {
    late ProviderContainer container;
    late DateTime fixedToday;

    setUp(() {
      fixedToday = DateTime(2024, 10, 15);
      container = ProviderContainer(
        overrides: [
          mockCalendarRepositoryProvider.overrideWithValue(
            MockCalendarRepository(now: fixedToday),
          ),
          todayProvider.overrideWithValue(fixedToday),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads initial weeks around today', () async {
      final notifier = container.read(calendarControllerProvider.notifier);
      await notifier.loadInitialWeeks();
      final state = container.read(calendarControllerProvider);

      expect(state.weeks.length, 3);
      expect(state.weeks.first.days.length, 7);
    });

    test('addEvent appends and removeEvent deletes', () async {
      final notifier = container.read(calendarControllerProvider.notifier);
      await notifier.loadInitialWeeks();
      final state = container.read(calendarControllerProvider);
      final targetWeek = state.weeks.first;
      final targetDay = targetWeek.days.first.date;
      final template = notifier.templates().first;

      final added = notifier.addEventFromTemplate(
        day: targetDay,
        template: template,
      );
      var refreshed = container.read(calendarControllerProvider);
      final dayModel = refreshed.weeks
          .firstWhere((w) => w.index == targetWeek.index)
          .days
          .firstWhere(
            (d) =>
                d.date.year == targetDay.year &&
                d.date.month == targetDay.month &&
                d.date.day == targetDay.day,
          );

      expect(dayModel.events.any((event) => event.id == added.id), isTrue);

      notifier.removeEvent(day: targetDay, event: added);
      refreshed = container.read(calendarControllerProvider);
      final clearedDay = refreshed.weeks
          .firstWhere((w) => w.index == targetWeek.index)
          .days
          .firstWhere(
            (d) =>
                d.date.year == targetDay.year &&
                d.date.month == targetDay.month &&
                d.date.day == targetDay.day,
          );

      expect(clearedDay.events.any((event) => event.id == added.id), isFalse);
    });

    test('loadNextWeek extends the calendar forward', () async {
      final notifier = container.read(calendarControllerProvider.notifier);
      await notifier.loadInitialWeeks();
      final initialCount = container
          .read(calendarControllerProvider)
          .weeks
          .length;

      await notifier.loadNextWeek();
      final updatedCount = container
          .read(calendarControllerProvider)
          .weeks
          .length;

      expect(updatedCount, greaterThan(initialCount));
    });

    test('loadPreviousWeek extends the calendar backward', () async {
      final notifier = container.read(calendarControllerProvider.notifier);
      await notifier.loadInitialWeeks();
      final initialMinOffset = container
          .read(calendarControllerProvider)
          .minOffset;

      await notifier.loadPreviousWeek();
      final updatedMinOffset = container
          .read(calendarControllerProvider)
          .minOffset;

      expect(updatedMinOffset, lessThan(initialMinOffset));
    });

    test('resetToSavedState reverts unsaved changes', () async {
      final notifier = container.read(calendarControllerProvider.notifier);
      await notifier.loadInitialWeeks();

      final state = container.read(calendarControllerProvider);
      final targetWeek = state.weeks.first;
      final targetDay = targetWeek.days.first.date;
      final template = notifier.templates().first;

      final added = notifier.addEventFromTemplate(
        day: targetDay,
        template: template,
      );
      notifier.resetToSavedState();

      final refreshed = container.read(calendarControllerProvider);
      final dayModel = refreshed.weeks
          .firstWhere((w) => w.index == targetWeek.index)
          .days
          .firstWhere(
            (d) =>
                d.date.year == targetDay.year &&
                d.date.month == targetDay.month &&
                d.date.day == targetDay.day,
          );

      expect(dayModel.events.any((event) => event.id == added.id), isFalse);
    });

    test('saveCurrentState sets new baseline for reset', () async {
      final notifier = container.read(calendarControllerProvider.notifier);
      await notifier.loadInitialWeeks();

      final state = container.read(calendarControllerProvider);
      final targetWeek = state.weeks.first;
      final targetDay = targetWeek.days.first.date;
      final template = notifier.templates().first;

      final firstAddition = notifier.addEventFromTemplate(
        day: targetDay,
        template: template,
      );
      notifier.saveCurrentState();

      final templates = notifier.templates();
      final secondTemplate = templates[(1) % templates.length];
      final secondAddition = notifier.addEventFromTemplate(
        day: targetDay,
        template: secondTemplate,
      );

      notifier.resetToSavedState();

      final refreshed = container.read(calendarControllerProvider);
      final dayModel = refreshed.weeks
          .firstWhere((w) => w.index == targetWeek.index)
          .days
          .firstWhere(
            (d) =>
                d.date.year == targetDay.year &&
                d.date.month == targetDay.month &&
                d.date.day == targetDay.day,
          );

      expect(
        dayModel.events.map((event) => event.id),
        contains(firstAddition.id),
      );
      expect(
        dayModel.events.map((event) => event.id),
        isNot(contains(secondAddition.id)),
      );
    });

    test('moveEvent reorders across days', () async {
      final notifier = container.read(calendarControllerProvider.notifier);
      await notifier.loadInitialWeeks();
      final state = container.read(calendarControllerProvider);
      final firstWeek = state.weeks.first;
      final fromDay = firstWeek.days.first.date;
      final toDay = firstWeek.days[1].date;
      final template = notifier.templates().first;
      final added = notifier.addEventFromTemplate(
        day: fromDay,
        template: template,
      );

      notifier.moveEvent(fromDay: fromDay, toDay: toDay, event: added);
      final refreshed = container.read(calendarControllerProvider);

      final destinationDay = refreshed.weeks
          .firstWhere((w) => w.index == firstWeek.index)
          .days
          .firstWhere(
            (d) =>
                d.date.year == toDay.year &&
                d.date.month == toDay.month &&
                d.date.day == toDay.day,
          );

      expect(destinationDay.events.map((e) => e.id), contains(added.id));
    });
  });
}
