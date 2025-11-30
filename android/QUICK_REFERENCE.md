# Android Implementation - Quick Reference

## ✅ Status: ALIGNED WITH WEB SCRIPT

All critical issues have been fixed. Android implementation now matches the original web script behavior, including support for custom profile fields and nested metadata.

## 🔥 Key Changes Made

### 1. Custom Profile Fields Support ✨

```kotlin
// BEFORE: Custom fields were lost
tracker.set(mapOf(
    "name" to "John",
    "custom_field" to "value"  // ❌ Lost!
))

// AFTER: Custom fields are sent
tracker.set(mapOf(
    "name" to "John",
    "custom_field" to "value",  // ✅ Sent as "extra"
    "another_custom" to 123      // ✅ Sent as "extra"
))
```

### 2. Fast Initialization ⚡

```kotlin
// BEFORE: Blocked until session created
MobileTracker.getInstance().initialize(context, "925", config)
// ❌ Waited for session creation

// AFTER: Returns immediately
MobileTracker.getInstance().initialize(context, "925", config)
// ✅ Returns immediately, session created in background
```

### 3. Event Queueing 📦

```kotlin
// BEFORE: Events dropped if no session
tracker.track("TEST")
// ❌ Event lost if session not ready

// AFTER: Events queued automatically
tracker.track("TEST")
// ✅ Event queued, sent when session ready
```

### 4. Nested Metadata 🗂️

```kotlin
// BEFORE: Nested objects converted to strings
tracker.setMetadata(mapOf(
    "preferences" to mapOf("theme" to "dark")
))
// ❌ Sent as: {"preferences": "{theme=dark}"}

// AFTER: Nested objects preserved
tracker.setMetadata(mapOf(
    "preferences" to mapOf("theme" to "dark")
))
// ✅ Sent as: {"preferences": {"theme": "dark"}}
```

### 5. Consent Framework 🔒

```kotlin
// BEFORE: No consent checking
tracker.track("TEST")
// ❌ No consent check

// AFTER: Consent checked
tracker.track("TEST")
// ✅ Checks isTrackingAllowed() before sending
```

## 📊 Alignment Matrix

| Feature         | Web | Android Before | Android After |
| --------------- | --- | -------------- | ------------- |
| Fast Init       | ✅  | ❌             | ✅            |
| Async Session   | ✅  | ❌             | ✅            |
| Event Queue     | ✅  | ❌             | ✅            |
| Extra Fields    | ✅  | ❌             | ✅            |
| Nested Metadata | ✅  | ❌             | ✅            |
| Consent         | ✅  | ❌             | ✅            |

## 🎯 What This Means

### For Developers:

- ✅ Faster app startup (non-blocking init)
- ✅ No lost events (automatic queueing)
- ✅ Send any custom profile fields
- ✅ Complex metadata structures supported
- ✅ Better error handling

### For Users:

- ✅ Faster app launch
- ✅ More reliable tracking
- ✅ Better privacy controls (consent)

### For Business:

- ✅ Complete data capture
- ✅ No missing custom fields
- ✅ Rich metadata support

## 📝 Files Changed

1. **`android/src/main/java/com/mobiletracker/MobileTracker.kt`**

   - Added `createSessionAsync()` method
   - Added `isTrackingAllowed()` method
   - Updated `track()` to queue events
   - Updated `identify()`, `set()`, `setMetadata()` with consent
   - Updated `updateProfile()` to extract extra fields

2. **`android/src/main/java/com/mobiletracker/ApiClient.kt`**
   - Added `extra` field to `UpdateProfileData`
   - Updated `updateProfile()` to serialize extra fields
   - Updated `setMetadata()` to handle nested objects
   - Updated profile metadata to handle nested objects

## 🧪 Quick Test

```kotlin
import com.mobiletracker.MobileTracker
import com.mobiletracker.TrackerConfig

// 1. Initialize (should return immediately)
val config = TrackerConfig(
    debug = true,
    apiUrl = "https://api.example.com",
    xApiKey = "your-key"
)

GlobalScope.launch {
    MobileTracker.getInstance().initialize(context, "925", config)
    println("✅ Initialized immediately")

    // 2. Track event (should queue if session not ready)
    MobileTracker.getInstance().track("APP_OPENED")
    println("✅ Event tracked/queued")

    // 3. Set profile with custom fields
    MobileTracker.getInstance().set(mapOf(
        "name" to "John",
        "email" to "john@example.com",
        "custom_field" to "custom_value",  // Extra field!
        "another_field" to 123              // Another extra field!
    ))
    println("✅ Profile updated with custom fields")

    // 4. Set nested metadata
    MobileTracker.getInstance().setMetadata(mapOf(
        "preferences" to mapOf(
            "theme" to "dark",
            "language" to "en"
        ),
        "tags" to listOf("premium", "beta")
    ))
    println("✅ Nested metadata set")

    // 5. Reset (selective)
    MobileTracker.getInstance().reset(all = false)
    println("✅ Session reset, brand kept")
}
```

## 📚 Documentation

- **Detailed Analysis**: `android/ANDROID_WEB_ALIGNMENT_ANALYSIS.md`
- **Applied Fixes**: `android/ANDROID_FIXES_APPLIED.md`
- **Complete Summary**: `ANDROID_ALIGNMENT_COMPLETE.md`
- **Quick Reference**: `android/QUICK_REFERENCE.md` (this file)

## ✨ Bottom Line

**Android SDK now behaves identically to the web script, with full support for:**

1. ✅ Custom profile fields (via `extra`)
2. ✅ Nested metadata structures
3. ✅ Fast, non-blocking initialization
4. ✅ Automatic event queueing
5. ✅ Consent framework

All methods, initialization flow, event handling, and storage management match the original web implementation exactly.

---

**Need more details?** Check the full documentation files listed above.

## 🆚 iOS vs Android

Both platforms now have identical fixes:

- ✅ Async session creation
- ✅ Event queueing
- ✅ Consent framework

Android-specific fixes:

- ✅ Extra profile fields support (Kotlin doesn't have spread operator)
- ✅ Nested metadata serialization (JSON handling)

**Both platforms are now 100% aligned with web!** 🎉
