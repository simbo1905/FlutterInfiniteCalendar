import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_entry.dart';
import '../models/event_template.dart';
import '../util/time_ordered_uuid_generator.dart';

enum CalendarMutationType { add, remove }

class CalendarMutationRecord implements Comparable<CalendarMutationRecord> {
  CalendarMutationRecord({
    required this.timestamp,
    required this.eventId,
    required this.type,
    required this.isoDate,
    this.snapshot,
  });

  final DateTime timestamp;
  final String eventId;
  final CalendarMutationType type;
  final String isoDate;
  final CalendarEvent? snapshot;

  @override
  int compareTo(CalendarMutationRecord other) {
    final comparison = timestamp.compareTo(other.timestamp);
    if (comparison != 0) {
      return comparison;
    }
    return eventId.compareTo(other.eventId);
  }
}

class MockCalendarRepository {
  MockCalendarRepository({DateTime? now, DateTime Function()? clock})
    : _seedNow = now ?? DateTime.now(),
      _clock = clock ?? DateTime.now,
      _uuidGenerator = TimeOrderedUuidGenerator() {
    _templates = _buildTemplates();
  }

  final DateTime _seedNow;
  final DateTime Function() _clock;
  final TimeOrderedUuidGenerator _uuidGenerator;
  late final List<EventTemplate> _templates;

  final SplayTreeMap<String, List<CalendarEvent>> _currentEvents =
      SplayTreeMap<String, List<CalendarEvent>>();
  final SplayTreeMap<String, List<CalendarEvent>> _savedSnapshot =
      SplayTreeMap<String, List<CalendarEvent>>();
  final List<CalendarMutationRecord> _mutationLog = <CalendarMutationRecord>[];

  Future<CalendarWeek> loadWeek({required int offsetFromToday}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final baseMonday = _startOfWeek(_seedNow);
    final weekStart = baseMonday.add(Duration(days: offsetFromToday * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    _seedWeekIfNeeded(offsetFromToday, weekStart);

    final days = <CalendarDay>[];
    for (var index = 0; index < 7; index++) {
      final date = weekStart.add(Duration(days: index));
      days.add(
        CalendarDay(
          date: date,
          events: List<CalendarEvent>.from(eventsForDay(date)),
        ),
      );
    }

    return CalendarWeek(
      index: offsetFromToday,
      start: weekStart,
      end: weekEnd,
      days: days,
      totalLabel: _computeTotalLabel(days),
    );
  }

  List<EventTemplate> get templates => List.unmodifiable(_templates);

  List<EventTemplate> searchTemplates(String query) {
    if (query.trim().isEmpty) {
      return templates;
    }
    final lower = query.trim().toLowerCase();
    return _templates
        .where((template) => template.title.toLowerCase().contains(lower))
        .toList(growable: false);
  }

  CalendarEvent addEventToDay({
    required DateTime day,
    required EventTemplate template,
    int? insertIndex,
  }) {
    final event = _createEventInstance(template);
    _upsertEvent(
      isoDate: _isoFor(day),
      event: event,
      insertIndex: insertIndex,
      updateSavedIfAbsent: false,
    );
    return event;
  }

  void moveEventInstance({
    required DateTime fromDay,
    required DateTime toDay,
    required CalendarEvent event,
    int? insertIndex,
  }) {
    final fromIso = _isoFor(fromDay);
    final toIso = _isoFor(toDay);

    if (fromIso == toIso) {
      _upsertEvent(
        isoDate: toIso,
        event: event,
        insertIndex: insertIndex,
        updateSavedIfAbsent: false,
      );
      return;
    }

    _removeEvent(fromIso, event.id);
    _upsertEvent(
      isoDate: toIso,
      event: event,
      insertIndex: insertIndex,
      updateSavedIfAbsent: false,
    );
  }

  void removeEventInstance({
    required DateTime day,
    required CalendarEvent event,
  }) {
    _removeEvent(_isoFor(day), event.id);
  }

  List<CalendarEvent> eventsForDay(DateTime day) {
    final iso = _isoFor(day);
    final existing = _currentEvents[iso];
    if (existing == null) {
      return const <CalendarEvent>[];
    }
    return existing.map((event) => event).toList(growable: false);
  }

  void saveSnapshot() {
    _savedSnapshot
      ..clear()
      ..addAll(_cloneGraph(_currentEvents));
  }

  void restoreSnapshot() {
    _currentEvents
      ..clear()
      ..addAll(_cloneGraph(_savedSnapshot));
  }

  Map<String, List<CalendarEvent>> snapshotCurrent() {
    return _cloneGraph(_currentEvents);
  }

  List<CalendarMutationRecord> get mutationLog {
    final copy = List<CalendarMutationRecord>.from(_mutationLog)..sort();
    return List.unmodifiable(copy);
  }

  Map<String, List<CalendarEvent>> replayMutations(
    Iterable<CalendarMutationRecord> mutations,
  ) {
    final map = SplayTreeMap<String, List<CalendarEvent>>();
    final sorted = mutations.toList()..sort();
    for (final record in sorted) {
      final bucket = map.putIfAbsent(record.isoDate, () => <CalendarEvent>[]);
      switch (record.type) {
        case CalendarMutationType.add:
          if (record.snapshot != null) {
            bucket.removeWhere((event) => event.id == record.eventId);
            _insertIntoList(bucket, record.snapshot!, insertIndex: null);
          }
        case CalendarMutationType.remove:
          bucket.removeWhere((event) => event.id == record.eventId);
      }
    }
    return map.map((key, value) => MapEntry(key, List.of(value)));
  }

  CalendarEvent _createEventInstance(EventTemplate template) {
    return CalendarEvent(
      id: _uuidGenerator.generate(),
      title: template.title,
      quantity: template.quantity,
      color: template.color,
      icon: template.icon,
    );
  }

  void _seedWeekIfNeeded(int offsetFromToday, DateTime weekStart) {
    final shouldPrefill = offsetFromToday >= 0 && offsetFromToday <= 1;
    if (!shouldPrefill) {
      return;
    }

    final rng = Random(
      _seedNow.millisecondsSinceEpoch ~/ 1000 + offsetFromToday * 17,
    );

    var seededCount = 0;
    for (var index = 0; index < 7; index++) {
      final date = weekStart.add(Duration(days: index));
      final iso = _isoFor(date);
      final existing = _currentEvents[iso];
      if (existing != null && existing.isNotEmpty) {
        seededCount += existing.length;
        continue;
      }

      final countForDay = rng.nextInt(4);
      if (countForDay == 0) {
        _currentEvents.putIfAbsent(iso, () => <CalendarEvent>[]);
        continue;
      }

      for (var i = 0; i < countForDay; i++) {
        final template = _templates[rng.nextInt(_templates.length)];
        final event = _createEventInstance(template);
        _upsertEvent(
          isoDate: iso,
          event: event,
          insertIndex: null,
          updateSavedIfAbsent: true,
          recordTimestamp: _seedNow.add(Duration(milliseconds: seededCount)),
        );
        seededCount++;
      }
    }

    if (seededCount < 3) {
      var remaining = 3 - seededCount;
      final allDates = List<DateTime>.generate(
        7,
        (index) => weekStart.add(Duration(days: index)),
      );
      while (remaining > 0) {
        final date = allDates[rng.nextInt(allDates.length)];
        final template = _templates[rng.nextInt(_templates.length)];
        final event = _createEventInstance(template);
        _upsertEvent(
          isoDate: _isoFor(date),
          event: event,
          insertIndex: null,
          updateSavedIfAbsent: true,
          recordTimestamp: _seedNow.add(Duration(milliseconds: seededCount)),
        );
        remaining--;
        seededCount++;
      }
    }
  }

  void _upsertEvent({
    required String isoDate,
    required CalendarEvent event,
    int? insertIndex,
    bool updateSavedIfAbsent = false,
    DateTime? recordTimestamp,
  }) {
    final bucket = _currentEvents.putIfAbsent(isoDate, () => <CalendarEvent>[]);
    bucket.removeWhere((candidate) => candidate.id == event.id);
    _insertIntoList(bucket, event, insertIndex: insertIndex);
    _logMutation(
      CalendarMutationRecord(
        timestamp: recordTimestamp ?? _clock(),
        eventId: event.id,
        type: CalendarMutationType.add,
        isoDate: isoDate,
        snapshot: event,
      ),
    );

    if (updateSavedIfAbsent) {
      final saved = _savedSnapshot.putIfAbsent(
        isoDate,
        () => <CalendarEvent>[],
      );
      final exists = saved.any((candidate) => candidate.id == event.id);
      if (!exists) {
        _insertIntoList(saved, event.copyWith(), insertIndex: insertIndex);
      }
    }
  }

  void _removeEvent(String isoDate, String eventId) {
    final bucket = _currentEvents[isoDate];
    if (bucket == null) {
      return;
    }
    final before = bucket.length;
    bucket.removeWhere((event) => event.id == eventId);
    if (before != bucket.length) {
      _logMutation(
        CalendarMutationRecord(
          timestamp: _clock(),
          eventId: eventId,
          type: CalendarMutationType.remove,
          isoDate: isoDate,
          snapshot: null,
        ),
      );
    }
  }

  void _logMutation(CalendarMutationRecord record) {
    _mutationLog.add(record);
  }

  static void _insertIntoList(
    List<CalendarEvent> list,
    CalendarEvent event, {
    int? insertIndex,
  }) {
    final index =
        insertIndex != null && insertIndex >= 0 && insertIndex <= list.length
        ? insertIndex
        : list.length;
    list.insert(index, event);
  }

  static String _isoFor(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _computeTotalLabel(List<CalendarDay> days) {
    final total = days.fold<double>(0, (sum, day) {
      final dayTotal = day.events.fold<double>(0, (inner, event) {
        final numeric = double.tryParse(event.quantity.split(' ').first) ?? 0;
        return inner + numeric;
      });
      return sum + dayTotal;
    });
    return total == 0 ? 'Total: —' : 'Total: ${total.toStringAsFixed(1)} units';
  }

  Map<String, List<CalendarEvent>> _cloneGraph(
    SplayTreeMap<String, List<CalendarEvent>> source,
  ) {
    final clone = SplayTreeMap<String, List<CalendarEvent>>();
    source.forEach((key, value) {
      clone[key] = value.map((event) => event.copyWith()).toList();
    });
    return clone;
  }

  static DateTime _startOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: dayOfWeek - DateTime.monday));
  }

  List<EventTemplate> _buildTemplates() {
    return List<EventTemplate>.generate(_titles.length, (index) {
      return EventTemplate(
        title: _titles[index],
        quantity: _quantitySamples[index % _quantitySamples.length],
        color: _stripeColors[index % _stripeColors.length],
        icon: _icons[index % _icons.length],
      );
    });
  }
}

const _stripeColors = <Color>[
  Color(0xFF22C55E),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
];

const _icons = <IconData>[
  Icons.schedule_rounded,
  Icons.auto_graph_rounded,
  Icons.layers_rounded,
  Icons.track_changes_rounded,
  Icons.workspace_premium_rounded,
];

const _titles = <String>[
  'Planning Session',
  'Creative Sprint',
  'Strategy Review',
  'Momentum Push',
  'Exploration Block',
  'Calibration Loop',
  'Iteration Window',
];

const _quantitySamples = <String>[
  '1.0 units',
  '2.4 units',
  '3.2 units',
  '45 min',
  '60 min',
  '90 min',
  '200 kcal',
];
