import 'package:flutter/material.dart';

class CalendarEvent {
  CalendarEvent({
    required this.id,
    required this.title,
    required this.quantity,
    required this.color,
    required this.icon,
  });

  final String id;
  final String title;
  final String quantity;
  final Color color;
  final IconData icon;

  CalendarEvent copyWith({
    String? title,
    String? quantity,
    Color? color,
    IconData? icon,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

class CalendarDay {
  CalendarDay({required this.date, required this.events});

  final DateTime date;
  final List<CalendarEvent> events;

  CalendarDay copyWith({List<CalendarEvent>? events}) {
    return CalendarDay(date: date, events: events ?? this.events);
  }

  bool get isToday {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }
}

class CalendarWeek {
  CalendarWeek({
    required this.index,
    required this.start,
    required this.end,
    required this.days,
    required this.totalLabel,
  });

  final int index;
  final DateTime start;
  final DateTime end;
  final List<CalendarDay> days;
  final String totalLabel;

  String get formattedRange =>
      '${start.day} ${_monthLabel(start)} - ${end.day} ${_monthLabel(end)}';

  static String _monthLabel(DateTime date) {
    return _monthNames[date.month - 1];
  }
}

const _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
