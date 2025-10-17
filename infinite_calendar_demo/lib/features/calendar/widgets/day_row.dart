import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/calendar_controller.dart';
import '../../../models/event_entry.dart';
import '../../../theme/app_theme.dart';
import 'event_card_tile.dart';

class DayRow extends ConsumerWidget {
  const DayRow({
    super.key,
    required this.day,
    required this.onAddPressed,
    required this.onCardTapped,
  });

  final CalendarDay day;
  final ValueChanged<DateTime> onAddPressed;
  final ValueChanged<CalendarEvent> onCardTapped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasEvents = day.events.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formatDayLabel(day.date),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                _DayNumberBadge(date: day.date),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < day.events.length; index++)
                  EventCardDragTarget(
                    day: day.date,
                    insertIndex: index,
                    child: EventCardTile(
                      day: day.date,
                      event: day.events[index],
                      onTap: () => onCardTapped(day.events[index]),
                    ),
                  ),
                EventCardDragTarget(
                  day: day.date,
                  insertIndex: day.events.length,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!hasEvents)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'No entries yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => onAddPressed(day.date),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayNumberBadge extends StatelessWidget {
  const _DayNumberBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    final theme = Theme.of(context);
    final brightness = Theme.of(context).brightness;
    final backgroundColor = isToday
        ? todayIndicatorColor(brightness)
        : theme.colorScheme.surface;
    final textColor = isToday
        ? theme.colorScheme.onPrimary
        : theme.textTheme.titleLarge?.color ?? Colors.black;

    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: isToday ? backgroundColor : Colors.transparent,
        border: Border.all(
          color: isToday ? Colors.transparent : theme.dividerColor,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        formatDayNumber(date),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isToday ? Colors.white : textColor,
        ),
      ),
    );
  }
}
