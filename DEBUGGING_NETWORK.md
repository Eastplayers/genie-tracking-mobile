# Debugging Network Issues in Android Example

## Changes Made

### 1. Added Network Security Configuration

- **File**: `examples/android/src/main/AndroidManifest.xml`
- **Change**: Added `android:usesCleartextTraffic="true"` to allow HTTP/HTTPS traffic
- This is required for Android 9+ (API 28+)

### 2. Enhanced Logging

Added detailed debug logging throughout the SDK to trace the issue:

- **MobileTracker.kt**: Added logs for initialization steps, session creation, and event tracking
- **ApiClient.kt**: Added logs for HTTP requests, responses, and errors
- **MainActivity.kt**: Added logs for SDK initialization

### 3. Fixed Initialization Flow and Infinite Loop

- **File**: `android/src/main/java/com/mobiletracker/MobileTracker.kt`
- **Changes**:
  - SDK now throws an error if session creation fails, preventing it from marking itself as "initialized" without a valid session
  - Added `initializationFailed` flag to prevent infinite event queueing
  - Events are discarded if initialization fails (logged once, not repeatedly)
  - Added max queue size (100 events) to prevent memory issues
  - Fixed infinite loop in `flushPendingTrackCalls()` by creating a copy before processing

## How to Debug

### Step 1: Rebuild and Install

```bash
cd examples/android
./gradlew clean assembleDebug
adb install -r build/outputs/apk/debug/android-debug.apk
```

### Step 2: Watch Logs

```bash
# Clear logs and start watching
adb logcat -c
adb logcat | grep -E "(MobileTracker|ApiClient)"
```

### Step 3: Launch App and Interact

```bash
# Start the app
adb shell am start -n com.mobiletracker.example/.MainActivity

# Then interact with the app UI to trigger events
```

## What to Look For in Logs

### Successful Flow:

```
[MobileTracker] Starting MobileTracker initialization...
[ApiClient] Starting createTrackingSession for brand: 925
[ApiClient] Device info: device_id=xxx, os=Android, type=Mobile
[ApiClient] Creating session - POST https://tracking.api.qc.founder-os.ai/api/v2/tracking-session
[ApiClient] ✅ Session creation response: {"data":{"id":"session_123"}}
[ApiClient] Extracted session ID: session_123
[ApiClient] ✅ Session ID saved to storage: session_123
[MobileTracker] ✅ Marked as initialized
[MobileTracker] Final session ID: session_123
[MobileTracker] ✅ Initialization completed successfully
```

### Failed Flow (Network Error):

```
[MobileTracker] Starting MobileTracker initialization...
[ApiClient] Starting createTrackingSession for brand: 925
[ApiClient] ❌ Exception creating tracking session: Unable to resolve host
[MobileTracker] ❌ Initialization failed: Failed to create tracking session
```

### Failed Flow (API Error):

```
[ApiClient] Creating session - POST https://...
[ApiClient] ❌ Failed to create session: HTTP 401
[ApiClient] Response body: {"error":"Invalid API key"}
```

## Common Issues

### 1. Network Connectivity

**Symptom**: "Unable to resolve host" or timeout errors
**Solution**:

- Check device/emulator has internet connection
- Try: `adb shell ping -c 3 google.com`

### 2. Invalid API Credentials

**Symptom**: HTTP 401 or 403 errors
**Solution**:

- Verify the API key in `MainActivity.kt` is correct
- Verify the brand ID is correct
- Check the API URL is correct

### 3. Infinite Loop / Repeated Logs

**Symptom**: Same error message repeating forever, logs flooding
**Solution**:

- **FIXED**: SDK now tracks initialization failure and stops queueing events
- Events are discarded with a single warning message
- No more infinite loops or memory leaks from unbounded event queues
- Look for: `⚠️ Cannot track event - initialization failed` (logged once per event, not repeatedly)

### 4. Cleartext Traffic Blocked

**Symptom**: "Cleartext HTTP traffic not permitted"
**Solution**:

- Already fixed by adding `usesCleartextTraffic="true"` to manifest
- If using HTTPS, ensure the certificate is valid

### 4. Events Queued But Not Sent

**Symptom**: Logs show "Missing session ID - queuing event"
**Solution**:

- This means initialization failed
- Check the initialization logs for the root cause
- Session must be created successfully before events can be sent

## Testing Network Requests

You can also use `adb` to monitor actual network traffic:

```bash
# Monitor all network activity
adb shell tcpdump -i any -s 0 -w - | wireshark -k -i -

# Or use Charles Proxy / mitmproxy for HTTPS inspection
```

## Quick Test Script

Run the provided test script:

```bash
cd examples/android
./test-network.sh
```

This will:

1. Build the app
2. Install it
3. Launch it
4. Show filtered logs

## Next Steps

After running the app with enhanced logging, share the logcat output and we can identify the exact issue preventing network requests.
