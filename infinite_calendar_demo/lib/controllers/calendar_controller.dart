import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mock_calendar_repository.dart';
import '../models/event_entry.dart';
import '../models/event_template.dart';

final mockCalendarRepositoryProvider = Provider<MockCalendarRepository>((ref) {
  return MockCalendarRepository();
});

final todayProvider = Provider<DateTime>((ref) => DateTime.now());

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarState>(CalendarController.new);

class CalendarController extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final initialState = CalendarState.initial();
    Future.microtask(() async {
      await loadInitialWeeks();
    });
    return initialState;
  }

  MockCalendarRepository get _repository =>
      ref.read(mockCalendarRepositoryProvider);

  Future<void> loadInitialWeeks() async {
    if (state.weeks.isNotEmpty) {
      return;
    }

    await Future.wait([
      loadWeek(offset: -1),
      loadWeek(offset: 0),
      loadWeek(offset: 1),
    ]);
  }

  Future<void> loadWeek({required int offset}) async {
    if (state.loadingOffsets.contains(offset)) {
      return;
    }

    state = state.copyWith(
      loadingOffsets: {...state.loadingOffsets, offset},
      errorOffsets: {...state.errorOffsets}..remove(offset),
    );

    try {
      final week = await _repository.loadWeek(offsetFromToday: offset);
      final shouldUpdateSaved = !state.savedWeekMap.containsKey(week.index);
      state = state.insertWeek(week, updateSaved: shouldUpdateSaved);
    } catch (error) {
      debugPrint('Failed to load week $offset: $error');
      state = state.copyWith(errorOffsets: {...state.errorOffsets, offset});
    } finally {
      state = state.copyWith(
        loadingOffsets: {...state.loadingOffsets}..remove(offset),
      );
    }
  }

  Future<void> loadNextWeek() async {
    final next = state.maxOffset + 1;
    await loadWeek(offset: next);
  }

  Future<void> loadPreviousWeek() async {
    final previous = state.minOffset - 1;
    await loadWeek(offset: previous);
  }

  CalendarEvent addEventFromTemplate({
    required DateTime day,
    required EventTemplate template,
  }) {
    final offset = _offsetForDate(day);
    final week = state.weekMap[offset];
    if (week == null) {
      return _repository.addEventToDay(day: day, template: template);
    }

    final dayIndex = week.days.indexWhere((d) => _isSameDay(d.date, day));
    if (dayIndex == -1) {
      return _repository.addEventToDay(day: day, template: template);
    }

    final event = _repository.addEventToDay(day: day, template: template);
    final updatedDay = CalendarDay(
      date: day,
      events: _repository.eventsForDay(day),
    );
    final updatedWeek = _replaceDay(week, updatedDay);
    state = state.insertWeek(updatedWeek);
    return event;
  }

  void moveEvent({
    required DateTime fromDay,
    required DateTime toDay,
    required CalendarEvent event,
    int? insertIndex,
  }) {
    final fromOffset = _offsetForDate(fromDay);
    final toOffset = _offsetForDate(toDay);

    final fromWeek = state.weekMap[fromOffset];
    final toWeek = state.weekMap[toOffset];
    if (fromWeek == null || toWeek == null) {
      return;
    }

    final fromDayIndex = fromWeek.days.indexWhere(
      (d) => _isSameDay(d.date, fromDay),
    );
    final toDayIndex = toWeek.days.indexWhere((d) => _isSameDay(d.date, toDay));
    if (fromDayIndex == -1 || toDayIndex == -1) {
      return;
    }

    _repository.moveEventInstance(
      fromDay: fromDay,
      toDay: toDay,
      event: event,
      insertIndex: insertIndex,
    );

    final updatedFromDay = CalendarDay(
      date: fromDay,
      events: _repository.eventsForDay(fromDay),
    );
    final updatedToDay = CalendarDay(
      date: toDay,
      events: _repository.eventsForDay(toDay),
    );

    if (fromOffset == toOffset) {
      final fromWeekWithSource = _replaceDay(fromWeek, updatedFromDay);
      final withDestination = _replaceDay(fromWeekWithSource, updatedToDay);
      state = state.insertWeek(withDestination);
    } else {
      final updatedFromWeek = _replaceDay(fromWeek, updatedFromDay);
      state = state.insertWeek(updatedFromWeek);
      final refreshedToWeek = state.weekMap[toOffset] ?? toWeek;
      final newToWeek = _replaceDay(refreshedToWeek, updatedToDay);
      state = state.insertWeek(newToWeek);
    }
  }

  void removeEvent({required DateTime day, required CalendarEvent event}) {
    final offset = _offsetForDate(day);
    final week = state.weekMap[offset];
    if (week == null) {
      return;
    }

    final dayIndex = week.days.indexWhere((d) => _isSameDay(d.date, day));
    if (dayIndex == -1) {
      return;
    }
    _repository.removeEventInstance(day: day, event: event);
    final updatedDay = CalendarDay(
      date: day,
      events: _repository.eventsForDay(day),
    );
    state = state.insertWeek(_replaceDay(week, updatedDay));
  }

  List<EventTemplate> templates() => _repository.templates;

  List<EventTemplate> searchTemplates(String query) =>
      _repository.searchTemplates(query);

  void saveCurrentState() {
    _repository.saveSnapshot();
    final snapshot = _cloneWeekMap(state.weekMap);
    state = state.copyWith(savedWeekMap: snapshot);
  }

  void resetToSavedState() {
    if (state.savedWeekMap.isEmpty) {
      return;
    }
    _repository.restoreSnapshot();
    final restored = _cloneWeekMap(state.savedWeekMap);
    state = state.copyWith(weekMap: restored);
  }

  int _offsetForDate(DateTime date) {
    final baseMonday = _startOfWeek(ref.read(todayProvider));
    final targetMonday = _startOfWeek(date);
    final difference = targetMonday.difference(baseMonday).inDays;
    return difference ~/ 7;
  }

  CalendarWeek _replaceDay(CalendarWeek week, CalendarDay updatedDay) {
    final updatedDays = week.days
        .map((day) {
          if (_isSameDay(day.date, updatedDay.date)) {
            return updatedDay;
          }
          return day;
        })
        .toList(growable: false);

    final total = updatedDays.fold<double>(0, (sum, day) {
      final dayTotal = day.events.fold<double>(0, (inner, event) {
        final numeric = double.tryParse(event.quantity.split(' ').first) ?? 0;
        return inner + numeric;
      });
      return sum + dayTotal;
    });

    return CalendarWeek(
      index: week.index,
      start: week.start,
      end: week.end,
      days: updatedDays,
      totalLabel: total == 0
          ? 'Total: —'
          : 'Total: ${total.toStringAsFixed(1)} units',
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(
      Duration(days: normalized.weekday - DateTime.monday),
    );
  }
}

class CalendarState {
  CalendarState({
    required Map<int, CalendarWeek> weekMap,
    required Map<int, CalendarWeek> savedWeekMap,
    required this.loadingOffsets,
    required this.errorOffsets,
  }) : weekMap = SplayTreeMap<int, CalendarWeek>.of(weekMap),
       savedWeekMap = SplayTreeMap<int, CalendarWeek>.of(savedWeekMap);

  final SplayTreeMap<int, CalendarWeek> weekMap;
  final SplayTreeMap<int, CalendarWeek> savedWeekMap;
  final Set<int> loadingOffsets;
  final Set<int> errorOffsets;

  List<CalendarWeek> get weeks => weekMap.values.toList(growable: false);

  int get minOffset => weekMap.isEmpty ? 0 : weekMap.firstKey()!;

  int get maxOffset => weekMap.isEmpty ? 0 : weekMap.lastKey()!;

  bool get isLoading => loadingOffsets.isNotEmpty;

  CalendarState copyWith({
    Map<int, CalendarWeek>? weekMap,
    Map<int, CalendarWeek>? savedWeekMap,
    Set<int>? loadingOffsets,
    Set<int>? errorOffsets,
  }) {
    return CalendarState(
      weekMap: weekMap ?? this.weekMap,
      savedWeekMap: savedWeekMap ?? this.savedWeekMap,
      loadingOffsets: loadingOffsets ?? this.loadingOffsets,
      errorOffsets: errorOffsets ?? this.errorOffsets,
    );
  }

  CalendarState insertWeek(CalendarWeek week, {bool updateSaved = false}) {
    final updatedMap = Map<int, CalendarWeek>.from(weekMap);
    updatedMap[week.index] = week;
    final newSaved = updateSaved
        ? (Map<int, CalendarWeek>.from(savedWeekMap)
            ..[week.index] = _cloneWeek(week))
        : savedWeekMap;
    return copyWith(weekMap: updatedMap, savedWeekMap: newSaved);
  }

  factory CalendarState.initial() {
    return CalendarState(
      weekMap: const {},
      savedWeekMap: const {},
      loadingOffsets: const {},
      errorOffsets: const {},
    );
  }
}

String formatDayLabel(DateTime date) {
  return DateFormat.E().format(date).toUpperCase();
}

String formatDayNumber(DateTime date) {
  return DateFormat.d().format(date);
}

CalendarWeek _cloneWeek(CalendarWeek week) {
  final clonedDays = week.days
      .map(
        (day) => CalendarDay(
          date: day.date,
          events: day.events
              .map((event) => event.copyWith())
              .toList(growable: false),
        ),
      )
      .toList(growable: false);

  return CalendarWeek(
    index: week.index,
    start: week.start,
    end: week.end,
    days: clonedDays,
    totalLabel: week.totalLabel,
  );
}

SplayTreeMap<int, CalendarWeek> _cloneWeekMap(Map<int, CalendarWeek> source) {
  final map = SplayTreeMap<int, CalendarWeek>();
  source.forEach((key, value) {
    map[key] = _cloneWeek(value);
  });
  return map;
}
