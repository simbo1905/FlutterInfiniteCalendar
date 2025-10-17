import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:infinite_calendar_demo/data/mock_calendar_repository.dart';
import 'package:infinite_calendar_demo/models/event_entry.dart';

void main() {
  group('MockCalendarRepository', () {
    test('replayMutations tolerates duplicate adds and stray deletes', () {
      final now = DateTime(2025, 10, 16, 9);
      final repository = MockCalendarRepository(now: now, clock: () => now);
      const isoDate = '2025-10-16';
      final snapshot = CalendarEvent(
        id: 'evt-1',
        title: 'Sample',
        quantity: '1.0 units',
        color: Colors.blue,
        icon: Icons.access_alarm,
      );

      final events = [
        CalendarMutationRecord(
          timestamp: now,
          eventId: snapshot.id,
          type: CalendarMutationType.add,
          isoDate: isoDate,
          snapshot: snapshot,
        ),
        CalendarMutationRecord(
          timestamp: now.add(const Duration(milliseconds: 1)),
          eventId: snapshot.id,
          type: CalendarMutationType.add,
          isoDate: isoDate,
          snapshot: snapshot,
        ),
        CalendarMutationRecord(
          timestamp: now.add(const Duration(milliseconds: 2)),
          eventId: snapshot.id,
          type: CalendarMutationType.remove,
          isoDate: isoDate,
        ),
        CalendarMutationRecord(
          timestamp: now.add(const Duration(milliseconds: 3)),
          eventId: 'missing-id',
          type: CalendarMutationType.remove,
          isoDate: isoDate,
        ),
      ];

      final replayed = repository.replayMutations(events);
      expect(replayed[isoDate]?.isEmpty ?? true, isTrue);
    });

    test('removeEventInstance ignores unknown ids', () {
      final now = DateTime(2025, 10, 16, 9);
      final repository = MockCalendarRepository(now: now, clock: () => now);
      final initialLogLength = repository.mutationLog.length;

      repository.removeEventInstance(
        day: now,
        event: CalendarEvent(
          id: 'unknown',
          title: 'Ghost entry',
          quantity: '0 units',
          color: Colors.grey,
          icon: Icons.not_listed_location,
        ),
      );

      expect(repository.mutationLog.length, initialLogLength);
    });
  });
}
