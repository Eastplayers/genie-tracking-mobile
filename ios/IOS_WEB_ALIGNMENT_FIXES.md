# iOS Implementation Alignment with Web Script

## Overview

This document outlines the necessary changes to align the iOS implementation with the original web script structure from `examples/originalWebScript/core/tracker.ts`.

## Critical Fixes Required

### 1. Session Creation Flow (CRITICAL)

**Issue**: iOS creates session synchronously during initialization, but web creates it asynchronously in background.

**Web Reference**: `tracker.ts` lines 147-149, 179-218

**Current iOS Code** (MobileTracker.swift lines 140-150):

```swift
// Check for existing session: sessionId = apiClient.getSessionId()
var sessionId = self.apiClient?.getSessionId()

// If no sessionId: create session via apiClient.createTrackingSession()
if sessionId == nil {
    if let brandIdInt = Int(brandId) {
        sessionId = await self.apiClient?.createTrackingSession(brandIdInt)

        // If session creation failed, throw error
        if sessionId == nil {
            throw TrackerError.initializationFailed("Failed to create tracking session")
        }
    }
}
```

**Required Fix**:

```swift
// Mark as initialized immediately to allow tracking to start (web: line 136)
self.initialized = true

// Initialize background services async (web: lines 147-149)
Task {
    await initializeBackgroundServices()
}

// Create session asynchronously in background (web: lines 179-218)
Task {
    await createSessionAsync()
}

if self.config.debug {
    print("[MobileTracker] Fast initialization completed - creating session in background")
}
```

**Add new method**:

```swift
/// Create tracking session asynchronously without blocking
/// Web Reference: tracker.ts lines 179-218
private func createSessionAsync() async {
    guard let apiClient = apiClient, !brandId.isEmpty else { return }

    // Check for existing session
    var sessionId = apiClient.getSessionId()

    if sessionId == nil {
        // Create new session in background
        if let brandIdInt = Int(brandId) {
            sessionId = await apiClient.createTrackingSession(brandIdInt)

            if config.debug {
                print("[MobileTracker] Session created asynchronously: \(sessionId != nil ? "success" : "failed")")
            }

            // Flush any pending events now that session exists
            if sessionId != nil && !pendingTrackCalls.isEmpty {
                await flushPendingTrackCalls()
                if config.debug {
                    print("[MobileTracker] Flushed pending track calls after session creation")
                }
            }
        }
    }
}
```

### 2. Track Method - Session Handling

**Issue**: iOS doesn't queue events when session is missing but tracker is initialized.

**Web Reference**: `tracker.ts` lines 299-310

**Current iOS Code** (MobileTracker.swift lines 265-271):

```swift
// Get sessionId from apiClient (web: line 299)
guard let sessionId = apiClient.getSessionId() else {
    // If no sessionId, don't queue - this shouldn't happen if initialized properly
    if config.debug {
        print("[MobileTracker] ⚠️ Missing session ID - cannot track event: \(eventName)")
    }
    return
}
```

**Required Fix**:

```swift
// Get sessionId from apiClient (web: line 299)
let sessionId = apiClient.getSessionId()

if sessionId == nil {
    // Queue the event if session is missing but tracker is initialized (web: lines 301-308)
    if pendingTrackCalls.count < MAX_PENDING_EVENTS {
        pendingTrackCalls.append((eventName, attributes, metadata))
        if config.debug {
            print("[MobileTracker] Missing session ID - queuing event: \(eventName)")
        }
    } else if config.debug {
        print("[MobileTracker] ⚠️ Event queue full - dropping event: \(eventName)")
    }
    return
}

guard let sessionId = sessionId else { return }
```

### 3. ApiClient - Clear Cookie Method

**Issue**: Missing `clearCookieByName` method that web uses for selective cookie clearing.

**Web Reference**: `api.ts` lines 107-130

**Required Addition** to ApiClient.swift:

```swift
/// Clear a specific cookie by name
/// Web Reference: api.ts lines 107-130
func clearCookieByName(_ name: String, domain: String? = nil) {
    clearCookie(name, domain: domain)
}
```

### 4. Reset Method - Parent Domain Support

**Issue**: iOS reset doesn't handle parent domain clearing like web does.

**Web Reference**: `tracker.ts` lines 463-502

**Current iOS Code** (MobileTracker.swift lines 408-442):

```swift
// Clear cookies using the storage manager through ApiClient
// Note: We need to access the storage manager, but it's private in ApiClient
// For now, we'll use the clearAllTrackingCookies method
apiClient.clearAllTrackingCookies()
```

**Required Fix**:

```swift
// Clear all tracking cookies (web: lines 469-479)
let cookiesToClear = ["session_id", "device_id", "session_email", "identify_id"]

// If all=true, also clear brand_id (web: lines 470-472)
var allCookies = cookiesToClear
if all {
    allCookies.append("brand_id")
}

// Clear each cookie individually
for cookie in allCookies {
    apiClient.clearCookieByName(cookie)
}
```

### 5. Initialization - Consent Check

**Issue**: iOS doesn't have `isTrackingAllowed()` consent check.

**Web Reference**: `tracker.ts` lines 179-182

**Required Addition** to MobileTracker.swift:

```swift
/// Check if tracking operations are allowed based on consent
/// Web Reference: tracker.ts lines 179-182
private func isTrackingAllowed() -> Bool {
    // For now, always return true
    // In future, integrate with iOS App Tracking Transparency
    return true
}
```

Then update track(), identify(), set(), and setMetadata() to check consent:

```swift
// Additional consent check for tracking (web: lines 311-316)
if !isTrackingAllowed() {
    if config.debug {
        print("[MobileTracker] Event blocked - consent not granted: \(eventName)")
    }
    return
}
```

## Minor Improvements

### 6. Debug Logging Consistency

**Issue**: Some debug messages don't match web format exactly.

**Examples to Update**:

- Change `"⚠️ Not initialized"` to `"Not initialized. Call initialize() first."` (matching web line 295)
- Change `"✅ Event tracked"` to `"Event tracked:"` (matching web line 330)
- Change `"❌ Error tracking event"` to `"Error tracking event:"` (matching web line 333)

### 7. ApiClient - Method Return Types

**Issue**: Some ApiClient methods return Bool instead of matching web's behavior.

**Web Reference**: `api.ts` lines 367-410 (updateProfile), 412-450 (setMetadata)

**Current**: Methods return `Bool`
**Should**: Methods should match web's void return (they log errors internally)

However, this is acceptable as Swift's async/await pattern benefits from return values for error handling.

## Implementation Priority

### High Priority (Must Fix):

1. ✅ Session creation flow (async background creation)
2. ✅ Track method session handling (queue events when session missing)
3. ✅ Add `clearCookieByName` method

### Medium Priority (Should Fix):

4. ✅ Reset method parent domain support
5. ✅ Add `isTrackingAllowed()` consent check

### Low Priority (Nice to Have):

6. Debug logging consistency
7. Method return type alignment (optional)

## Testing Checklist

After implementing fixes:

- [ ] Initialize SDK and verify session is created asynchronously
- [ ] Track event before session is ready - verify it's queued
- [ ] Track event after session is ready - verify it's sent immediately
- [ ] Call reset() and verify all cookies are cleared
- [ ] Call reset(all: true) and verify brand_id is also cleared
- [ ] Verify pending events are flushed after session creation
- [ ] Test with debug: true and verify log messages match web format

## Web Script Reference Mapping

| iOS File             | Web File                | Purpose            |
| -------------------- | ----------------------- | ------------------ |
| MobileTracker.swift  | tracker.ts              | Main SDK class     |
| ApiClient.swift      | utils/api.ts            | API communication  |
| TrackerConfig.swift  | core/config.ts          | Configuration      |
| StorageManager.swift | (cookie + localStorage) | Persistent storage |
| Models/\*.swift      | types/index.ts          | Data models        |

## Conclusion

The iOS implementation is **very well structured** and closely follows the web script. The main issues are:

1. Session creation should be async/background (not blocking init)
2. Events should be queued when session is missing
3. Minor method additions for cookie management

These fixes will bring iOS to 100% alignment with the web implementation's behavior.
