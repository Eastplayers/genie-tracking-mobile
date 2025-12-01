# iOS Setup Guide

Complete integration guide for the FounderOS Mobile Tracking SDK for iOS applications.

## Introduction

The FounderOS Mobile Tracking SDK provides simple, reliable event tracking with automatic context enrichment, user identification, session management, and screen tracking capabilities for iOS applications. This guide will walk you through installing and integrating the SDK into your iOS app.

**What you'll accomplish:**

- Install the SDK using CocoaPods or Swift Package Manager
- Initialize the tracker with your configuration
- Track custom events with attributes
- Identify users and update profiles
- Set session-level metadata
- Handle user logout with session reset
- Verify tracking is working correctly

**Time to complete:** 10-15 minutes

---

## Installation

### Option 1: CocoaPods (Recommended)

Add the SDK to your `Podfile`:

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  pod 'FounderOSMobileTracker', '~> 0.1.1'
end
```

Then install:

```bash
pod install
```

**Post-installation:** Open the `.xcworkspace` file (not `.xcodeproj`) in Xcode.

### Option 2: Swift Package Manager

1. In Xcode, go to **File > Add Packages...**
2. Enter the repository URL:
   ```
   https://github.com/Eastplayers/genie-tracking-mobile.git
   ```
3. Select version `0.1.1` or later
4. Click **Add Package**

---

## Quick Start

Get up and running in under 5 minutes with this minimal example:

```swift
import MobileTracker

// In your AppDelegate or App struct
Task {
    try await MobileTracker.shared.initialize(
        brandId: "YOUR_BRAND_ID",
        config: TrackerConfig(
            debug: true,
            apiUrl: nil,  // Uses default production URL
            xApiKey: "YOUR_API_KEY"
        )
    )
}

// Track an event
Task {
    await MobileTracker.shared.track(
        eventName: "BUTTON_CLICK",
        attributes: ["button_name": "signup"]
    )
}
```

---

## Step-by-Step Setup

### Step 1: Installation

Follow the installation instructions above using either CocoaPods or Swift Package Manager.

**Expected result:** The SDK is added to your project and you can import `MobileTracker` in your Swift files.

---

### Step 2: Initialize the SDK

Initialize the tracker when your app launches. For SwiftUI apps, do this in your `App` struct. For UIKit apps, do this in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`.

**SwiftUI Example:**

```swift
import SwiftUI
import MobileTracker

@main
struct YourApp: App {
    init() {
        // Initialize SDK on app launch
        Task {
            do {
                try await MobileTracker.shared.initialize(
                    brandId: "123",  // Your brand ID
                    config: TrackerConfig(
                        debug: true,
                        apiUrl: nil,  // Optional: defaults to production
                        xApiKey: "your-api-key-here"
                    )
                )
                print("✅ Tracker initialized")
            } catch {
                print("❌ Tracker initialization failed: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**UIKit Example:**

```swift
import UIKit
import MobileTracker

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize SDK on app launch
        Task {
            do {
                try await MobileTracker.shared.initialize(
                    brandId: "123",
                    config: TrackerConfig(
                        debug: true,
                        apiUrl: nil,
                        xApiKey: "your-api-key-here"
                    )
                )
                print("✅ Tracker initialized")
            } catch {
                print("❌ Tracker initialization failed: \(error)")
            }
        }
        return true
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
- `debug` (Bool, optional): Enable debug logging (default: `false`)
- `apiUrl` (String?, optional): Custom API endpoint (default: `https://tracking.api.founder-os.ai/api`)
- `xApiKey` (String?, optional): API key for authentication

**Expected result:** The SDK initializes without errors and you see a success message in the console.

---

### Step 3: Track Events

Track user actions and behaviors throughout your app.

**Basic Event Tracking:**

```swift
import MobileTracker

// Simple event
Task {
    await MobileTracker.shared.track(eventName: "BUTTON_CLICK")
}

// Event with attributes
Task {
    await MobileTracker.shared.track(
        eventName: "PURCHASE_COMPLETED",
        attributes: [
            "product_id": "prod_123",
            "amount": 29.99,
            "currency": "USD"
        ]
    )
}
```

**Event with Metadata:**

```swift
Task {
    await MobileTracker.shared.track(
        eventName: "VIDEO_PLAYED",
        attributes: [
            "video_id": "vid_456",
            "duration": 120
        ],
        metadata: [
            "player_version": "2.1.0",
            "quality": "1080p"
        ]
    )
}
```

**Real-World Examples:**

```swift
// Button click
Task {
    await MobileTracker.shared.track(
        eventName: "BUTTON_CLICK",
        attributes: ["button_name": "signup", "screen": "home"]
    )
}

// Page view (automatic, but can be manual too)
Task {
    await MobileTracker.shared.track(
        eventName: "VIEW_PAGE",
        attributes: ["url": "ProfileViewController"]
    )
}

// Form submission
Task {
    await MobileTracker.shared.track(
        eventName: "FORM_SUBMITTED",
        attributes: [
            "form_name": "contact",
            "fields_count": 5
        ]
    )
}

// Error tracking
Task {
    await MobileTracker.shared.track(
        eventName: "ERROR_OCCURRED",
        attributes: [
            "error_code": "AUTH_001",
            "error_message": "Invalid credentials"
        ]
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

```swift
import MobileTracker

// Basic identification
Task {
    await MobileTracker.shared.identify(userId: "user_12345")
}

// Identification with profile data
Task {
    await MobileTracker.shared.identify(
        userId: "user_12345",
        profileData: [
            "email": "user@example.com",
            "name": "John Doe",
            "plan": "premium"
        ]
    )
}
```

**When to call identify:**

- After successful login
- After user registration
- When user data is loaded from storage

**Example in login flow:**

```swift
func handleLogin(email: String, password: String) async {
    do {
        let user = try await authService.login(email: email, password: password)

        // Identify user after successful login
        await MobileTracker.shared.identify(
            userId: user.id,
            profileData: [
                "email": user.email,
                "name": user.name,
                "created_at": user.createdAt
            ]
        )

        print("✅ User identified")
    } catch {
        print("❌ Login failed: \(error)")
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

```swift
import MobileTracker

// Update profile data
Task {
    await MobileTracker.shared.set(profileData: [
        "plan": "enterprise",
        "company": "Acme Corp",
        "phone": "+1234567890"
    ])
}

// Update single field
Task {
    await MobileTracker.shared.set(profileData: ["last_login": Date().ISO8601Format()])
}
```

**Common use cases:**

```swift
// After subscription upgrade
Task {
    await MobileTracker.shared.set(profileData: [
        "plan": "premium",
        "subscription_date": Date().ISO8601Format()
    ])
}

// After profile edit
Task {
    await MobileTracker.shared.set(profileData: [
        "name": updatedName,
        "phone": updatedPhone,
        "preferences": userPreferences
    ])
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

```swift
import MobileTracker

// Set session-level metadata
Task {
    await MobileTracker.shared.setMetadata([
        "app_version": "2.1.0",
        "build_number": "145",
        "environment": "production"
    ])
}

// Add experiment/feature flag data
Task {
    await MobileTracker.shared.setMetadata([
        "experiment_group": "variant_b",
        "feature_new_ui": true,
        "ab_test_id": "test_123"
    ])
}
```

**When to use metadata:**

- Feature flags and A/B test assignments
- App version and build information
- Session type (guest vs authenticated)
- Environment information (staging, production)

**Example with feature flags:**

```swift
func setupSessionContext() async {
    await MobileTracker.shared.setMetadata([
        "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
        "feature_dark_mode": UserDefaults.standard.bool(forKey: "dark_mode_enabled"),
        "experiment_checkout_flow": "variant_a",
        "user_segment": "power_user"
    ])
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

```swift
import MobileTracker

// Reset user data but keep session
MobileTracker.shared.reset(all: false)

// Reset everything including brand ID (rare)
MobileTracker.shared.reset(all: true)
```

**Example in logout flow:**

```swift
func handleLogout() async {
    // Clear user session
    await authService.logout()

    // Reset tracker to clear user identification
    MobileTracker.shared.reset(all: false)

    print("✅ User logged out and tracker reset")

    // Navigate to login screen
    navigateToLogin()
}
```

**What `reset()` does:**

- Clears `session_id`, `device_id`, `session_email`, `identify_id`
- Creates a new tracking session
- Clears pending events
- Resets internal state

**What `reset(all: true)` does:**

- Everything above, plus clears `brand_id`
- Use only when completely reinitializing the SDK

**Expected result:** New events after reset are not associated with the previous user.

---

### Step 8: Verify Tracking

Confirm the SDK is working correctly.

**1. Enable Debug Mode:**

```swift
try await MobileTracker.shared.initialize(
    brandId: "123",
    config: TrackerConfig(
        debug: true,  // Enable debug logging
        xApiKey: "your-api-key"
    )
)
```

**2. Check Console Logs:**

Look for these messages in Xcode console:

```
✅ MobileTracker initialized successfully
[MobileTracker] Session created asynchronously: success
[MobileTracker] Event tracked: BUTTON_CLICK, ["button_name": "signup"]
```

**3. Check Dashboard:**

- Log into your FounderOS dashboard
- Navigate to Events or Analytics section
- Verify events appear with correct data
- Check that user identification is working

**4. Test Event Flow:**

```swift
// Test complete flow
Task {
    // 1. Initialize
    try await MobileTracker.shared.initialize(
        brandId: "123",
        config: TrackerConfig(debug: true, xApiKey: "your-api-key")
    )

    // 2. Track test event
    await MobileTracker.shared.track(
        eventName: "TEST_EVENT",
        attributes: ["test": true]
    )

    // 3. Identify test user
    await MobileTracker.shared.identify(
        userId: "test_user_123",
        profileData: ["email": "test@example.com"]
    )

    // 4. Track another event
    await MobileTracker.shared.track(
        eventName: "TEST_EVENT_AFTER_IDENTIFY",
        attributes: ["identified": true]
    )

    print("✅ Test flow completed - check dashboard")
}
```

**Expected result:**

- Console shows successful initialization and event tracking
- Dashboard displays all test events
- Events after `identify()` show user association

---

## All-in-One Example

Complete integration showing all features together:

```swift
import SwiftUI
import MobileTracker

@main
struct MyApp: App {
    init() {
        // Initialize on app launch
        Task {
            do {
                try await MobileTracker.shared.initialize(
                    brandId: "123",
                    config: TrackerConfig(
                        debug: true,
                        apiUrl: nil,  // Uses default
                        xApiKey: "your-api-key-here"
                    )
                )

                // Set session metadata
                await MobileTracker.shared.setMetadata([
                    "app_version": "1.0.0",
                    "environment": "production"
                ])

                print("✅ Tracker ready")
            } catch {
                print("❌ Tracker failed: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

struct ContentView: View {
@State private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 20) {
            if isLoggedIn {
                // Logged in view
                Text("Welcome!")

                Button("Track Purchase") {
                    Task {
                        await MobileTracker.shared.track(
                            eventName: "PURCHASE_COMPLETED",
                            attributes: [
                                "product_id": "prod_123",
                                "amount": 29.99
                            ]
                        )
                    }
                }

                Button("Update Profile") {
                    Task {
                        await MobileTracker.shared.set(profileData: [
                            "plan": "premium",
                            "last_active": Date().ISO8601Format()
                        ])
                    }
                }

                Button("Logout") {
                    Task {
                        // Reset tracker on logout
                        MobileTracker.shared.reset(all: false)
                        isLoggedIn = false
                    }
                }
            } else {
                // Login view
                Button("Login") {
                    Task {
                        // Simulate login
                        let userId = "user_12345"

                        // Identify user
                        await MobileTracker.shared.identify(
                            userId: userId,
                            profileData: [
                                "email": "user@example.com",
                                "name": "John Doe"
                            ]
                        )

                        // Track login event
                        await MobileTracker.shared.track(
                            eventName: "USER_LOGGED_IN",
                            attributes: ["method": "email"]
                        )

                        isLoggedIn = true
                    }
                }
            }
        }
        .padding()
        .onAppear {
            // Track screen view
            Task {
                await MobileTracker.shared.track(
                    eventName: "VIEW_PAGE",
                    attributes: ["screen": "ContentView"]
                )
            }
        }
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
```

## Best Practices

### Performance

**Initialize Early:**

```swift
// ✅ Good: Initialize in App init or AppDelegate
@main
struct MyApp: App {
    init() {
        Task {
            try await MobileTracker.shared.initialize(...)
        }
    }
}

// ❌ Bad: Don't initialize in every view
struct MyView: View {
    var body: some View {
        Text("Hello").onAppear {
            Task { try await MobileTracker.shared.initialize(...) }  // Wrong!
        }
    }
}
```

**Batch Events:**

```swift
// ✅ Good: Track meaningful events
await MobileTracker.shared.track(eventName: "CHECKOUT_COMPLETED")

// ❌ Bad: Don't track every tiny interaction
await MobileTracker.shared.track(eventName: "MOUSE_MOVED")  // Too granular
```

**Use Background Tasks:**

```swift
// ✅ Good: Already async, no blocking
Task {
    await MobileTracker.shared.track(eventName: "EVENT")
}

// ❌ Bad: Don't block main thread
await MobileTracker.shared.track(eventName: "EVENT")  // Blocks if called on main thread
```

### Privacy

**Respect User Consent:**

```swift
// Check consent before initializing
if userHasGrantedTrackingConsent {
    Task {
        try await MobileTracker.shared.initialize(...)
    }
}
```

**Don't Track PII Without Consent:**

```swift
// ✅ Good: Use hashed or anonymized IDs
await MobileTracker.shared.identify(userId: "user_abc123")

// ⚠️ Careful: Only if user consented
await MobileTracker.shared.identify(
    userId: "user_123",
    profileData: ["email": "user@example.com"]  // Requires consent
)
```

**Clear Data on Logout:**

```swift
// Always reset on logout
func logout() {
    MobileTracker.shared.reset(all: false)
    // Clear other user data...
}
```

### Event Naming

**Use Consistent Naming:**

```swift
// ✅ Good: SCREAMING_SNAKE_CASE
await MobileTracker.shared.track(eventName: "BUTTON_CLICK")
await MobileTracker.shared.track(eventName: "PURCHASE_COMPLETED")
await MobileTracker.shared.track(eventName: "VIDEO_PLAYED")

// ❌ Bad: Inconsistent naming
await MobileTracker.shared.track(eventName: "buttonClick")
await MobileTracker.shared.track(eventName: "purchase-completed")
await MobileTracker.shared.track(eventName: "Video Played")
```

**Be Descriptive:**

```swift
// ✅ Good: Clear and specific
await MobileTracker.shared.track(eventName: "CHECKOUT_PAYMENT_METHOD_SELECTED")

// ❌ Bad: Too vague
await MobileTracker.shared.track(eventName: "CLICK")
```

### Attributes vs Metadata

**Use Attributes for Event-Specific Data:**

```swift
// Event-specific information
await MobileTracker.shared.track(
    eventName: "PRODUCT_VIEWED",
    attributes: [
        "product_id": "prod_123",
        "category": "electronics",
        "price": 299.99
    ]
)
```

**Use Metadata for Session-Wide Context:**

```swift
// Session-wide information
await MobileTracker.shared.setMetadata([
    "app_version": "2.1.0",
    "user_segment": "premium",
    "ab_test_variant": "B"
])
```

### Error Handling

**Handle Initialization Errors:**

```swift
Task {
    do {
        try await MobileTracker.shared.initialize(
            brandId: "123",
            config: TrackerConfig(xApiKey: "key")
        )
    } catch {
        // Log error but don't crash the app
        print("Tracker initialization failed: \(error)")
        // Optionally report to error tracking service
    }
}
```

**Graceful Degradation:**

```swift
// SDK handles errors internally - tracking failures won't crash your app
await MobileTracker.shared.track(eventName: "EVENT")  // Safe even if not initialized
```

---

## Troubleshooting

### SDK Not Loading

**Problem:** Import fails or SDK not found

**Solutions:**

1. **CocoaPods:** Ensure you opened `.xcworkspace` not `.xcodeproj`

   ```bash
   # Reinstall pods
   pod deintegrate
   pod install
   ```

2. **Swift Package Manager:** Clean build folder

   - Xcode → Product → Clean Build Folder (⇧⌘K)
   - File → Packages → Reset Package Caches

3. **Check minimum iOS version:** SDK requires iOS 13.0+
   ```swift
   // In your target settings
   iOS Deployment Target: 13.0 or higher
   ```

### Events Not Tracking

**Problem:** Events don't appear in dashboard

**Solutions:**

1. **Check initialization:**

   ```swift
   // Enable debug mode
   try await MobileTracker.shared.initialize(
       brandId: "123",
       config: TrackerConfig(debug: true, xApiKey: "key")
   )
   // Look for "✅ MobileTracker initialized successfully" in console
   ```

2. **Verify API key and brand ID:**

   ```swift
   // Ensure these are correct
   brandId: "123"  // Must be numeric string
   xApiKey: "your-actual-api-key"  // Check dashboard for correct key
   ```

3. **Check network connectivity:**

   - Events are queued if offline and sent when online
   - Check console for network errors

4. **Wait for session creation:**
   ```swift
   // Session is created asynchronously
   // Events are queued until session exists
   // Check console for: "Session created asynchronously: success"
   ```

### Initialization Failures

**Problem:** Initialization throws error or times out

**Solutions:**

1. **Invalid brand ID:**

   ```swift
   // ❌ Wrong: Non-numeric
   brandId: "my-brand"

   // ✅ Correct: Numeric string
   brandId: "123"
   ```

2. **Network timeout:**

   - Check internet connection
   - Verify API URL is reachable
   - Check firewall/proxy settings

3. **Invalid API URL:**

   ```swift
   // ✅ Correct: Valid URL or nil for default
   apiUrl: nil  // Uses default
   apiUrl: "https://tracking.api.founder-os.ai/api"

   // ❌ Wrong: Invalid URL
   apiUrl: "not-a-url"
   ```

### Events Not Associated with User

**Problem:** Events tracked after `identify()` don't show user info

**Solutions:**

1. **Call identify after initialization:**

   ```swift
   // ✅ Correct order
   try await MobileTracker.shared.initialize(...)
   await MobileTracker.shared.identify(userId: "user_123")
   await MobileTracker.shared.track(eventName: "EVENT")

   // ❌ Wrong: identify before initialize
   await MobileTracker.shared.identify(userId: "user_123")  // Won't work
   try await MobileTracker.shared.initialize(...)
   ```

2. **Check user ID is not empty:**

   ```swift
   // ❌ Wrong: Empty user ID
   await MobileTracker.shared.identify(userId: "")

   // ✅ Correct: Valid user ID
   await MobileTracker.shared.identify(userId: "user_123")
   ```

### Build Errors

**Problem:** Compilation errors or warnings

**Solutions:**

1. **Swift version mismatch:**

   - SDK requires Swift 5.5+
   - Check Build Settings → Swift Language Version

2. **Async/await not available:**

   - Requires iOS 13.0+ with Swift 5.5+
   - Update deployment target if needed

3. **Module not found:**
   ```swift
   // Ensure correct import
   import MobileTracker  // Not FounderOSMobileTracker
   ```

### Debug Logging

Enable detailed logging to diagnose issues:

```swift
try await MobileTracker.shared.initialize(
    brandId: "123",
    config: TrackerConfig(
        debug: true,  // Enable debug logs
        xApiKey: "key"
    )
)
```

**What to look for in logs:**

- `✅ MobileTracker initialized successfully` - Initialization succeeded
- `Session created asynchronously: success` - Session created
- `Event tracked: EVENT_NAME` - Event sent successfully
- `⚠️ Not initialized` - SDK not initialized before use
- `❌ Initialization failed` - Initialization error

---

## Platform-Specific Notes

### iOS Version Requirements

- **Minimum iOS Version:** 13.0
- **Minimum Swift Version:** 5.5
- **Xcode Version:** 13.0 or later

### UIKit vs SwiftUI

**SwiftUI Apps:**

```swift
@main
struct MyApp: App {
    init() {
        // Initialize here
        Task {
            try await MobileTracker.shared.initialize(...)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**UIKit Apps:**

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize here
        Task {
            try await MobileTracker.shared.initialize(...)
        }
        return true
    }
}
```

### Automatic Screen Tracking

The SDK automatically tracks screen views in UIKit apps by swizzling `viewDidAppear(_:)`. This happens automatically after initialization.

**Disable automatic tracking (if needed):**
Currently automatic tracking is always enabled. To track screens manually:

```swift
// Manual screen tracking
Task {
    await MobileTracker.shared.track(
        eventName: "VIEW_PAGE",
        attributes: ["url": "ProfileViewController"]
    )
}
```

### Permissions

**Location Tracking (Optional):**

If you want to include location data in events, add to `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to provide better analytics</string>
```

**App Tracking Transparency (iOS 14.5+):**

For user-level tracking, request permission:

```swift
import AppTrackingTransparency

// Request tracking permission
if #available(iOS 14.5, *) {
    ATTrackingManager.requestTrackingAuthorization { status in
        if status == .authorized {
            // User granted permission
            Task {
                try await MobileTracker.shared.initialize(...)
            }
        }
    }
}
```

### Thread Safety

All SDK methods are thread-safe and can be called from any thread. The SDK uses Swift's async/await for concurrency.

```swift
// Safe to call from any thread
Task {
    await MobileTracker.shared.track(eventName: "EVENT")
}

// Safe from main thread
DispatchQueue.main.async {
    Task {
        await MobileTracker.shared.track(eventName: "EVENT")
    }
}

// Safe from background thread
DispatchQueue.global().async {
    Task {
        await MobileTracker.shared.track(eventName: "EVENT")
    }
}
```

### Storage

The SDK uses a dual storage strategy:

- **Primary:** UserDefaults with prefix `__GT_{brandId}_`
- **Backup:** File-based storage in app's documents directory

Data persists across app launches and is automatically synced.

### Network Behavior

- **Timeout:** 30 seconds for initialization
- **Retry:** Events are queued and retried if network fails
- **Background:** Events can be sent in background (iOS handles this automatically)

### App Extensions

The SDK is designed for main app use. For app extensions:

- Initialize separately in each extension
- Share data using App Groups if needed
- Consider privacy implications

---

## API Quick Reference

### Initialization

| Method                        | Parameters                                    | Description                                        |
| ----------------------------- | --------------------------------------------- | -------------------------------------------------- |
| `initialize(brandId:config:)` | `brandId: String`<br>`config: TrackerConfig?` | Initialize the SDK with brand ID and configuration |

### Event Tracking

| Method                                  | Parameters                                                                        | Description                                          |
| --------------------------------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `track(eventName:attributes:metadata:)` | `eventName: String`<br>`attributes: [String: Any]?`<br>`metadata: [String: Any]?` | Track an event with optional attributes and metadata |

### User Identification

| Method                          | Parameters                                        | Description                                       |
| ------------------------------- | ------------------------------------------------- | ------------------------------------------------- |
| `identify(userId:profileData:)` | `userId: String`<br>`profileData: [String: Any]?` | Identify a user with ID and optional profile data |
| `set(profileData:)`             | `profileData: [String: Any]`                      | Update user profile data                          |

### Session Management

| Method            | Parameters                | Description                            |
| ----------------- | ------------------------- | -------------------------------------- |
| `setMetadata(_:)` | `metadata: [String: Any]` | Set session-level metadata             |
| `reset(all:)`     | `all: Bool`               | Reset tracker state (default: `false`) |

### Configuration

| Property           | Type      | Required | Default        | Description                |
| ------------------ | --------- | -------- | -------------- | -------------------------- |
| `debug`            | `Bool`    | No       | `false`        | Enable debug logging       |
| `apiUrl`           | `String?` | No       | Production URL | Custom API endpoint        |
| `xApiKey`          | `String?` | Yes      | -              | API key for authentication |
| `crossSiteCookie`  | `Bool`    | No       | `false`        | Enable cross-site cookies  |
| `cookieDomain`     | `String?` | No       | `nil`          | Custom cookie domain       |
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

- [iOS Example App](../examples/ios/README.md)
- [Example Code](../examples/ios/MobileTrackerExample/)

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

✅ Installed the SDK via CocoaPods or Swift Package Manager  
✅ Initialized the tracker with your configuration  
✅ Tracked custom events with attributes  
✅ Identified users and updated profiles  
✅ Set session-level metadata  
✅ Handled logout with session reset  
✅ Verified tracking is working

**Your app is now tracking events and user behavior!** 🎉

Check your FounderOS dashboard to see events flowing in and start analyzing user behavior.
