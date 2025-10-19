export const config = {
    runner: 'local',
    specs: [`./tests/${process.env.DEMO}/**/*.test.js`],
    maxInstances: 1,
    
    hostname: '127.0.0.1',
    port: 4723,
    path: '/',
    
    capabilities: [{
        platformName: 'Android',
        'appium:automationName': 'FlutterIntegration',
        'appium:deviceName': 'Android Emulator',
        'appium:app': '/Users/Shared/FlutterInfiniteCalendar/automation/../demo/01/build/app/outputs/flutter-apk/app-debug.apk',
        
        // ✅ THESE WORK TOGETHER - DON'T CHANGE INDIVIDUALLY
        'appium:noReset': false,              // DO reset app data between sessions
        'appium:fullReset': false,            // DON'T uninstall app
        'appium:skipUninstall': true,         // DON'T uninstall after session
        'appium:skipServerInstallation': true, // DON'T reinstall Appium server helpers
        
        // Timeouts
        'appium:newCommandTimeout': 300,
        'appium:adbExecTimeout': 60000,
        'appium:androidInstallTimeout': 90000,
        'appium:appWaitDuration': 90000,
    }],
    
    logLevel: 'info',
    bail: 0,
    waitforTimeout: 30000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,
    
    framework: 'mocha',
    reporters: ['spec'],
    
    mochaOpts: {
        ui: 'bdd',
        timeout: 120000
    }
}