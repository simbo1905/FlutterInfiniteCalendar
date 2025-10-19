import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final runId = 'ios_${timestamp}';
  
  // Ensure .tmp directory exists
  final logDir = Directory('.tmp')..createSync(recursive: true);

  print('🚀 Starting integration test driver for iOS platform');
  print('📁 Run ID: $runId');

  final result = await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      // Screenshots removed from testing approach - no processing
      return true; // Return true to indicate screenshot was handled
    },
  );

  // Log test results
  final logFile = File('.tmp/${runId}_results.log');
  await logFile.writeAsString('Test completed\n');
  print('🪵 [RESULTS] Test results logged to: ${logFile.path}');
}