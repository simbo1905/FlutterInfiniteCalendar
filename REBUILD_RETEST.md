# Complete Manual Rebuild Steps

# 1. Uninstall the app from device
adb uninstall com.example.meal_planner_demo

# 2. Navigate to the demo app folder
cd ./demo/01

# 3. Clean Flutter build artifacts
flutter clean

# 4. Get Flutter dependencies
flutter pub get

# 5. Build the debug APK
flutter build apk --debug

# 6. Verify the APK was created
ls -lh build/app/outputs/flutter-apk/app-debug.apk

# 7. Navigate back to automation folder
cd ../../automation

# 8. Run the test (will install fresh APK)
DEMO=01 ANDROID_HOME=$HOME/Library/Android/sdk npx wdio run ./wdio.conf.js
