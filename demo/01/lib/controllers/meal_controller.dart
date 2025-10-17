import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/meal_repository.dart';
import '../models/meal_instance.dart';
import '../models/meal_template.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final repo = MealRepository();
  repo.initialize(DateTime.now());
  return repo;
});

final baseDateProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

final mealControllerProvider =
    NotifierProvider<MealController, CalendarState>(MealController.new);

class MealController extends Notifier<CalendarState> {
  late final DateTime _baseDate;

  @override
  CalendarState build() {
    _baseDate = ref.read(baseDateProvider);
    
    final weeks = <int, CalendarWeek>{};
    
    for (int offset = -1; offset <= 1; offset++) {
      final weekStart = _startOfWeek(_baseDate).add(Duration(days: offset * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      final days = <CalendarDay>[];
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final meals = ref.read(mealRepositoryProvider).mealsForDay(date);
        days.add(CalendarDay(date: date, meals: meals));
      }

      weeks[offset] = CalendarWeek(
        index: offset,
        start: weekStart,
        end: weekEnd,
        days: days,
      );
    }
    
    return CalendarState(
      weekMap: weeks,
      savedWeekMap: Map<int, CalendarWeek>.from(weeks).map(
        (key, value) => MapEntry(key, _cloneWeek(value)),
      ),
      loadingOffsets: const {},
      errorOffsets: const {},
      selectedDay: _baseDate,
    );
  }

  MealRepository get _repository => ref.read(mealRepositoryProvider);

  Future<void> loadWeek({required int offset}) async {
    if (state.loadingOffsets.contains(offset) || state.weekMap.containsKey(offset)) {
      return;
    }

    try {
      state = state.copyWith(
        loadingOffsets: {...state.loadingOffsets, offset},
        errorOffsets: {...state.errorOffsets}..remove(offset),
      );

      final weekStart = _startOfWeek(_baseDate).add(Duration(days: offset * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      final days = <CalendarDay>[];
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final meals = _repository.mealsForDay(date);
        days.add(CalendarDay(date: date, meals: meals));
      }

      final week = CalendarWeek(
        index: offset,
        start: weekStart,
        end: weekEnd,
        days: days,
      );

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

  MealInstance addMealFromTemplate({
    required DateTime day,
    required MealTemplate template,
  }) {
    final offset = _offsetForDate(day);
    final week = state.weekMap[offset];
    
    final meal = _repository.addMealToDay(day: day, template: template);
    
    if (week == null) {
      return meal;
    }

    final dayIndex = week.days.indexWhere((d) => _isSameDay(d.date, day));
    if (dayIndex == -1) {
      return meal;
    }

    final updatedDay = CalendarDay(
      date: day,
      meals: _repository.mealsForDay(day),
    );
    final updatedWeek = _replaceDay(week, updatedDay);
    state = state.insertWeek(updatedWeek);
    return meal;
  }

  void moveMeal({
    required DateTime fromDay,
    required DateTime toDay,
    required MealInstance meal,
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

    _repository.moveMeal(
      fromDay: fromDay,
      toDay: toDay,
      meal: meal,
      insertIndex: insertIndex,
    );

    final updatedFromDay = CalendarDay(
      date: fromDay,
      meals: _repository.mealsForDay(fromDay),
    );
    final updatedToDay = CalendarDay(
      date: toDay,
      meals: _repository.mealsForDay(toDay),
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

  void removeMeal({required DateTime day, required MealInstance meal}) {
    final offset = _offsetForDate(day);
    final week = state.weekMap[offset];
    if (week == null) {
      return;
    }

    final dayIndex = week.days.indexWhere((d) => _isSameDay(d.date, day));
    if (dayIndex == -1) {
      return;
    }
    
    _repository.removeMeal(day: day, meal: meal);
    final updatedDay = CalendarDay(
      date: day,
      meals: _repository.mealsForDay(day),
    );
    state = state.insertWeek(_replaceDay(week, updatedDay));
  }

  List<MealTemplate> templates() => _repository.templates;

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

  void setSelectedDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  int _offsetForDate(DateTime date) {
    final baseMonday = _startOfWeek(_baseDate);
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

    return CalendarWeek(
      index: week.index,
      start: week.start,
      end: week.end,
      days: updatedDays,
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
    this.selectedDay,
  }) : weekMap = SplayTreeMap<int, CalendarWeek>.of(weekMap),
       savedWeekMap = SplayTreeMap<int, CalendarWeek>.of(savedWeekMap);

  final SplayTreeMap<int, CalendarWeek> weekMap;
  final SplayTreeMap<int, CalendarWeek> savedWeekMap;
  final Set<int> loadingOffsets;
  final Set<int> errorOffsets;
  final DateTime? selectedDay;

  List<CalendarWeek> get weeks => weekMap.values.toList(growable: false);

  int get minOffset => weekMap.isEmpty ? 0 : weekMap.firstKey()!;

  int get maxOffset => weekMap.isEmpty ? 0 : weekMap.lastKey()!;

  bool get isLoading => loadingOffsets.isNotEmpty;

  CalendarState copyWith({
    Map<int, CalendarWeek>? weekMap,
    Map<int, CalendarWeek>? savedWeekMap,
    Set<int>? loadingOffsets,
    Set<int>? errorOffsets,
    DateTime? selectedDay,
  }) {
    return CalendarState(
      weekMap: weekMap ?? this.weekMap,
      savedWeekMap: savedWeekMap ?? this.savedWeekMap,
      loadingOffsets: loadingOffsets ?? this.loadingOffsets,
      errorOffsets: errorOffsets ?? this.errorOffsets,
      selectedDay: selectedDay ?? this.selectedDay,
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

  factory CalendarState.initial({DateTime? selectedDay}) {
    return CalendarState(
      weekMap: const {},
      savedWeekMap: const {},
      loadingOffsets: const {},
      errorOffsets: const {},
      selectedDay: selectedDay ?? DateTime.now(),
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
          meals: day.meals
              .map((meal) => meal.copyWith())
              .toList(growable: false),
        ),
      )
      .toList(growable: false);

  return CalendarWeek(
    index: week.index,
    start: week.start,
    end: week.end,
    days: clonedDays,
  );
}

SplayTreeMap<int, CalendarWeek> _cloneWeekMap(Map<int, CalendarWeek> source) {
  final map = SplayTreeMap<int, CalendarWeek>();
  source.forEach((key, value) {
    map[key] = _cloneWeek(value);
  });
  return map;
}
