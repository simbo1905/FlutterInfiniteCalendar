import 'package:flutter/material.dart';

import 'features/calendar/calendar_screen.dart';
import 'theme/app_theme.dart';

class InfiniteCalendarApp extends StatelessWidget {
  const InfiniteCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Calendar Demo',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: const CalendarScreen(),
    );
  }
}
