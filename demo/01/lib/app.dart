import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'theme/app_theme.dart';
import 'features/calendar/meal_calendar_screen.dart';

class MealPlannerApp extends StatefulWidget {
  const MealPlannerApp({
    super.key,
    this.overrides = const [],
  });

  final List<Override> overrides;

  @override
  State<MealPlannerApp> createState() => _MealPlannerAppState();
}

class _MealPlannerAppState extends State<MealPlannerApp> {
  @override
  void initState() {
    super.initState();
    developer.log('FLUTTER_APP_STARTED', name: 'lifecycle');
  }

  @override
  Widget build(BuildContext context) {
    developer.log('FLUTTER_APP_BUILDING', name: 'lifecycle');
    return ProviderScope(
      overrides: widget.overrides,
      child: MaterialApp(
        title: 'Meal Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        home: const MealCalendarScreen(),
      ),
    );
  }
}
