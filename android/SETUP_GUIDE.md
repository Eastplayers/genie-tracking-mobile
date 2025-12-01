# Android Setup Guide

Complete integration guide for the FounderOS Mobile Tracking SDK for Android applications.

## Introduction

The FounderOS Mobile Tracking SDK provides simple, reliable event tracking with automatic context enrichment, user identification, session management, and screen tracking capabilities for Android applications. This guide will walk you through installing and integrating the SDK into your Android app.

**What you'll accomplish:**

- Install the SDK using Gradle with JitPack
- Initialize the tracker with your configuration
- Track custom events with attributes
- Identify users and update profiles
- Set session-level metadata
- Handle user logout with session reset
- Verify tracking is working correctly

**Time to complete:** 10-15 minutes

---

## Installation

### Gradle with JitPack (Recommended)

**Step 1:** Add JitPack repository to your project's `settings.gradle` (or `settings.gradle.kts`):

```gradle
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }  // Add this line
    }
}
```

**Step 2:** Add the SDK dependency to your app's `build.gradle` (or `build.gradle.kts`):

```gradle
dependencies {
    implementation("com.github.Eastplayers:genie-tracking-mobile:0.1.1")
}
```

**Step 3:** Sync your project:

```bash
./gradlew sync
```

**Post-installation:** The SDK is now available in your project and you can import `ai.founderos.mobiletracker.MobileTracker` in your Kotlin files.

---

## Quick Start

Get up and running in under 5 minutes with this minimal example:

```kotlin
import ai.founderos.mobiletracker.MobileTracker
import ai.founderos.mobiletracker.TrackerConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// In your Application class or MainActivity
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize on app launch
        CoroutineScope(Dispatchers.IO).launch {
            MobileTracker.getInstance().initialize(
                context = this@MyApplication,
                brandId = "YOUR_BRAND_ID",
                config = TrackerConfig(
                    debug = true,
                    apiUrl = null,  // Uses default production URL
                    xApiKey = "YOUR_API_KEY"
                )
            )
        }
    }
}

// Track an event
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(
        eventName = "BUTTON_CLICK",
        attributes = mapOf("button_name" to "signup")
    )
}
```

---

## Step-by-Step Setup

### Step 1: Installation

Follow the installation instructions above using Gradle with JitPack.

**Expected result:** The SDK is added to your project and you can import `MobileTracker` in your Kotlin files.

---

### Step 2: Initialize the SDK

Initialize the tracker when your app launches. The best place is in your `Application` class's `onCreate()` method.

**Create Application Class (if you don't have one):**

```kotlin
import android.app.Application
import ai.founderos.mobiletracker.MobileTracker
import ai.founderos.mobiletracker.TrackerConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize SDK on app launch
        CoroutineScope(Dispatchers.IO).launch {
            try {
                MobileTracker.getInstance().initialize(
                    context = this@MyApplication,
                    brandId = "123",  // Your brand ID
                    config = TrackerConfig(
                        debug = true,
                        apiUrl = null,  // Optional: defaults to production
                        xApiKey = "your-api-key-here"
                    )
                )
                println("✅ Tracker initialized")
            } catch (e: Exception) {
                println("❌ Tracker initialization failed: ${e.message}")
            }
        }
    }
}
```

**Register Application Class in AndroidManifest.xml:**

```xml
<application
    android:name=".MyApplication"
    android:label="@string/app_name"
    ...>
    <!-- Your activities -->
</application>
```

**Alternative: Initialize in MainActivity:**

```kotlin
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import ai.founderos.mobiletracker.MobileTracker
import ai.founderos.mobiletracker.TrackerConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize SDK
        CoroutineScope(Dispatchers.IO).launch {
            try {
                MobileTracker.getInstance().initialize(
                    context = applicationContext,
                    brandId = "123",
                    config = TrackerConfig(
                        debug = true,
                        apiUrl = null,
                        xApiKey = "your-api-key-here"
                    )
                )
                println("✅ Tracker initialized")
            } catch (e: Exception) {
                println("❌ Tracker initialization failed: ${e.message}")
            }
        }
    }
}
```

**What this does:**

- Creates a tracking session with the backend
- Initializes storage for session and device data
- Sets up automatic screen view tracking
- Prepares the SDK to queue and send events

**Configuration Parameters:**

- `brandId` (String, required): Your unique brand identifier (must be numeric)
- `debug` (Boolean, optional): Enable debug logging (default: `false`)
- `apiUrl` (String?, optional): Custom API endpoint (default: `https://tracking.api.founder-os.ai/api`)
- `xApiKey` (String?, optional): API key for authentication

**Expected result:** The SDK initializes without errors and you see a success message in Logcat.

---

### Step 3: Track Events

Track user actions and behaviors throughout your app.

**Basic Event Tracking:**

```kotlin
import ai.founderos.mobiletracker.MobileTracker
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// Simple event
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(eventName = "BUTTON_CLICK")
}

// Event with attributes
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(
        eventName = "PURCHASE_COMPLETED",
        attributes = mapOf(
            "product_id" to "prod_123",
            "amount" to 29.99,
            "currency" to "USD"
        )
    )
}
```

**Event with Metadata:**

```kotlin
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(
        eventName = "VIDEO_PLAYED",
        attributes = mapOf(
            "video_id" to "vid_456",
            "duration" to 120
        ),
        metadata = mapOf(
            "player_version" to "2.1.0",
            "quality" to "1080p"
        )
    )
}
```

**Real-World Examples:**

```kotlin
// Button click
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(
        eventName = "BUTTON_CLICK",
        attributes = mapOf("button_name" to "signup", "screen" to "home")
    )
}

// Page view (automatic, but can be manual too)
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(
        eventName = "VIEW_PAGE",
        attributes = mapOf("url" to "ProfileActivity")
    )
}

// Form submission
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(
        eventName = "FORM_SUBMITTED",
        attributes = mapOf(
            "form_name" to "contact",
            "fields_count" to 5
        )
    )
}

// Error tracking
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(
        eventName = "ERROR_OCCURRED",
        attributes = mapOf(
            "error_code" to "AUTH_001",
            "error_message" to "Invalid credentials"
        )
    )
}
```

**What this does:**

- Sends events to the backend with automatic context enrichment
- Adds device info, platform, OS version, and timestamps automatically
- Queues events if network is unavailable and retries later

**Expected result:** Events appear in your FounderOS dashboard within seconds.

---

### Step 4: Identify Users

Associate events with specific users after login or signup.

```kotlin
import ai.founderos.mobiletracker.MobileTracker
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// Basic identification
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().identify(userId = "user_12345")
}

// Identification with profile data
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().identify(
        userId = "user_12345",
        profileData = mapOf(
            "email" to "user@example.com",
            "name" to "John Doe",
            "plan" to "premium"
        )
    )
}
```

**When to call identify:**

- After successful login
- After user registration
- When user data is loaded from storage

**Example in login flow:**

```kotlin
suspend fun handleLogin(email: String, password: String) {
    try {
        val user = authService.login(email, password)

        // Identify user after successful login
        MobileTracker.getInstance().identify(
            userId = user.id,
            profileData = mapOf(
                "email" to user.email,
                "name" to user.name,
                "created_at" to user.createdAt
            )
        )

        println("✅ User identified")
    } catch (e: Exception) {
        println("❌ Login failed: ${e.message}")
    }
}
```

**What this does:**

- Links all subsequent events to this user
- Updates the user profile in the backend
- Persists user ID across app sessions

**Expected result:** Events in your dashboard show the associated user ID and profile data.

---

### Step 5: Update User Profiles

Update user profile information as it changes.

```kotlin
import ai.founderos.mobiletracker.MobileTracker
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// Update profile data
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().set(
        profileData = mapOf(
            "plan" to "enterprise",
            "company" to "Acme Corp",
            "phone" to "+1234567890"
        )
    )
}

// Update single field
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().set(
        profileData = mapOf("last_login" to System.currentTimeMillis())
    )
}
```

**Common use cases:**

```kotlin
// After subscription upgrade
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().set(
        profileData = mapOf(
            "plan" to "premium",
            "subscription_date" to System.currentTimeMillis()
        )
    )
}

// After profile edit
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().set(
        profileData = mapOf(
            "name" to updatedName,
            "phone" to updatedPhone,
            "preferences" to userPreferences
        )
    )
}
```

**What this does:**

- Updates user profile without changing user ID
- Merges new data with existing profile
- Useful for tracking user progression and changes

**Expected result:** User profile in dashboard reflects the updated information.

---

### Step 6: Set Session Metadata

Add context that applies to all events in the current session.

```kotlin
import ai.founderos.mobiletracker.MobileTracker
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// Set session-level metadata
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().setMetadata(
        metadata = mapOf(
            "app_version" to "2.1.0",
            "build_number" to "145",
            "environment" to "production"
        )
    )
}

// Add experiment/feature flag data
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().setMetadata(
        metadata = mapOf(
            "experiment_group" to "variant_b",
            "feature_new_ui" to true,
            "ab_test_id" to "test_123"
        )
    )
}
```

**When to use metadata:**

- Feature flags and A/B test assignments
- App version and build information
- Session type (guest vs authenticated)
- Environment information (staging, production)

**Example with feature flags:**

```kotlin
suspend fun setupSessionContext() {
    val packageInfo = packageManager.getPackageInfo(packageName, 0)

    MobileTracker.getInstance().setMetadata(
        metadata = mapOf(
            "app_version" to packageInfo.versionName,
            "feature_dark_mode" to sharedPreferences.getBoolean("dark_mode_enabled", false),
            "experiment_checkout_flow" to "variant_a",
            "user_segment" to "power_user"
        )
    )
}
```

**What this does:**

- Attaches metadata to all subsequent events in the session
- Useful for filtering and segmenting events in analytics
- Persists until session is reset or app is restarted

**Expected result:** All tracked events include the metadata fields in your dashboard.

---

### Step 7: Reset on Logout

Clear user data and create a new session when users log out.

```kotlin
import ai.founderos.mobiletracker.MobileTracker

// Reset user data but keep session
MobileTracker.getInstance().reset(all = false)

// Reset everything including brand ID (rare)
MobileTracker.getInstance().reset(all = true)
```

**Example in logout flow:**

```kotlin
suspend fun handleLogout() {
    // Clear user session
    authService.logout()

    // Reset tracker to clear user identification
    MobileTracker.getInstance().reset(all = false)

    println("✅ User logged out and tracker reset")

    // Navigate to login screen
    navigateToLogin()
}
```

**What `reset()` does:**

- Clears `session_id`, `device_id`, `session_email`, `identify_id`
- Creates a new tracking session
- Clears pending events
- Resets internal state

**What `reset(all = true)` does:**

- Everything above, plus clears `brand_id`
- Use only when completely reinitializing the SDK

**Expected result:** New events after reset are not associated with the previous user.

---

### Step 8: Verify Tracking

Confirm the SDK is working correctly.

**1. Enable Debug Mode:**

```kotlin
MobileTracker.getInstance().initialize(
    context = this,
    brandId = "123",
    config = TrackerConfig(
        debug = true,  // Enable debug logging
        xApiKey = "your-api-key"
    )
)
```

**2. Check Logcat:**

Look for these messages in Android Studio Logcat:

```
✅ MobileTracker initialized successfully
[MobileTracker] Session created asynchronously: success
[MobileTracker] Event tracked: BUTTON_CLICK
```

**3. Check Dashboard:**

- Log into your FounderOS dashboard
- Navigate to Events or Analytics section
- Verify events appear with correct data
- Check that user identification is working

**4. Test Event Flow:**

```kotlin
// Test complete flow
CoroutineScope(Dispatchers.IO).launch {
    // 1. Initialize
    MobileTracker.getInstance().initialize(
        context = applicationContext,
        brandId = "123",
        config = TrackerConfig(debug = true, xApiKey = "your-api-key")
    )

    // 2. Track test event
    MobileTracker.getInstance().track(
        eventName = "TEST_EVENT",
        attributes = mapOf("test" to true)
    )

    // 3. Identify test user
    MobileTracker.getInstance().identify(
        userId = "test_user_123",
        profileData = mapOf("email" to "test@example.com")
    )

    // 4. Track another event
    MobileTracker.getInstance().track(
        eventName = "TEST_EVENT_AFTER_IDENTIFY",
        attributes = mapOf("identified" to true)
    )

    println("✅ Test flow completed - check dashboard")
}
```

**Expected result:**

- Logcat shows successful initialization and event tracking
- Dashboard displays all test events
- Events after `identify()` show user association

---

## All-in-One Example

Complete integration showing all features together:

```kotlin
import android.app.Application
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import ai.founderos.mobiletracker.MobileTracker
import ai.founderos.mobiletracker.TrackerConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize on app launch
        CoroutineScope(Dispatchers.IO).launch {
            try {
                MobileTracker.getInstance().initialize(
                    context = this@MyApplication,
                    brandId = "123",
                    config = TrackerConfig(
                        debug = true,
                        apiUrl = null,  // Uses default
                        xApiKey = "your-api-key-here"
                    )
                )

                // Set session metadata
                MobileTracker.getInstance().setMetadata(
                    metadata = mapOf(
                        "app_version" to "1.0.0",
                        "environment" to "production"
                    )
                )

                println("✅ Tracker ready")
            } catch (e: Exception) {
                println("❌ Tracker failed: ${e.message}")
            }
        }
    }
}

class MainActivity : AppCompatActivity() {
    private var isLoggedIn = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Track screen view
        CoroutineScope(Dispatchers.IO).launch {
            MobileTracker.getInstance().track(
                eventName = "VIEW_PAGE",
                attributes = mapOf("screen" to "MainActivity")
            )
        }

        setupButtons()
    }

    private fun setupButtons() {
        findViewById<Button>(R.id.loginButton).setOnClickListener {
            CoroutineScope(Dispatchers.IO).launch {
                handleLogin()
            }
        }

        findViewById<Button>(R.id.purchaseButton).setOnClickListener {
            CoroutineScope(Dispatchers.IO).launch {
                handlePurchase()
            }
        }

        findViewById<Button>(R.id.updateProfileButton).setOnClickListener {
            CoroutineScope(Dispatchers.IO).launch {
                handleUpdateProfile()
            }
        }

        findViewById<Button>(R.id.logoutButton).setOnClickListener {
            handleLogout()
        }
    }

    private suspend fun handleLogin() {
        // Simulate login
        val userId = "user_12345"

        // Identify user
        MobileTracker.getInstance().identify(
            userId = userId,
            profileData = mapOf(
                "email" to "user@example.com",
                "name" to "John Doe"
            )
        )

        // Track login event
        MobileTracker.getInstance().track(
            eventName = "USER_LOGGED_IN",
            attributes = mapOf("method" to "email")
        )

        isLoggedIn = true
        runOnUiThread {
            // Update UI
        }
    }

    private suspend fun handlePurchase() {
        MobileTracker.getInstance().track(
            eventName = "PURCHASE_COMPLETED",
            attributes = mapOf(
                "product_id" to "prod_123",
                "amount" to 29.99
            )
        )
    }

    private suspend fun handleUpdateProfile() {
        MobileTracker.getInstance().set(
            profileData = mapOf(
                "plan" to "premium",
                "last_active" to System.currentTimeMillis()
            )
        )
    }

    private fun handleLogout() {
        // Reset tracker on logout
        MobileTracker.getInstance().reset(all = false)
        isLoggedIn = false

        // Update UI
    }
}
```

**What this example demonstrates:**

- ✅ SDK initialization on app launch
- ✅ Session metadata setup
- ✅ Event tracking with attributes
- ✅ User identification on login
- ✅ Profile updates
- ✅ Session reset on logout
- ✅ Screen view tracking

---

## Best Practices

### Performance

**Initialize Early:**

```kotlin
// ✅ Good: Initialize in Application class
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        CoroutineScope(Dispatchers.IO).launch {
            MobileTracker.getInstance().initialize(...)
        }
    }
}

// ❌ Bad: Don't initialize in every Activity
class MyActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        CoroutineScope(Dispatchers.IO).launch {
            MobileTracker.getInstance().initialize(...)  // Wrong!
        }
    }
}
```

**Batch Events:**

```kotlin
// ✅ Good: Track meaningful events
MobileTracker.getInstance().track(eventName = "CHECKOUT_COMPLETED")

// ❌ Bad: Don't track every tiny interaction
MobileTracker.getInstance().track(eventName = "SCROLL_MOVED")  // Too granular
```

**Use Background Coroutines:**

```kotlin
// ✅ Good: Use IO dispatcher for tracking
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(eventName = "EVENT")
}

// ❌ Bad: Don't block main thread
runBlocking {
    MobileTracker.getInstance().track(eventName = "EVENT")  // Blocks UI
}
```

### Privacy

**Respect User Consent:**

```kotlin
// Check consent before initializing
if (userHasGrantedTrackingConsent) {
    CoroutineScope(Dispatchers.IO).launch {
        MobileTracker.getInstance().initialize(...)
    }
}
```

**Don't Track PII Without Consent:**

```kotlin
// ✅ Good: Use hashed or anonymized IDs
MobileTracker.getInstance().identify(userId = "user_abc123")

// ⚠️ Careful: Only if user consented
MobileTracker.getInstance().identify(
    userId = "user_123",
    profileData = mapOf("email" to "user@example.com")  // Requires consent
)
```

**Clear Data on Logout:**

```kotlin
// Always reset on logout
fun logout() {
    MobileTracker.getInstance().reset(all = false)
    // Clear other user data...
}
```

### Event Naming

**Use Consistent Naming:**

```kotlin
// ✅ Good: SCREAMING_SNAKE_CASE
MobileTracker.getInstance().track(eventName = "BUTTON_CLICK")
MobileTracker.getInstance().track(eventName = "PURCHASE_COMPLETED")
MobileTracker.getInstance().track(eventName = "VIDEO_PLAYED")

// ❌ Bad: Inconsistent naming
MobileTracker.getInstance().track(eventName = "buttonClick")
MobileTracker.getInstance().track(eventName = "purchase-completed")
MobileTracker.getInstance().track(eventName = "Video Played")
```

**Be Descriptive:**

```kotlin
// ✅ Good: Clear and specific
MobileTracker.getInstance().track(eventName = "CHECKOUT_PAYMENT_METHOD_SELECTED")

// ❌ Bad: Too vague
MobileTracker.getInstance().track(eventName = "CLICK")
```

### Attributes vs Metadata

**Use Attributes for Event-Specific Data:**

```kotlin
// Event-specific information
MobileTracker.getInstance().track(
    eventName = "PRODUCT_VIEWED",
    attributes = mapOf(
        "product_id" to "prod_123",
        "category" to "electronics",
        "price" to 299.99
    )
)
```

**Use Metadata for Session-Wide Context:**

```kotlin
// Session-wide information
MobileTracker.getInstance().setMetadata(
    metadata = mapOf(
        "app_version" to "2.1.0",
        "user_segment" to "premium",
        "ab_test_variant" to "B"
    )
)
```

### Error Handling

**Handle Initialization Errors:**

```kotlin
CoroutineScope(Dispatchers.IO).launch {
    try {
        MobileTracker.getInstance().initialize(
            context = applicationContext,
            brandId = "123",
            config = TrackerConfig(xApiKey = "key")
        )
    } catch (e: Exception) {
        // Log error but don't crash the app
        Log.e("Tracker", "Initialization failed: ${e.message}")
        // Optionally report to error tracking service
    }
}
```

**Graceful Degradation:**

```kotlin
// SDK handles errors internally - tracking failures won't crash your app
MobileTracker.getInstance().track(eventName = "EVENT")  // Safe even if not initialized
```

---

## Troubleshooting

### SDK Not Loading

**Problem:** Import fails or SDK not found

**Solutions:**

1. **Check JitPack repository:** Ensure JitPack is added to `settings.gradle`

   ```gradle
   maven { url = uri("https://jitpack.io") }
   ```

2. **Sync Gradle:** Clean and rebuild project

   ```bash
   ./gradlew clean
   ./gradlew build
   ```

3. **Check minimum Android version:** SDK requires Android API 21+ (Lollipop)

   ```gradle
   android {
       defaultConfig {
           minSdk = 21  // Or higher
       }
   }
   ```

4. **Invalidate caches:** In Android Studio
   - File → Invalidate Caches → Invalidate and Restart

### Events Not Tracking

**Problem:** Events don't appear in dashboard

**Solutions:**

1. **Check initialization:**

   ```kotlin
   // Enable debug mode
   MobileTracker.getInstance().initialize(
       context = this,
       brandId = "123",
       config = TrackerConfig(debug = true, xApiKey = "key")
   )
   // Look for "✅ MobileTracker initialized successfully" in Logcat
   ```

2. **Verify API key and brand ID:**

   ```kotlin
   // Ensure these are correct
   brandId = "123"  // Must be numeric string
   xApiKey = "your-actual-api-key"  // Check dashboard for correct key
   ```

3. **Check network connectivity:**

   - Events are queued if offline and sent when online
   - Check Logcat for network errors
   - Ensure `INTERNET` permission in AndroidManifest.xml:
     ```xml
     <uses-permission android:name="android.permission.INTERNET" />
     ```

4. **Wait for session creation:**
   ```kotlin
   // Session is created asynchronously
   // Events are queued until session exists
   // Check Logcat for: "Session created asynchronously: success"
   ```

### Initialization Failures

**Problem:** Initialization throws error or times out

**Solutions:**

1. **Invalid brand ID:**

   ```kotlin
   // ❌ Wrong: Non-numeric
   brandId = "my-brand"

   // ✅ Correct: Numeric string
   brandId = "123"
   ```

2. **Network timeout:**

   - Check internet connection
   - Verify API URL is reachable
   - Check firewall/proxy settings

3. **Invalid API URL:**

   ```kotlin
   // ✅ Correct: Valid URL or null for default
   apiUrl = null  // Uses default
   apiUrl = "https://tracking.api.founder-os.ai/api"

   // ❌ Wrong: Invalid URL
   apiUrl = "not-a-url"
   ```

4. **Context issues:**
   ```kotlin
   // ✅ Use applicationContext
   MobileTracker.getInstance().initialize(
       context = applicationContext,  // Not activity context
       brandId = "123"
   )
   ```

### Events Not Associated with User

**Problem:** Events tracked after `identify()` don't show user info

**Solutions:**

1. **Call identify after initialization:**

   ```kotlin
   // ✅ Correct order
   MobileTracker.getInstance().initialize(...)
   MobileTracker.getInstance().identify(userId = "user_123")
   MobileTracker.getInstance().track(eventName = "EVENT")

   // ❌ Wrong: identify before initialize
   MobileTracker.getInstance().identify(userId = "user_123")  // Won't work
   MobileTracker.getInstance().initialize(...)
   ```

2. **Check user ID is not empty:**

   ```kotlin
   // ❌ Wrong: Empty user ID
   MobileTracker.getInstance().identify(userId = "")

   // ✅ Correct: Valid user ID
   MobileTracker.getInstance().identify(userId = "user_123")
   ```

### Build Errors

**Problem:** Compilation errors or warnings

**Solutions:**

1. **Kotlin version mismatch:**

   - SDK requires Kotlin 1.8+
   - Check `build.gradle`:
     ```gradle
     kotlin("android") version "1.8.0" apply false
     ```

2. **Coroutines not available:**

   - Add Kotlin coroutines dependency:
     ```gradle
     implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
     ```

3. **Import errors:**
   ```kotlin
   // Ensure correct imports
   import ai.founderos.mobiletracker.MobileTracker
   import ai.founderos.mobiletracker.TrackerConfig
   ```

### Debug Logging

Enable detailed logging to diagnose issues:

```kotlin
MobileTracker.getInstance().initialize(
    context = this,
    brandId = "123",
    config = TrackerConfig(
        debug = true,  // Enable debug logs
        xApiKey = "key"
    )
)
```

**What to look for in Logcat:**

- `✅ MobileTracker initialized successfully` - Initialization succeeded
- `Session created asynchronously: success` - Session created
- `Event tracked: EVENT_NAME` - Event sent successfully
- `⚠️ Not initialized` - SDK not initialized before use
- `❌ Initialization failed` - Initialization error

**Filter Logcat:**

```
MobileTracker
```

---

## Platform-Specific Notes

### Android Version Requirements

- **Minimum Android Version:** API 21+ (Android 5.0 Lollipop)
- **Minimum Kotlin Version:** 1.8+
- **Target SDK:** 34 (Android 14) recommended
- **Android Studio:** Arctic Fox (2020.3.1) or later

### Application Class vs Activity

**Application Class (Recommended):**

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize here - runs once per app launch
        CoroutineScope(Dispatchers.IO).launch {
            MobileTracker.getInstance().initialize(...)
        }
    }
}
```

**MainActivity (Alternative):**

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Initialize here - runs every time activity is created
        CoroutineScope(Dispatchers.IO).launch {
            MobileTracker.getInstance().initialize(...)
        }
    }
}
```

### Automatic Screen Tracking

The SDK automatically tracks screen views using `ActivityLifecycleCallbacks`. This happens automatically after initialization.

**Automatic tracking includes:**

- Activity name (e.g., `app://MainActivity`)
- Screen transitions
- Only tracks when screen changes (no duplicates)

**Manual screen tracking (if needed):**

```kotlin
// Manual screen tracking
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(
        eventName = "VIEW_PAGE",
        attributes = mapOf("url" to "ProfileActivity")
    )
}
```

### Permissions

**Required Permissions:**

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**Optional Permissions:**

For location tracking (if needed):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### Lifecycle Considerations

**Activity Lifecycle:**

The SDK handles Activity lifecycle automatically. No need to call any methods in `onPause()`, `onResume()`, etc.

**Process Death:**

Session data persists across process death using:

- SharedPreferences (primary storage)
- File-based backup storage

**Background Execution:**

Events can be tracked in background:

```kotlin
// Works in background
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(eventName = "BACKGROUND_EVENT")
}
```

### Thread Safety

All SDK methods are thread-safe and can be called from any thread. The SDK uses Kotlin coroutines for concurrency.

```kotlin
// Safe to call from any thread
CoroutineScope(Dispatchers.IO).launch {
    MobileTracker.getInstance().track(eventName = "EVENT")
}

// Safe from main thread
CoroutineScope(Dispatchers.Main).launch {
    MobileTracker.getInstance().track(eventName = "EVENT")
}

// Safe from background thread
CoroutineScope(Dispatchers.Default).launch {
    MobileTracker.getInstance().track(eventName = "EVENT")
}
```

### Storage

The SDK uses a dual storage strategy:

- **Primary:** SharedPreferences with prefix `__GT_{brandId}_`
- **Backup:** File-based storage in app's internal storage

Data persists across app launches and is automatically synced.

### Network Behavior

- **Timeout:** 30 seconds for initialization
- **Retry:** Events are queued and retried if network fails
- **Background:** Events can be sent in background

### ProGuard/R8

If using ProGuard or R8, add these rules to `proguard-rules.pro`:

```proguard
# FounderOS Mobile Tracker
-keep class ai.founderos.mobiletracker.** { *; }
-keepclassmembers class ai.founderos.mobiletracker.** { *; }

# Kotlinx Serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}
```

### Jetpack Compose

The SDK works seamlessly with Jetpack Compose:

```kotlin
@Composable
fun MyScreen() {
    val scope = rememberCoroutineScope()

    LaunchedEffect(Unit) {
        MobileTracker.getInstance().track(
            eventName = "VIEW_PAGE",
            attributes = mapOf("screen" to "MyScreen")
        )
    }

    Button(onClick = {
        scope.launch(Dispatchers.IO) {
            MobileTracker.getInstance().track(eventName = "BUTTON_CLICK")
        }
    }) {
        Text("Track Event")
    }
}
```

### Multi-Module Projects

For multi-module projects:

1. Add dependency in app module's `build.gradle`
2. Initialize in Application class (in app module)
3. Access singleton from any module:
   ```kotlin
   MobileTracker.getInstance().track(...)
   ```

---

## API Quick Reference

### Initialization

| Method                                 | Parameters                                                          | Description                                        |
| -------------------------------------- | ------------------------------------------------------------------- | -------------------------------------------------- |
| `initialize(context, brandId, config)` | `context: Context`<br>`brandId: String`<br>`config: TrackerConfig?` | Initialize the SDK with brand ID and configuration |

### Event Tracking

| Method                                   | Parameters                                                                              | Description                                          |
| ---------------------------------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `track(eventName, attributes, metadata)` | `eventName: String`<br>`attributes: Map<String, Any>?`<br>`metadata: Map<String, Any>?` | Track an event with optional attributes and metadata |

### User Identification

| Method                          | Parameters                                           | Description                                       |
| ------------------------------- | ---------------------------------------------------- | ------------------------------------------------- |
| `identify(userId, profileData)` | `userId: String`<br>`profileData: Map<String, Any>?` | Identify a user with ID and optional profile data |
| `set(profileData)`              | `profileData: Map<String, Any>`                      | Update user profile data                          |

### Session Management

| Method                  | Parameters                   | Description                            |
| ----------------------- | ---------------------------- | -------------------------------------- |
| `setMetadata(metadata)` | `metadata: Map<String, Any>` | Set session-level metadata             |
| `reset(all)`            | `all: Boolean`               | Reset tracker state (default: `false`) |

### Configuration

| Property           | Type      | Required | Default        | Description                |
| ------------------ | --------- | -------- | -------------- | -------------------------- |
| `debug`            | `Boolean` | No       | `false`        | Enable debug logging       |
| `apiUrl`           | `String?` | No       | Production URL | Custom API endpoint        |
| `xApiKey`          | `String?` | Yes      | -              | API key for authentication |
| `crossSiteCookie`  | `Boolean` | No       | `false`        | Enable cross-site cookies  |
| `cookieDomain`     | `String?` | No       | `null`         | Custom cookie domain       |
| `cookieExpiration` | `Int`     | No       | `365`          | Cookie expiration in days  |

### Common Event Names

| Event                | Description        | Example Attributes                 |
| -------------------- | ------------------ | ---------------------------------- |
| `VIEW_PAGE`          | Screen/page view   | `url`, `screen_name`               |
| `BUTTON_CLICK`       | Button interaction | `button_name`, `screen`            |
| `PURCHASE_COMPLETED` | Purchase event     | `product_id`, `amount`, `currency` |
| `USER_LOGGED_IN`     | Login event        | `method` (email, social, etc.)     |
| `USER_SIGNED_UP`     | Registration event | `method`, `plan`                   |
| `FORM_SUBMITTED`     | Form submission    | `form_name`, `fields_count`        |
| `VIDEO_PLAYED`       | Video playback     | `video_id`, `duration`             |
| `ERROR_OCCURRED`     | Error tracking     | `error_code`, `error_message`      |

---

## Next Steps

### Explore Full API Documentation

For detailed API documentation, see [API_REFERENCE.md](../API_REFERENCE.md)

### Check Out Examples

See complete working examples:

- [Android Example App](../examples/android/README.md)
- [Example Code](../examples/android/src/main/java/ai/founderos/mobiletracker/example/)

### Advanced Topics

- **Custom Event Schemas:** Define your own event structure
- **Event Validation:** Validate events before sending
- **Offline Support:** Handle offline scenarios
- **Performance Optimization:** Tips for high-volume tracking
- **Testing:** How to test tracking in your app

### Get Help

- **Documentation:** [https://founder-os.ai/docs](https://founder-os.ai/docs)
- **Dashboard:** [https://founder-os.ai/dashboard](https://founder-os.ai/dashboard)
- **Support:** contact@founder-os.ai
- **GitHub:** [https://github.com/Eastplayers/genie-tracking-mobile](https://github.com/Eastplayers/genie-tracking-mobile)

---

## Summary

You've successfully integrated the FounderOS Mobile Tracking SDK! Here's what you accomplished:

✅ Installed the SDK via Gradle with JitPack  
✅ Initialized the tracker with your configuration  
✅ Tracked custom events with attributes  
✅ Identified users and updated profiles  
✅ Set session-level metadata  
✅ Handled logout with session reset  
✅ Verified tracking is working

**Your app is now tracking events and user behavior!** 🎉

Check your FounderOS dashboard to see events flowing in and start analyzing user behavior.
