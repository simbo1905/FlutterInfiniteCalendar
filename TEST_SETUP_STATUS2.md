# Manual Test Debugging - Step by Step

## Current Status: Flutter Integration Server IS Working ✅

Your manual test proves:
- ✅ APK installs correctly
- ✅ App launches successfully  
- ✅ Flutter integration server starts on port 9000
- ✅ Server responds to `curl http://localhost:9000/status`

**Key log entry from your test:**
```
10-19 03:31:38.206 13056 13056 I flutter : [APPIUM FLUTTER]  Appium flutter server is listening on port 9000
```

## Issue: Appium Cannot Connect When It Runs

The problem is NOT the Flutter app - it's how Appium is trying to connect to it.

## Step-by-Step Manual Debugging

### Terminal 1: Monitor Appium Logs

```bash
cd /Users/Shared/FlutterInfiniteCalendar
tail -f .tmp/appium.log
```

Keep this running to watch Appium's port forwarding and connection attempts.

### Terminal 2: Run WebDriverIO Test Directly

```bash
# Navigate to automation directory
cd /Users/Shared/FlutterInfiniteCalendar/automation

# Set environment variables
export DEMO=01
export ANDROID_HOME="$HOME/Library/Android/sdk"

# Run WebDriverIO directly (not through mise)
npx wdio run ./wdio.conf.js
```

This will show you exactly what WebDriverIO is doing.

### Terminal 3: Monitor ADB Port Forwarding

```bash
# Watch what ports Appium forwards
watch -n 1 '$ANDROID_HOME/platform-tools/adb forward --list'
```

OR just run once:
```bash
$ANDROID_HOME/platform-tools/adb forward --list
```

### Terminal 4: Monitor App Logs (Optional)

```bash
$ANDROID_HOME/platform-tools/adb logcat | grep -i "appium\|flutter"
```

## What to Look For

### In Appium Logs (Terminal 1)

Watch for these patterns:

**Good:**
```
[ADB] Forwarding system: XXXX to device: 9000
```

**Bad:**
```
FlutterServer not reachable on port XXXXX, Retrying..
```

### In WebDriverIO Output (Terminal 2)

**Good:**
```
[0-0] RUNNING in Android...
[0-0] Session created successfully
```

**Bad:**
```
ERROR webdriver: Request failed with error code UND_ERR_HEADERS_TIMEOUT
```

### In ADB Port Forward List (Terminal 3)

**Should see:**
```
emulator-5554 tcp:XXXXX tcp:9000
```

Where XXXXX is the local port Appium uses (like 10003, 10004, etc.)

## Quick Diagnostic Commands

### 1. Check Current Port Forwards
```bash
$ANDROID_HOME/platform-tools/adb forward --list
```

### 2. Clear All Port Forwards
```bash
$ANDROID_HOME/platform-tools/adb forward --remove-all
```

### 3. Test Direct Connection to App
```bash
# Forward port manually
$ANDROID_HOME/platform-tools/adb forward tcp:9000 tcp:9000

# Launch app
$ANDROID_HOME/platform-tools/adb shell am start -n com.example.meal_planner_demo/.MainActivity

# Wait a few seconds, then test
sleep 5
curl http://localhost:9000/status
```

## Hypothesis: Port Conflict

**Possible Issue:** Appium might be trying to forward a port that's already in use, or using a different port number than expected.

### Check What Appium Actually Forwards

When you see this in Appium logs:
```
[ADB] Forwarding system: 10003 to device: 9000
```

Try connecting to that port:
```bash
curl http://localhost:10003/status
```

## Alternative: Run Appium in Foreground

Instead of using the background script, run Appium directly to see all output:

```bash
cd /Users/Shared/FlutterInfiniteCalendar
export ANDROID_HOME="$HOME/Library/Android/sdk"
npx --prefix automation appium --config ./automation/appium.config.cjs
```

Then in another terminal, run the test:
```bash
cd /Users/Shared/FlutterInfiniteCalendar/automation
export DEMO=01
export ANDROID_HOME="$HOME/Library/Android/sdk"
npx wdio run ./wdio.conf.js
```

## Collect Debug Info

If the test still fails, capture these:

```bash
# 1. Port forwards during test
$ANDROID_HOME/platform-tools/adb forward --list > /tmp/port-forwards.txt

# 2. Last 200 lines of Appium log
tail -200 /Users/Shared/FlutterInfiniteCalendar/.tmp/appium.log > /tmp/appium-debug.log

# 3. WebDriverIO output
npx wdio run ./wdio.conf.js 2>&1 | tee /tmp/wdio-debug.log

# 4. App logcat during test
$ANDROID_HOME/platform-tools/adb logcat -d | grep -i "appium\|flutter" > /tmp/app-debug.log
```

## Expected vs Actual

### Expected Flow
1. WebDriverIO requests session from Appium
2. Appium launches app with `am start`
3. Appium forwards local port (e.g., 10003) to device port 9000
4. Appium waits for server response on http://localhost:10003/status
5. Flutter app starts integration server on port 9000
6. Appium successfully connects
7. Test proceeds

### What Might Be Happening
1. ✅ WebDriverIO requests session from Appium
2. ✅ Appium launches app with `am start`
3. ❓ Appium forwards port (check which port)
4. ❌ Appium tries to connect before app is ready
5. ✅ Flutter app starts integration server (proven by manual test)
6. ❌ Appium gives up before server responds
7. ❌ Test times out

## Quick Fix to Try

The issue might be timing. Add a startup delay capability:

Edit `automation/wdio.conf.js` and add:
```javascript
'appium:appWaitDuration': 30000,  // Wait 30s for app to be ready
```

## Next Steps After Gathering Info

1. Start Appium in foreground (see output clearly)
2. Run WebDriverIO test directly
3. Watch what port Appium forwards
4. Check if that port responds: `curl http://localhost:PORT/status`
5. Compare with your manual test which uses port 9000 directly

The key difference between manual (working) and automated (failing) is likely:
- Port forwarding configuration
- Timing (Appium connecting too early)
- App launch method differences
