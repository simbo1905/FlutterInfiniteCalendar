import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'features/calendar/meal_calendar_screen.dart';

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Meal Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MealCalendarScreen(),
      ),
    );
  }
}
