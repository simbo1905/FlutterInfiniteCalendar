import 'dart:math';
import '../models/meal_template.dart';
import '../models/meal_instance.dart';
import '../util/uuid_generator.dart';
import '../util/app_logger.dart';

class MealRepository {
  MealRepository({
    Random? random,
    Map<String, List<MealInstance>>? initialState,
  }) : _random = random ?? Random(),
       _initialState = initialState?.map(
         (key, value) =>
             MapEntry(key, value.map((meal) => meal.copyWith()).toList()),
       );

  final Random _random;
  final Map<String, List<MealInstance>>? _initialState;
  final Map<String, List<MealInstance>> _workingState = {};
  final Map<String, List<MealInstance>> _persistentState = {};

  List<MealTemplate> get templates => mealTemplates;

  void initialize(DateTime today) {
    _workingState.clear();
    _persistentState.clear();

    if (_initialState != null && _initialState.isNotEmpty) {
      _initialState.forEach((key, meals) {
        _persistentState[key] = meals.map((m) => m.copyWith()).toList();
        _workingState[key] = meals.map((m) => m.copyWith()).toList();
      });
      AppLogger.initState(_serializePersistentState());
      return;
    }

    final currentWeekStart = _startOfWeek(today);

    for (int weekOffset = 0; weekOffset <= 1; weekOffset++) {
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final date = currentWeekStart.add(
          Duration(days: weekOffset * 7 + dayOffset),
        );
        final dateKey = _dateKey(date);

        final mealCount = _random.nextInt(4);
        final meals = <MealInstance>[];

        for (int i = 0; i < mealCount; i++) {
          final template = mealTemplates[_random.nextInt(mealTemplates.length)];
          meals.add(
            MealInstance(
              id: UuidGenerator.generate(),
              templateId: template.templateId,
              date: date,
              order: i,
              title: template.title,
              quantity: template.quantity,
              color: template.color,
              icon: template.icon,
            ),
          );
        }

        _persistentState[dateKey] = meals;
        _workingState[dateKey] = meals.map((m) => m.copyWith()).toList();
      }
    }

    AppLogger.initState(_serializePersistentState());
  }

  Map<String, dynamic> _serializePersistentState() {
    final serialized = <String, dynamic>{};
    _persistentState.forEach((date, meals) {
      serialized[date] = meals
          .map(
            (meal) => {
              'id': meal.id,
              'templateId': meal.templateId,
              'date': _dateKey(meal.date),
              'order': meal.order,
              'title': meal.title,
              'quantity': meal.quantity,
              'color':
                  '#${meal.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
              'icon': meal.icon.codePoint,
            },
          )
          .toList();
    });
    return serialized;
  }

  List<MealInstance> mealsForDay(DateTime day) {
    final key = _dateKey(day);
    return _workingState[key] ?? [];
  }

  MealInstance addMealToDay({
    required DateTime day,
    required MealTemplate template,
  }) {
    final key = _dateKey(day);
    final existing = _workingState[key] ?? [];
    final meal = MealInstance(
      id: UuidGenerator.generate(),
      templateId: template.templateId,
      date: day,
      order: existing.length,
      title: template.title,
      quantity: template.quantity,
      color: template.color,
      icon: template.icon,
    );
    _workingState[key] = [...existing, meal];
    return meal;
  }

  void moveMeal({
    required DateTime fromDay,
    required DateTime toDay,
    required MealInstance meal,
    int? insertIndex,
  }) {
    final fromKey = _dateKey(fromDay);
    final toKey = _dateKey(toDay);

    final fromMeals = _workingState[fromKey] ?? [];
    fromMeals.removeWhere((m) => m.id == meal.id);
    _workingState[fromKey] = _reorderMeals(fromMeals);

    final toMeals = _workingState[toKey] ?? [];
    final updatedMeal = meal.copyWith(date: toDay);

    final safeIndex = insertIndex?.clamp(0, toMeals.length);
    if (safeIndex != null) {
      toMeals.insert(safeIndex, updatedMeal);
    } else {
      toMeals.add(updatedMeal);
    }

    _workingState[toKey] = _reorderMeals(toMeals);
  }

  void removeMeal({required DateTime day, required MealInstance meal}) {
    final key = _dateKey(day);
    final meals = _workingState[key] ?? [];
    meals.removeWhere((m) => m.id == meal.id);
    _workingState[key] = _reorderMeals(meals);
  }

  void saveSnapshot() {
    _persistentState.clear();
    _workingState.forEach((key, meals) {
      _persistentState[key] = meals.map((m) => m.copyWith()).toList();
    });
  }

  void restoreSnapshot() {
    _workingState.clear();
    _persistentState.forEach((key, meals) {
      _workingState[key] = meals.map((m) => m.copyWith()).toList();
    });
  }

  int countFutureMeals(DateTime referenceDate) {
    final today = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    int count = 0;
    _workingState.forEach((dateKey, meals) {
      final mealDate = _parseDateKey(dateKey);
      if (mealDate.isAtSameMomentAs(today) || mealDate.isAfter(today)) {
        count += meals.length;
      }
    });
    return count;
  }

  DateTime _parseDateKey(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  List<MealInstance> _reorderMeals(List<MealInstance> meals) {
    final reordered = <MealInstance>[];
    for (int i = 0; i < meals.length; i++) {
      reordered.add(meals[i].copyWith(order: i));
    }
    return reordered;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(
      Duration(days: normalized.weekday - DateTime.monday),
    );
  }
}
