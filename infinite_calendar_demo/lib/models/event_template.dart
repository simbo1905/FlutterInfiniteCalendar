import 'package:flutter/material.dart';

class EventTemplate {
  const EventTemplate({
    required this.title,
    required this.quantity,
    required this.color,
    required this.icon,
  });

  final String title;
  final String quantity;
  final Color color;
  final IconData icon;
}
