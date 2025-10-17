import 'dart:convert';
import 'dart:developer' as developer;

enum LogLevel {
  info,
  debug,
}

class AppLogger {
  static void log(LogLevel level, String action, Map<String, dynamic> details) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final levelStr = level == LogLevel.info ? 'INFO' : 'DEBUG';
    final detailsJson = jsonEncode(details);
    final message = '[$timestamp] [$levelStr] [$action] - $detailsJson';
    
    developer.log(message, name: 'MealPlanner');
  }

  static void initState(Map<String, dynamic> persistentState) {
    log(LogLevel.debug, 'INIT_STATE', {'persistentState': persistentState});
  }

  static void screenLoad(String reason) {
    log(LogLevel.info, 'SCREEN_LOAD', {'reason': reason});
  }

  static void addMeal(Map<String, dynamic> mealInstance) {
    log(LogLevel.info, 'ADD_MEAL', {'meal': mealInstance});
  }

  static void deleteMeal(String mealId) {
    log(LogLevel.info, 'DELETE_MEAL', {'mealId': mealId});
  }

  static void moveMeal({
    required String mealId,
    required String fromDate,
    required int fromOrder,
    required String toDate,
    required int toOrder,
  }) {
    log(LogLevel.info, 'MOVE_MEAL', {
      'mealId': mealId,
      'from': {'date': fromDate, 'order': fromOrder},
      'to': {'date': toDate, 'order': toOrder},
    });
  }

  static void reorderMeal({
    required String mealId,
    required String date,
    required int fromOrder,
    required int toOrder,
  }) {
    log(LogLevel.info, 'REORDER_MEAL', {
      'mealId': mealId,
      'date': date,
      'from': {'order': fromOrder},
      'to': {'order': toOrder},
    });
  }
}
