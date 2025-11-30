# Android Implementation - Web Script Alignment Analysis

## Overview

Comprehensive review of Android implementation against the original web script (`examples/originalWebScript/core/tracker.ts` and `examples/originalWebScript/utils/api.ts`).

## 🔍 Critical Issues Found

### 1. ❌ CRITICAL: Missing `extra` Field in updateProfile

**File**: `android/src/main/java/com/mobiletracker/ApiClient.kt` lines 530-600

**Problem**: Android's `updateProfile()` doesn't handle extra/unknown fields that aren't in the predefined `UpdateProfileData` structure.

**Web Reference**: `utils/api.ts` lines 367-410

```typescript
// Web extracts extra fields with spread operator
const {
  name,
  phone,
  gender,
  business_domain,
  metadata,
  email,
  source,
  birthday,
  ...extra
} = data

// Web includes extra in payload
body: JSON.stringify({
  email,
  name,
  phone,
  gender,
  business_domain,
  extra, // ← MISSING IN ANDROID
  birthday,
  metadata,
  brand_id: brandId,
  source,
  user_id,
  session_id,
})
```

**Android Current Code**:

```kotlin
// Android only sends predefined fields
val payload = buildJsonObject {
    data.email?.let { put("email", JsonPrimitive(it)) }
    data.name?.let { put("name", JsonPrimitive(it)) }
    data.phone?.let { put("phone", JsonPrimitive(it)) }
    // ... other predefined fields
    // ❌ NO SUPPORT FOR EXTRA FIELDS
}
```

**Impact**:

- ❌ Custom profile fields are lost
- ❌ Cannot send arbitrary profile data
- ❌ Breaks compatibility with web behavior

**Required Fix**:

```kotlin
// Change UpdateProfileData to accept extra fields
data class UpdateProfileData(
    val name: String? = null,
    val phone: String? = null,
    val gender: String? = null,
    val business_domain: String? = null,
    val metadata: Map<String, Any>? = null,
    val email: String? = null,
    val source: String? = null,
    val birthday: String? = null,
    val user_id: String? = null,
    val extra: Map<String, Any>? = null  // ← ADD THIS
)

// Update updateProfile to include extra fields
val payload = buildJsonObject {
    data.email?.let { put("email", JsonPrimitive(it)) }
    data.name?.let { put("name", JsonPrimitive(it)) }
    // ... other fields

    // Add extra fields
    data.extra?.forEach { (key, value) ->
        when (value) {
            is String -> put(key, JsonPrimitive(value))
            is Number -> put(key, JsonPrimitive(value))
            is Boolean -> put(key, JsonPrimitive(value))
            else -> put(key, JsonPrimitive(value.toString()))
        }
    }
}
```

### 2. ❌ CRITICAL: Async Session Creation Missing

**File**: `android/src/main/java/com/mobiletracker/MobileTracker.kt` lines 140-165

**Problem**: Android creates session synchronously during initialization, blocking the init process.

**Web Reference**: `tracker.ts` lines 136, 147-149, 184-218

**Web Behavior**:

```typescript
// Mark as initialized immediately
this.initialized = true

// Initialize background services without blocking
setTimeout(() => {
  this.initializeBackgroundServices()
}, 0)

// Create session asynchronously
private async createSessionAsync(): Promise<void> {
  // Check for existing session
  let sessionId = this.apiClient.getSessionId()

  if (!sessionId) {
    // Create new session in background
    sessionId = await this.apiClient.createTrackingSession(...)

    // Flush pending events
    if (sessionId && this.pendingTrackCalls.length > 0) {
      await this.flushPendingTrackCalls()
    }
  }
}
```

**Android Current Code**:

```kotlin
// ❌ Creates session synchronously, blocking init
if (sessionId == null) {
    sessionId = this.apiClient?.createTrackingSession(brandId.toInt())

    if (sessionId == null) {
        throw IllegalStateException("Failed to create tracking session")
    }
}

// Mark as initialized AFTER session creation
initialized = true
```

**Impact**:

- ❌ Slow initialization (blocks on network call)
- ❌ Cannot track events until session created
- ❌ Doesn't match web's fast initialization pattern

**Required Fix**:

```kotlin
// Mark as initialized immediately (web: line 136)
initialized = true

if (this.config.debug) {
    println("[MobileTracker] Fast initialization completed - creating session in background")
}

// Initialize background services async (web: lines 147-149)
withContext(Dispatchers.Main) {
    setupPageViewTracking()
}

// Create session asynchronously in background (web: lines 184-218)
CoroutineScope(Dispatchers.IO).launch {
    createSessionAsync()
}

// Add new method
private suspend fun createSessionAsync() {
    val apiClient = apiClient ?: return

    // Check for existing session
    var sessionId = apiClient.getSessionId()

    if (sessionId == null) {
        // Create new session in background
        sessionId = apiClient.createTrackingSession(brandId.toInt())

        if (config.debug) {
            println("[MobileTracker] Session created asynchronously: ${sessionId != null}")
        }

        // Flush pending events
        if (sessionId != null && pendingTrackCalls.isNotEmpty()) {
            flushPendingTrackCalls()
            if (config.debug) {
                println("[MobileTracker] Flushed pending track calls after session creation")
            }
        }
    }
}
```

### 3. ❌ CRITICAL: Event Queueing When Session Missing

**File**: `android/src/main/java/com/mobiletracker/MobileTracker.kt` lines 280-295

**Problem**: Android doesn't queue events when session is missing but tracker is initialized.

**Web Reference**: `tracker.ts` lines 302-309

**Web Behavior**:

```typescript
if (!sessionId) {
  // Queue the event if session is missing but tracker is initialized
  this.pendingTrackCalls.push([eventName, attributes, metadata])
  if (this.config.debug) {
    console.warn('[FounderOS] Missing session ID - queuing event:', eventName)
  }
  return
}
```

**Android Current Code**:

```kotlin
// ❌ Drops events instead of queuing
if (sessionId == null) {
    if (config.debug) {
        println("[MobileTracker] ⚠️ Missing session ID - cannot track event: $eventName")
    }
    return  // ← Event is lost!
}
```

**Impact**:

- ❌ Events lost during session creation
- ❌ No automatic replay after session ready
- ❌ Doesn't match web's queueing behavior

**Required Fix**:

```kotlin
// Get sessionId from apiClient (web: line 299)
val sessionId = apiClient?.getSessionId()

if (sessionId == null) {
    // Queue the event if session is missing but tracker is initialized (web: lines 302-309)
    if (pendingTrackCalls.size < MAX_PENDING_EVENTS) {
        pendingTrackCalls.add(Triple(eventName, attributes, metadata))
        if (config.debug) {
            println("[MobileTracker] Missing session ID - queuing event: $eventName")
        }
    } else if (config.debug) {
        println("[MobileTracker] ⚠️ Event queue full - dropping event: $eventName")
    }
    return
}
```

### 4. ⚠️ MEDIUM: Missing Consent Framework

**File**: `android/src/main/java/com/mobiletracker/MobileTracker.kt`

**Problem**: Android doesn't have `isTrackingAllowed()` consent checking.

**Web Reference**: `tracker.ts` lines 179-182, 311-316, 356-362, 389-395, 434-440

**Required Addition**:

```kotlin
/**
 * Check if tracking operations are allowed based on consent
 * Web Reference: tracker.ts lines 179-182
 */
private fun isTrackingAllowed(): Boolean {
    // For now, always return true
    // In future, integrate with Android privacy APIs
    return true
}
```

Then add consent checks to:

- `track()` - before sending events
- `identify()` - before sending user data
- `set()` - before updating profile
- `setMetadata()` - before sending metadata

### 5. ⚠️ MEDIUM: Missing `clearCookieByName` Public Method

**File**: `android/src/main/java/com/mobiletracker/ApiClient.kt`

**Problem**: `clearCookieByName` exists but isn't used properly in reset().

**Web Reference**: `api.ts` lines 107-130, `tracker.ts` lines 473-477

**Current Android**:

```kotlin
// reset() in MobileTracker.kt
cookiesToClear.forEach { cookie ->
    storage.remove(cookie)  // ← Direct storage access
}
```

**Should be**:

```kotlin
// reset() should use ApiClient method
cookiesToClear.forEach { cookie ->
    apiClient.clearCookieByName(cookie)
}
```

### 6. ⚠️ MEDIUM: Metadata Serialization Issue

**File**: `android/src/main/java/com/mobiletracker/ApiClient.kt` lines 650-680

**Problem**: Metadata serialization doesn't handle nested objects properly.

**Current Code**:

```kotlin
put("metadata", buildJsonObject {
    metadata.forEach { (key, value) ->
        when (value) {
            is String -> put(key, JsonPrimitive(value))
            is Number -> put(key, JsonPrimitive(value))
            is Boolean -> put(key, JsonPrimitive(value))
            else -> put(key, JsonPrimitive(value.toString()))  // ← Converts objects to string!
        }
    }
})
```

**Issue**: Nested objects/maps are converted to strings instead of being serialized as JSON objects.

**Required Fix**:

```kotlin
put("metadata", buildJsonObject {
    metadata.forEach { (key, value) ->
        when (value) {
            is String -> put(key, JsonPrimitive(value))
            is Number -> put(key, JsonPrimitive(value))
            is Boolean -> put(key, JsonPrimitive(value))
            is Map<*, *> -> put(key, buildJsonObject {
                value.forEach { (k, v) ->
                    when (v) {
                        is String -> put(k.toString(), JsonPrimitive(v))
                        is Number -> put(k.toString(), JsonPrimitive(v))
                        is Boolean -> put(k.toString(), JsonPrimitive(v))
                        else -> put(k.toString(), JsonPrimitive(v.toString()))
                    }
                }
            })
            is List<*> -> put(key, buildJsonArray {
                value.forEach { item ->
                    when (item) {
                        is String -> add(JsonPrimitive(item))
                        is Number -> add(JsonPrimitive(item))
                        is Boolean -> add(JsonPrimitive(item))
                        else -> add(JsonPrimitive(item.toString()))
                    }
                }
            })
            else -> put(key, JsonPrimitive(value.toString()))
        }
    }
})
```

## 📊 Comparison Matrix

| Feature              | Web Script                | Android Current       | Status     |
| -------------------- | ------------------------- | --------------------- | ---------- |
| Fast initialization  | ✅ Async                  | ❌ Sync (blocking)    | ❌ BROKEN  |
| Session creation     | ✅ Background             | ❌ Blocking init      | ❌ BROKEN  |
| Event queueing       | ✅ Queues when no session | ❌ Drops events       | ❌ BROKEN  |
| Extra profile fields | ✅ Supports `extra`       | ❌ Only predefined    | ❌ BROKEN  |
| Consent checking     | ✅ Implemented            | ❌ Missing            | ⚠️ MISSING |
| Metadata nesting     | ✅ Nested objects         | ⚠️ Converts to string | ⚠️ PARTIAL |
| Cookie management    | ✅ Selective clearing     | ✅ Implemented        | ✅ OK      |
| Debug logging        | ✅ Consistent             | ✅ Consistent         | ✅ OK      |

## 🎯 Priority Fixes

### High Priority (MUST FIX):

1. ❌ Add `extra` field support in `updateProfile()`
2. ❌ Make session creation async (non-blocking init)
3. ❌ Queue events when session missing

### Medium Priority (SHOULD FIX):

4. ⚠️ Add `isTrackingAllowed()` consent framework
5. ⚠️ Fix metadata nested object serialization
6. ⚠️ Use `clearCookieByName()` in reset()

### Low Priority (NICE TO HAVE):

7. Debug logging format consistency
8. Add more detailed error messages

## 🧪 Testing Checklist

After implementing fixes:

- [ ] Initialize SDK and verify it returns immediately
- [ ] Track event before session ready - verify it's queued
- [ ] Track event after session ready - verify it's sent
- [ ] Call `set()` with extra fields - verify they're sent
- [ ] Call `setMetadata()` with nested objects - verify structure preserved
- [ ] Call `reset()` and verify cookies cleared properly
- [ ] Test with debug: true and verify log messages

## 📝 Implementation Notes

### UpdateProfileData Changes:

```kotlin
// BEFORE
data class UpdateProfileData(
    val name: String? = null,
    val phone: String? = null,
    // ... predefined fields only
)

// AFTER
data class UpdateProfileData(
    val name: String? = null,
    val phone: String? = null,
    // ... predefined fields
    val extra: Map<String, Any>? = null  // ← ADD THIS
)
```

### MobileTracker.kt Changes:

```kotlin
// Change updateProfile() to accept Map<String, Any> and extract extra fields
private suspend fun updateProfile(data: Map<String, Any>) {
    // Extract known fields
    val knownFields = setOf("name", "phone", "gender", "business_domain",
                            "metadata", "email", "source", "birthday", "user_id")

    // Extract extra fields
    val extra = data.filterKeys { it !in knownFields }

    // Create UpdateProfileData with extra
    val profileData = UpdateProfileData(
        name = data["name"] as? String,
        phone = data["phone"] as? String,
        // ... other fields
        extra = extra.takeIf { it.isNotEmpty() }
    )

    apiClient?.updateProfile(profileData, brandId)
}
```

## 🔗 Web Script Reference Mapping

| Android File      | Web File                | Purpose           |
| ----------------- | ----------------------- | ----------------- |
| MobileTracker.kt  | tracker.ts              | Main SDK class    |
| ApiClient.kt      | utils/api.ts            | API communication |
| TrackerConfig     | core/config.ts          | Configuration     |
| StorageManager.kt | (cookie + localStorage) | Storage           |
| UpdateProfileData | types/index.ts          | Data models       |

## ✨ Conclusion

Android implementation has **3 critical issues** that break compatibility with web:

1. **Missing `extra` field support** - Custom profile fields are lost
2. **Synchronous session creation** - Blocks initialization
3. **No event queueing** - Events lost during session creation

These must be fixed to achieve parity with the web implementation.

**Current Alignment**: ~70%  
**Target Alignment**: 100%

After fixes, Android will match web behavior exactly.
