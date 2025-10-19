import 'dart:convert';
import 'dart:developer' as developer;

typedef LogListener = void Function(LogRecord record);

class LogRecord {
  LogRecord({
    required this.level,
    required this.action,
    required this.details,
    required this.message,
  });

  final LogLevel level;
  final String action;
  final Map<String, dynamic> details;
  final String message;
}

enum LogLevel {
  info,
  debug,
}

class AppLogger {
  static final List<LogListener> _listeners = [];
  static final List<LogRecord> _history = [];

  static void log(LogLevel level, String action, Map<String, dynamic> details) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final levelStr = level == LogLevel.info ? 'INFO' : 'DEBUG';
    final clonedDetails = jsonDecode(jsonEncode(details)) as Map<String, dynamic>;
    final detailsJson = jsonEncode(clonedDetails);
    final message = '[$timestamp] [$levelStr] [$action] - $detailsJson';
    
    developer.log(message, name: 'MealPlanner');
    final record = LogRecord(
      level: level,
      action: action,
      details: clonedDetails,
      message: message,
    );
    _history.add(record);
    if (_history.length > 200) {
      _history.removeAt(0);
    }
    for (final listener in _listeners) {
      listener(record);
    }
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

  static void addListener(LogListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(LogListener listener) {
    _listeners.remove(listener);
  }

  static void clearListeners() {
    _listeners.clear();
  }

  static void clearHistory() {
    _history.clear();
  }

  static List<LogRecord> get history => List.unmodifiable(_history);
}
