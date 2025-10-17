import 'package:flutter/material.dart';

class MealInstance {
  MealInstance({
    required this.id,
    required this.templateId,
    required this.date,
    required this.order,
    required this.title,
    required this.quantity,
    required this.color,
    required this.icon,
  });

  final String id;
  final String templateId;
  final DateTime date;
  final int order;
  final String title;
  final int quantity;
  final Color color;
  final IconData icon;

  MealInstance copyWith({
    String? id,
    String? templateId,
    DateTime? date,
    int? order,
    String? title,
    int? quantity,
    Color? color,
    IconData? icon,
  }) {
    return MealInstance(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      date: date ?? this.date,
      order: order ?? this.order,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

class CalendarDay {
  CalendarDay({required this.date, required this.meals});

  final DateTime date;
  final List<MealInstance> meals;

  CalendarDay copyWith({List<MealInstance>? meals}) {
    return CalendarDay(date: date, meals: meals ?? this.meals);
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
  });

  final int index;
  final DateTime start;
  final DateTime end;
  final List<CalendarDay> days;

  String get formattedRange =>
      '${start.day} ${_monthLabel(start)} - ${end.day} ${_monthLabel(end)}';

  int get weekNumber {
    final dayOfYear = start.difference(DateTime(start.year, 1, 1)).inDays;
    return (dayOfYear / 7).ceil() + 1;
  }

  String get weekLabel => 'Week $weekNumber, ${start.year}';

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
