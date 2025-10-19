import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/meal_controller.dart';
import '../../../models/meal_instance.dart';
import 'meal_card.dart';
import 'add_meal_card.dart';

class DayRow extends ConsumerWidget {
  const DayRow({
    super.key,
    required this.day,
    required this.onAddPressed,
    required this.onMealLongPress,
  });

  final CalendarDay day;
  final VoidCallback onAddPressed;
  final Function(MealInstance, DateTime) onMealLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(mealControllerProvider).selectedDay;
    final isSelected = selectedDay != null &&
        selectedDay.year == day.date.year &&
        selectedDay.month == day.date.month &&
        selectedDay.day == day.date.day;

    return GestureDetector(
      key: ValueKey('day-${_dateKey(day.date)}'),
      onTap: () {
        ref.read(mealControllerProvider.notifier).setSelectedDay(day.date);
      },
      onLongPress: () {
        // Long-press on empty area triggers add meal
        if (day.meals.isEmpty) {
          onAddPressed();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      formatDayLabel(day.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500,
                        color: day.isToday
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: day.isToday
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          formatDayNumber(day.date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: day.isToday
                                ? Colors.white
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  key: ValueKey('meal-list-${_dateKey(day.date)}'),
                  scrollDirection: Axis.horizontal,
                  itemCount: day.meals.length + 1,
                  itemBuilder: (context, index) {
                    if (index == day.meals.length) {
                      return Padding(
                        key: ValueKey('add-${_dateKey(day.date)}'),
                        padding: const EdgeInsets.only(left: 8),
                        child: AddMealCard(onTap: onAddPressed),
                      );
                    }

                    final meal = day.meals[index];
                    return MealCard(
                      key: ValueKey('meal-${meal.id}'),
                      meal: meal,
                      onLongPress: () => onMealLongPress(meal, day.date),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
