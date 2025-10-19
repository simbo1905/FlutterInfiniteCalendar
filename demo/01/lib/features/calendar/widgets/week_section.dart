import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/meal_instance.dart';
import 'day_row.dart';

class WeekSection extends ConsumerWidget {
  const WeekSection({
    super.key,
    required this.week,
    required this.onAddPressed,
    required this.onMealLongPress,
  });

  final CalendarWeek week;
  final Function(DateTime) onAddPressed;
  final Function(MealInstance, DateTime) onMealLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                week.weekLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                week.formattedRange,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        ...week.days.map((day) => DayRow(
          day: day,
          onAddPressed: () => onAddPressed(day.date),
          onMealLongPress: onMealLongPress,
        )),
        const Divider(height: 1),
      ],
    );
  }
}
