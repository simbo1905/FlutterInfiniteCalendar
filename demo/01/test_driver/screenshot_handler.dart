// Common interface for platform-specific screenshot handling
abstract class ScreenshotHandler {
  Future<void> takeScreenshot(String name);
}

// iOS implementation - noop
class IOSScreenshotHandler implements ScreenshotHandler {
  @override
  Future<void> takeScreenshot(String name) async {
    print('📸 [IOS_SCREENSHOT] Skipping screenshot "$name" (noop for iOS)');
  }
}

// Web implementation - will implement later
class WebScreenshotHandler implements ScreenshotHandler {
  @override
  Future<void> takeScreenshot(String name) async {
    // TODO: Implement web screenshot using integration test APIs
    print('📸 [WEB_SCREENSHOT] Would capture screenshot "$name" (implementation pending)');
  }
}

// Factory to create appropriate handler based on platform
ScreenshotHandler createScreenshotHandler(String platform) {
  switch (platform.toLowerCase()) {
    case 'ios':
      return IOSScreenshotHandler();
    case 'web':
      return WebScreenshotHandler();
    default:
      return IOSScreenshotHandler(); // Default to noop
  }
}