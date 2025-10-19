import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/meal_repository.dart';
import '../models/meal_instance.dart';
import '../models/meal_template.dart';
import '../util/app_logger.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final repo = MealRepository();
  repo.initialize(DateTime.now());
  return repo;
});

final baseDateProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

final boardControllerProvider =
    NotifierProvider<BoardController, BoardState>(BoardController.new);

final plannedMealsCountProvider = Provider<int>((ref) {
  final state = ref.watch(boardControllerProvider);
  final baseDate = ref.read(baseDateProvider);
  final today = DateTime(baseDate.year, baseDate.month, baseDate.day);
  return ref.read(mealRepositoryProvider).countFutureMeals(today);
});

class BoardController extends Notifier<BoardState> {
  late final DateTime _baseDate;

  @override
  BoardState build() {
    _baseDate = ref.read(baseDateProvider);
    
    final days = <int, CalendarDay>{};
    
    final mondayOfCurrentWeek = _startOfWeek(_baseDate);
    for (int offset = 0; offset < 28; offset++) {
      final date = mondayOfCurrentWeek.add(Duration(days: offset));
      final meals = ref.read(mealRepositoryProvider).mealsForDay(date);
      days[offset] = CalendarDay(date: date, meals: meals);
    }
    
    return BoardState(
      dayMap: days,
      savedDayMap: Map<int, CalendarDay>.from(days).map(
        (key, value) => MapEntry(key, _cloneDay(value)),
      ),
      loadingOffsets: const {},
      errorOffsets: const {},
      selectedDay: _baseDate,
    );
  }

  MealRepository get _repository => ref.read(mealRepositoryProvider);

  Future<void> loadDay({required int offset}) async {
    if (state.loadingOffsets.contains(offset) || state.dayMap.containsKey(offset)) {
      return;
    }

    try {
      state = state.copyWith(
        loadingOffsets: {...state.loadingOffsets, offset},
        errorOffsets: {...state.errorOffsets}..remove(offset),
      );

      final mondayOfCurrentWeek = _startOfWeek(_baseDate);
      final date = mondayOfCurrentWeek.add(Duration(days: offset));
      final meals = _repository.mealsForDay(date);
      
      final day = CalendarDay(date: date, meals: meals);
      final shouldUpdateSaved = !state.savedDayMap.containsKey(offset);
      state = state.insertDay(offset, day, updateSaved: shouldUpdateSaved);
    } catch (error) {
      debugPrint('Failed to load day $offset: $error');
      state = state.copyWith(errorOffsets: {...state.errorOffsets, offset});
    } finally {
      state = state.copyWith(
        loadingOffsets: {...state.loadingOffsets}..remove(offset),
      );
    }
  }

  Future<void> loadNextDays() async {
    final next = state.maxOffset + 1;
    await loadDay(offset: next);
  }

  Future<void> loadPreviousDays() async {
    if (state.minOffset <= 0) return;
    final previous = state.minOffset - 1;
    await loadDay(offset: previous);
  }

  MealInstance addMealFromTemplate({
    required DateTime day,
    required MealTemplate template,
  }) {
    final offset = _offsetForDate(day);
    final currentDay = state.dayMap[offset];
    
    final meal = _repository.addMealToDay(day: day, template: template);
    
    AppLogger.addMeal({
      'id': meal.id,
      'templateId': meal.templateId,
      'date': _dateKey(meal.date),
      'order': meal.order,
      'title': meal.title,
      'quantity': meal.quantity,
      'color': '#${meal.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'icon': meal.icon.codePoint,
    });
    
    if (currentDay == null) {
      _logPlannedMealsCount();
      return meal;
    }

    final updatedDay = CalendarDay(
      date: day,
      meals: _repository.mealsForDay(day),
    );
    state = state.insertDay(offset, updatedDay);
    _logPlannedMealsCount();
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

    final fromDayData = state.dayMap[fromOffset];
    final toDayData = state.dayMap[toOffset];
    if (fromDayData == null || toDayData == null) {
      return;
    }

    final oldOrder = meal.order;
    
    final today = DateTime(_baseDate.year, _baseDate.month, _baseDate.day);
    final fromNormalized = DateTime(fromDay.year, fromDay.month, fromDay.day);
    final toNormalized = DateTime(toDay.year, toDay.month, toDay.day);
    
    final fromIsFuture = fromNormalized.isAtSameMomentAs(today) || fromNormalized.isAfter(today);
    final toIsFuture = toNormalized.isAtSameMomentAs(today) || toNormalized.isAfter(today);
    final crossesBoundary = fromIsFuture != toIsFuture;
    
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
    
    final movedMeal = updatedToDay.meals.firstWhere((m) => m.id == meal.id);
    final newOrder = movedMeal.order;

    if (_isSameDay(fromDay, toDay)) {
      AppLogger.reorderMeal(
        mealId: meal.id,
        date: _dateKey(fromDay),
        fromOrder: oldOrder,
        toOrder: newOrder,
      );
    } else {
      AppLogger.moveMeal(
        mealId: meal.id,
        fromDate: _dateKey(fromDay),
        fromOrder: oldOrder,
        toDate: _dateKey(toDay),
        toOrder: newOrder,
      );
    }

    state = state.insertDay(fromOffset, updatedFromDay);
    state = state.insertDay(toOffset, updatedToDay);
    
    if (crossesBoundary) {
      _logPlannedMealsCount();
    }
  }

  void removeMeal({required DateTime day, required MealInstance meal}) {
    final offset = _offsetForDate(day);
    final currentDay = state.dayMap[offset];
    if (currentDay == null) {
      return;
    }
    
    _repository.removeMeal(day: day, meal: meal);
    
    AppLogger.deleteMeal(meal.id);
    
    final updatedDay = CalendarDay(
      date: day,
      meals: _repository.mealsForDay(day),
    );
    state = state.insertDay(offset, updatedDay);
    _logPlannedMealsCount();
  }

  List<MealTemplate> templates() => _repository.templates;

  void saveCurrentState() {
    _repository.saveSnapshot();
    final snapshot = _cloneDayMap(state.dayMap);
    state = state.copyWith(savedDayMap: snapshot);
  }

  void resetToSavedState() {
    if (state.savedDayMap.isEmpty) {
      return;
    }
    _repository.restoreSnapshot();
    final restored = _cloneDayMap(state.savedDayMap);
    state = state.copyWith(dayMap: restored);
    _logPlannedMealsCount();
  }

  void setSelectedDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  int _offsetForDate(DateTime date) {
    final mondayOfCurrentWeek = _startOfWeek(_baseDate);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(mondayOfCurrentWeek).inDays;
    return difference;
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

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _logPlannedMealsCount() {
    final today = DateTime(_baseDate.year, _baseDate.month, _baseDate.day);
    final count = _repository.countFutureMeals(today);
    print('updating planned meals to $count');
  }
}

class BoardState {
  BoardState({
    required Map<int, CalendarDay> dayMap,
    required Map<int, CalendarDay> savedDayMap,
    required this.loadingOffsets,
    required this.errorOffsets,
    this.selectedDay,
  }) : dayMap = SplayTreeMap<int, CalendarDay>.of(dayMap),
       savedDayMap = SplayTreeMap<int, CalendarDay>.of(savedDayMap);

  final SplayTreeMap<int, CalendarDay> dayMap;
  final SplayTreeMap<int, CalendarDay> savedDayMap;
  final Set<int> loadingOffsets;
  final Set<int> errorOffsets;
  final DateTime? selectedDay;

  List<CalendarDay> get days => dayMap.values.toList(growable: false);

  int get minOffset => dayMap.isEmpty ? 0 : dayMap.firstKey()!;

  int get maxOffset => dayMap.isEmpty ? 0 : dayMap.lastKey()!;

  bool get isLoading => loadingOffsets.isNotEmpty;

  BoardState copyWith({
    Map<int, CalendarDay>? dayMap,
    Map<int, CalendarDay>? savedDayMap,
    Set<int>? loadingOffsets,
    Set<int>? errorOffsets,
    DateTime? selectedDay,
  }) {
    return BoardState(
      dayMap: dayMap ?? this.dayMap,
      savedDayMap: savedDayMap ?? this.savedDayMap,
      loadingOffsets: loadingOffsets ?? this.loadingOffsets,
      errorOffsets: errorOffsets ?? this.errorOffsets,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }

  BoardState insertDay(int offset, CalendarDay day, {bool updateSaved = false}) {
    final updatedMap = Map<int, CalendarDay>.from(dayMap);
    updatedMap[offset] = day;
    final newSaved = updateSaved
        ? (Map<int, CalendarDay>.from(savedDayMap)
            ..[offset] = _cloneDay(day))
        : savedDayMap;
    return copyWith(dayMap: updatedMap, savedDayMap: newSaved);
  }

  factory BoardState.initial({DateTime? selectedDay}) {
    return BoardState(
      dayMap: const {},
      savedDayMap: const {},
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

CalendarDay _cloneDay(CalendarDay day) {
  return CalendarDay(
    date: day.date,
    meals: day.meals
        .map((meal) => meal.copyWith())
        .toList(growable: false),
  );
}

SplayTreeMap<int, CalendarDay> _cloneDayMap(Map<int, CalendarDay> source) {
  final map = SplayTreeMap<int, CalendarDay>();
  source.forEach((key, value) {
    map[key] = _cloneDay(value);
  });
  return map;
}
