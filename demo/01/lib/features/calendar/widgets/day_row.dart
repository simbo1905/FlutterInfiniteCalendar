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
    required this.onMealDelete,
  });

  final CalendarDay day;
  final VoidCallback onAddPressed;
  final Function(MealInstance) onMealDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(mealControllerProvider).selectedDay;
    final isSelected = selectedDay != null &&
        selectedDay.year == day.date.year &&
        selectedDay.month == day.date.month &&
        selectedDay.day == day.date.day;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        return data.containsKey('meal') && 
               data.containsKey('fromDay') &&
               data['meal'] is MealInstance &&
               data['fromDay'] is DateTime;
      },
      onAcceptWithDetails: (details) {
        final meal = details.data['meal'] as MealInstance;
        final fromDay = details.data['fromDay'] as DateTime;
        
        if (!_isSameDay(fromDay, day.date)) {
          ref.read(mealControllerProvider.notifier).moveMeal(
            fromDay: fromDay,
            toDay: day.date,
            meal: meal,
          );
        }
        
        ref.read(mealControllerProvider.notifier).setSelectedDay(day.date);
      },
      builder: (context, candidateData, rejectedData) {
        final isDragTarget = candidateData.isNotEmpty;
        
        return GestureDetector(
          onTap: () {
            ref.read(mealControllerProvider.notifier).setSelectedDay(day.date);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                  : isDragTarget
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
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
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      buildDefaultDragHandles: false,
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        if (oldIndex != newIndex && oldIndex < day.meals.length) {
                          final meal = day.meals[oldIndex];
                          ref.read(mealControllerProvider.notifier).moveMeal(
                            fromDay: day.date,
                            toDay: day.date,
                            meal: meal,
                            insertIndex: newIndex,
                          );
                        }
                      },
                      itemCount: day.meals.length + 1,
                      itemBuilder: (context, index) {
                        if (index == day.meals.length) {
                          return Padding(
                            key: const ValueKey('add_card'),
                            padding: const EdgeInsets.only(left: 8),
                            child: AddMealCard(onTap: onAddPressed),
                          );
                        }

                        final meal = day.meals[index];
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(meal.id),
                          index: index,
                          child: LongPressDraggable<Map<String, dynamic>>(
                            data: {
                              'meal': meal,
                              'fromDay': day.date,
                            },
                            delay: const Duration(milliseconds: 500),
                            feedback: Material(
                              color: Colors.transparent,
                              child: Transform.scale(
                                scale: 1.1,
                                child: Opacity(
                                  opacity: 0.8,
                                  child: MealCard(
                                    meal: meal,
                                    onDelete: () {},
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: MealCard(
                                meal: meal,
                                onDelete: () {},
                              ),
                            ),
                            child: MealCard(
                              meal: meal,
                              onDelete: () => onMealDelete(meal),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
