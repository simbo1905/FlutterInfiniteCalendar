import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';
import 'screenshot_handler.dart';

Future<void> main() async {
  final platform = Platform.environment['TEST_PLATFORM'] ?? 'ios';
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final runId = '${platform}_${timestamp}';
  
  // Ensure .tmp directory exists
  final logDir = Directory('.tmp')..createSync(recursive: true);

  print('🚀 Starting integration test driver for platform: $platform');
  print('📁 Run ID: $runId');

  // Create platform-specific screenshot handler
  final screenshotHandler = createScreenshotHandler(platform);
  
  final result = await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      // Use platform-specific handler
      await screenshotHandler.takeScreenshot(name);
      return true; // Always return true to indicate screenshot was handled
    },
  );

  // Log test results
  final logFile = File('.tmp/${runId}_results.log');
  await logFile.writeAsString('Test completed\n');
  print('🪵 [RESULTS] Test results logged to: ${logFile.path}');
}