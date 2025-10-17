import 'package:flutter/material.dart';
import '../../../models/event_entry.dart';
import 'day_row.dart';

class WeekSection extends StatelessWidget {
  const WeekSection({
    super.key,
    required this.week,
    required this.onAddPressed,
    required this.onResetPressed,
    required this.onCardTapped,
  });

  final CalendarWeek week;
  final ValueChanged<DateTime> onAddPressed;
  final VoidCallback onResetPressed;
  final void Function(DateTime day, CalendarEvent event) onCardTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekLabel = week.formattedRange;
    final weekNumber = _formatWeekNumber(week.start);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'WEEK $weekNumber',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          week.totalLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onResetPressed,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset'),
              ),
            ],
          ),
        ),
        Container(
          color: theme.colorScheme.surface,
          child: Column(
            children: week.days
                .map(
                  (day) => DayRow(
                    day: day,
                    onAddPressed: onAddPressed,
                    onCardTapped: (event) => onCardTapped(day.date, event),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  int _formatWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(firstDayOfYear).inDays;
    return (days / 7).floor() + 1;
  }
}
