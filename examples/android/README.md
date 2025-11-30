# Android Example App

This is a simple Android example application demonstrating how to use the MobileTracker SDK.

## Features

- **Initialize SDK**: The SDK is initialized when the activity is created with demo credentials
- **Session Management**: Automatic session creation and management during initialization
- **Identify Users**: Enter a user ID to identify the current user with traits
- **Track Events**: Track custom events with properties
- **Track Screens**: Track screen views with properties
- **Set Metadata**: Add session-level metadata that persists across events
- **Update Profile**: Update user profile data using the set() method
- **Reset Tracking**: Clear session data or reset all tracking data including brand ID
- **Quick Actions**: Pre-configured buttons to track common events (button clicks, purchases, signups)

## Setup

1. Ensure the MobileTracker Android SDK is built and available
2. Open the root project in Android Studio
3. Select the example app configuration
4. Build and run the app on an emulator or device

## Usage

### Initialize

The SDK is automatically initialized when the activity is created with:

- Brand ID: `925` (identifies your application/brand)
- API Key: `03dbd95123137cc76b075f50107d8d2d` (for authentication)
- API URL: `https://tracking.api.qc.founder-os.ai/api` (backend endpoint)

### Identify a User

1. Enter a user ID in the "Identify User" section
2. Tap "Identify" to associate future events with this user
3. The SDK will automatically add traits like email and plan

### Track Custom Events

1. Enter an event name in the "Track Event" section
2. Tap "Track Event" to send the event
3. The event will include custom properties like source and timestamp

### Track Screen Views

1. Enter a screen name in the "Track Screen" section
2. Tap "Track Screen" to record the screen view
3. The screen event will include properties like previous screen and load time

### Set Metadata

1. Enter a metadata key and value in the "Set Metadata" section
2. Tap "Set Metadata" to add session-level metadata
3. This metadata will be included with all subsequent events

### Update Profile

1. Enter name and/or email in the "Update Profile (set)" section
2. Tap "Update Profile" to update the user's profile data
3. This uses the set() method to update profile without requiring a user ID

### Reset Tracking

Use the reset functionality to clear tracking data:

- **Reset Session**: Clears session data but preserves brand ID
- **Reset All**: Clears all tracking data including brand ID

### Quick Actions

Use the pre-configured buttons to quickly test common tracking scenarios:

- **Button Click**: Tracks a button interaction event
- **Purchase**: Tracks a purchase with product details and price
- **Signup**: Tracks a user signup event

## Code Examples

### Initialize SDK with Session Management

```kotlin
// Initialize with brand ID, API key, and configuration
MobileTracker.getInstance().initialize(
    context = applicationContext,
    brandId = "925",  // Your Brand ID
    config = TrackerConfig(
        debug = true,
        apiUrl = "https://tracking.api.qc.founder-os.ai/api",  // Backend API URL
        xApiKey = "03dbd95123137cc76b075f50107d8d2d"  // Your API key for authentication
    )
)
// Session is automatically created during initialization
```

### Identify User

```kotlin
MobileTracker.getInstance().identify(
    userId = "user123",
    profileData = mapOf(
        "email" to "user@example.com",
        "plan" to "premium"
    )
)
```

### Track Event

```kotlin
MobileTracker.getInstance().track(
    eventName = "Button Clicked",
    attributes = mapOf(
        "buttonName" to "signup",
        "screen" to "home"
    )
)
```

### Set Metadata

```kotlin
MobileTracker.getInstance().setMetadata(mapOf(
    "app_version" to "1.2.3",
    "feature_flags" to listOf("new_ui", "beta_feature"),
    "environment" to "production"
))
```

### Update Profile with set()

```kotlin
MobileTracker.getInstance().set(mapOf(
    "name" to "John Doe",
    "email" to "john@example.com",
    "plan" to "premium"
))
```

### Reset Tracking

```kotlin
// Reset session data but keep brand ID
MobileTracker.getInstance().reset(false)

// Reset all data including brand ID
MobileTracker.getInstance().reset(true)
```

## Requirements

- Android API 21+ (Lollipop)
- Kotlin 1.8+
- Jetpack Compose
- MobileTracker SDK

## Dependencies

The example app uses:

- Jetpack Compose for UI
- Material 3 design components
- MobileTracker Android SDK

## Notes

- All events are logged to Logcat for debugging
- Status messages appear at the top of the screen
- The app demonstrates session management (Requirements 1.1, 2.1, 2.2)
- The app demonstrates setMetadata() functionality (Requirements 7.1)
- The app demonstrates set() profile updates (Requirements 6.2)
- The app demonstrates reset() functionality (Requirements 8.1)
- Sessions are automatically created during SDK initialization
- Automatic screen tracking is enabled by default
- Internet permission is required for sending events to the backend
