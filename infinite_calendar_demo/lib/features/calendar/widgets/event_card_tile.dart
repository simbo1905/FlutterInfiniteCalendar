import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/calendar_controller.dart';
import '../../../models/event_entry.dart';

class EventCardTile extends ConsumerWidget {
  const EventCardTile({
    super.key,
    required this.day,
    required this.event,
    required this.onTap,
  });

  final DateTime day;
  final CalendarEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseCard = _CardContent(event: event);
    final availableWidth = (MediaQuery.sizeOf(context).width - 96)
        .clamp(240.0, 520.0)
        .toDouble();

    final wrappedCard = GestureDetector(onTap: onTap, child: baseCard);

    return LongPressDraggable<_DragIntent>(
      data: _DragIntent(day: day, event: event),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: availableWidth,
            maxWidth: availableWidth,
            minHeight: 64,
          ),
          child: _CardContent(event: event, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: wrappedCard),
      child: wrappedCard,
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.event, this.isDragging = false});

  final CalendarEvent event;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDragging)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        event.icon,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.quantity,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DragIntent {
  _DragIntent({required this.day, required this.event});

  final DateTime day;
  final CalendarEvent event;
}

class EventCardDragTarget extends ConsumerWidget {
  const EventCardDragTarget({
    super.key,
    required this.day,
    required this.child,
    this.insertIndex,
  });

  final DateTime day;
  final Widget child;
  final int? insertIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<_DragIntent>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        ref
            .read(calendarControllerProvider.notifier)
            .moveEvent(
              fromDay: details.data.day,
              toDay: day,
              event: details.data.event,
              insertIndex: insertIndex,
            );
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  )
                : null,
          ),
          child: child,
        );
      },
    );
  }
}
