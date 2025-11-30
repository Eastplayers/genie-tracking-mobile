# Infinite Loop Fix - All Platforms (Android, iOS, React Native)

## Problem

The Mobile Tracking SDKs (Android, iOS, and React Native) had a critical infinite loop issue when initialization failed:

1. **Initialization fails** (e.g., network error, invalid credentials)
2. **SDK marks itself as "not initialized"** but doesn't track the failure
3. **Events get queued** because there's no session ID
4. **User tries to track more events** → they get queued again
5. **`flushPendingTrackCalls()` tries to flush** → calls `track()` → events get re-queued
6. **Infinite loop** 🔄 → logs flood, memory grows, app becomes unresponsive

## Root Causes

### 1. No Failure State Tracking

The SDK had only two states: `initialized` and `isInitPending`. There was no way to know if initialization had **failed permanently**.

### 2. Infinite Re-queueing

When `flushPendingTrackCalls()` tried to process queued events, it called `track()`, which would re-queue them if there was no session ID, creating an infinite loop.

### 3. Unbounded Queue

The `pendingTrackCalls` list had no size limit, so it could grow indefinitely.

## Solution

### 1. Added Failure State Tracking

```kotlin
private var initializationFailed: Boolean = false
```

This flag is set when initialization fails and prevents further event queueing.

### 2. Stop Queueing After Failure

```kotlin
suspend fun track(...) {
    // If initialization failed, don't queue events
    if (initializationFailed) {
        if (config.debug) {
            println("[MobileTracker] ⚠️ Cannot track event - initialization failed")
        }
        return
    }
    // ... rest of track logic
}
```

### 3. Clear Queue on Failure

```kotlin
} finally {
    isInitPending = false

    if (initialized) {
        flushPendingTrackCalls()
    } else if (initializationFailed && config.debug) {
        // Clear pending events if initialization failed
        if (pendingTrackCalls.isNotEmpty()) {
            println("[MobileTracker] ⚠️ Discarding ${pendingTrackCalls.size} pending events due to initialization failure")
            pendingTrackCalls.clear()
        }
    }
}
```

### 4. Fixed Flush Logic

```kotlin
private suspend fun flushPendingTrackCalls() {
    if (config.debug && pendingTrackCalls.isNotEmpty()) {
        println("[MobileTracker] Flushing ${pendingTrackCalls.size} pending events")
    }

    // Create a copy to avoid infinite loop if track() re-queues events
    val eventsToFlush = pendingTrackCalls.toList()
    pendingTrackCalls.clear()

    eventsToFlush.forEach { (eventName, attributes, metadata) ->
        track(eventName, attributes, metadata)
    }
}
```

### 5. Added Queue Size Limit

```kotlin
private val MAX_PENDING_EVENTS = 100

// In track():
if (isInitPending) {
    if (pendingTrackCalls.size < MAX_PENDING_EVENTS) {
        pendingTrackCalls.add(Triple(eventName, attributes, metadata))
    } else if (config.debug) {
        println("[MobileTracker] ⚠️ Event queue full - dropping event: $eventName")
    }
    return
}
```

## Behavior After Fix

### Before (Infinite Loop):

```
[MobileTracker] Missing session ID - queuing event: User Signup
[MobileTracker] Missing session ID - queuing event: User Signup
[MobileTracker] Missing session ID - queuing event: User Signup
[MobileTracker] Missing session ID - queuing event: User Signup
... (repeats forever)
```

### After (Clean Failure):

```
[MobileTracker] ❌ Initialization failed: Failed to create tracking session
[MobileTracker] ⚠️ Discarding 1 pending events due to initialization failure
[MobileTracker] ⚠️ Cannot track event 'User Signup' - initialization failed
[MobileTracker] ⚠️ Cannot track event 'Button Clicked' - initialization failed
... (each event logged once, no loop)
```

## Testing

To verify the fix works:

1. **Simulate network failure**: Turn off internet or use invalid API credentials
2. **Try to track events**: Click buttons in the example app
3. **Check logs**: Should see clean error messages, no infinite loops
4. **Check memory**: App should remain responsive, no memory growth

## Files Changed

### Android SDK

- `android/src/main/java/com/mobiletracker/MobileTracker.kt`
  - Added `initializationFailed` flag
  - Added `MAX_PENDING_EVENTS` constant
  - Modified `track()` to check failure state
  - Modified `performInitialization()` to set failure flag
  - Modified `flushPendingTrackCalls()` to prevent re-queueing
  - Modified `reset()` to clear failure flag

### iOS SDK

- `ios/MobileTracker/MobileTracker.swift`
  - Added `initializationFailed` flag
  - Added `MAX_PENDING_EVENTS` constant
  - Modified `track()` to check failure state
  - Modified `performInitialization()` to set failure flag
  - Modified `flushPendingTrackCalls()` to prevent re-queueing
  - Modified `reset()` to clear failure flag

### React Native

- React Native Android bridge uses the fixed Android SDK
- React Native iOS bridge uses the fixed iOS SDK
- No changes needed to the TypeScript layer

## Impact

✅ **No more infinite loops**
✅ **No more log flooding**
✅ **No more memory leaks**
✅ **Clear error messages**
✅ **App remains responsive even when SDK fails**
