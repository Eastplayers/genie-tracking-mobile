# Mobile Tracking SDK

A cross-platform analytics and event tracking SDK for iOS, Android, and React Native applications. The SDK provides simple, reliable event tracking with automatic context enrichment, user identification, session management, and screen tracking capabilities.

## Features

- 📱 Native iOS SDK (Swift)
- 🤖 Native Android SDK (Kotlin)
- ⚛️ React Native bridge for cross-platform apps
- 🚀 Simple, intuitive API
- 🔐 Backend session management with automatic creation
- 📊 Automatic context enrichment (platform, OS version, timestamps)
- 👤 User identification and profile management
- 📺 Automatic screen/page view tracking
- 🔄 Event queueing with automatic delivery
- 💾 Dual storage (primary + backup) for data persistence
- 📍 Optional geolocation tracking
- 🧵 Thread-safe operations
- ⚡ Lightweight and performant

## Installation

### iOS (CocoaPods)

Add to your `Podfile`:

```ruby
pod 'MobileTracker', '~> 0.1.0'
```

Then run:

```bash
pod install
```

### iOS (Swift Package Manager)

Add the package dependency in Xcode:

1. File → Add Packages...
2. Enter the repository URL: `https://github.com/yourusername/mobile-tracking-sdk.git`
3. Select version `0.1.0` or later

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/mobile-tracking-sdk.git", from: "0.1.0")
]
```

### Android (Gradle)

Add to your app's `build.gradle`:

```gradle
dependencies {
    implementation 'com.mobiletracker:mobile-tracking-sdk:0.1.0'
}
```

Add the Maven repository in your project's `build.gradle` or `settings.gradle`:

```gradle
repositories {
    mavenCentral()
    // Or your custom repository
    maven { url 'https://your-maven-repo.com/releases' }
}
```

### React Native

Install via npm or yarn:

```bash
npm install @mobiletracker/react-native
# or
yarn add @mobiletracker/react-native
```

For React Native 0.60+, dependencies are auto-linked. For older versions:

```bash
react-native link @mobiletracker/react-native
```

iOS additional setup:

```bash
cd ios && pod install && cd ..
```

## Quick Start

### iOS

```swift
import MobileTracker

// Initialize the SDK with brand ID and configuration (typically in AppDelegate)
Task {
    do {
        try await MobileTracker.shared.initialize(
            brandId: "925",  // Your Brand ID (identifies your application/brand)
            config: TrackerConfig(
                debug: true,
                apiUrl: "https://tracking.api.qc.founder-os.ai/api",  // Backend API URL
                xApiKey: "03dbd95123137cc76b075f50107d8d2d"  // Your API key for authentication
            )
        )
        // Session is automatically created during initialization
    } catch {
        print("Failed to initialize tracker: \(error)")
    }
}

// Track an event (requires active session)
Task {
    await MobileTracker.shared.track(
        eventName: "BUTTON_CLICK",
        attributes: [
            "button_name": "signup",
            "screen": "home"
        ]
    )
}

// Identify a user with profile data
Task {
    await MobileTracker.shared.identify(
        userId: "user123",
        profileData: [
            "email": "user@example.com",
            "name": "John Doe",
            "plan": "pro"
        ]
    )
}

// Update user profile without changing user ID
Task {
    await MobileTracker.shared.set(profileData: [
        "plan": "enterprise",
        "last_login": "2025-11-27"
    ])
}

// Set session-level metadata
Task {
    await MobileTracker.shared.setMetadata([
        "session_type": "premium",
        "feature_flags": ["new_ui", "dark_mode"]
    ])
}

// Reset all tracking data (e.g., on logout)
MobileTracker.shared.reset(all: false)  // Keeps brand ID
// or
MobileTracker.shared.reset(all: true)   // Clears everything including brand ID
```

### Android

```kotlin
import com.mobiletracker.MobileTracker
import com.mobiletracker.Configuration
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

// Initialize the SDK with brand ID and configuration (typically in Application.onCreate())
GlobalScope.launch {
    MobileTracker.getInstance().initialize(
        context = applicationContext,
        brandId = "925",  // Your Brand ID (identifies your application/brand)
        config = TrackerConfig(
            debug = true,
            apiUrl = "https://tracking.api.qc.founder-os.ai/api",  // Backend API URL
            xApiKey = "03dbd95123137cc76b075f50107d8d2d"  // Your API key for authentication
        )
    )
    // Session is automatically created during initialization
}

// Track an event (requires active session)
GlobalScope.launch {
    MobileTracker.getInstance().track(
        eventName = "BUTTON_CLICK",
        attributes = mapOf(
            "button_name" to "signup",
            "screen" to "home"
        )
    )
}

// Identify a user with profile data
GlobalScope.launch {
    MobileTracker.getInstance().identify(
        userId = "user123",
        profileData = mapOf(
            "email" to "user@example.com",
            "name" to "John Doe",
            "plan" to "pro"
        )
    )
}

// Update user profile without changing user ID
GlobalScope.launch {
    MobileTracker.getInstance().set(
        profileData = mapOf(
            "plan" to "enterprise",
            "last_login" to "2025-11-27"
        )
    )
}

// Set session-level metadata
GlobalScope.launch {
    MobileTracker.getInstance().setMetadata(
        metadata = mapOf(
            "session_type" to "premium",
            "feature_flags" to listOf("new_ui", "dark_mode")
        )
    )
}

// Reset all tracking data (e.g., on logout)
MobileTracker.getInstance().reset(all = false)  // Keeps brand ID
// or
MobileTracker.getInstance().reset(all = true)   // Clears everything including brand ID
```

### React Native

```typescript
import MobileTracker from '@mobiletracker/react-native'

// Initialize the SDK with brand ID and configuration (typically in App.tsx)
await MobileTracker.init({
  apiKey: '925', // Your Brand ID (passed as apiKey for React Native bridge)
  endpoint: 'https://tracking.api.qc.founder-os.ai/api', // Backend API URL
  x_api_key: '03dbd95123137cc76b075f50107d8d2d', // Your API key for authentication
  debug: true,
})
// Session is automatically created during initialization

// Track an event (requires active session)
await MobileTracker.track('BUTTON_CLICK', {
  button_name: 'signup',
  screen: 'home',
})

// Identify a user with profile data
await MobileTracker.identify('user123', {
  email: 'user@example.com',
  name: 'John Doe',
  plan: 'pro',
})

// Update user profile without changing user ID
await MobileTracker.set({
  plan: 'enterprise',
  last_login: '2025-11-27',
})

// Set session-level metadata
await MobileTracker.setMetadata({
  session_type: 'premium',
  feature_flags: ['new_ui', 'dark_mode'],
})

// Reset all tracking data (e.g., on logout)
MobileTracker.reset(false) // Keeps brand ID
// or
MobileTracker.reset(true) // Clears everything including brand ID
```

## Key Concepts

### Initialization and Session Management

The SDK must be initialized with a **brand ID** before any tracking can occur. During initialization:

1. **Brand ID Validation**: The SDK validates that the brand ID is a non-empty numeric string
2. **Configuration Merge**: Your config is merged with default values
3. **Session Creation**: A backend tracking session is automatically created (or existing session is restored)
4. **Background Services**: Page/screen view tracking is set up automatically

**Important**: All events require an active session. If you try to track events before initialization completes, they will be queued and sent once the session is ready.

### Session Lifecycle

- **Creation**: Sessions are created automatically during `init()` if no existing session is found
- **Persistence**: Session IDs are stored in dual storage (primary + backup) for reliability
- **Restoration**: On app restart, the SDK checks for an existing session before creating a new one
- **Reset**: Call `reset()` to clear session data (useful on logout)

### Storage Strategy

The SDK uses a **dual storage approach** inspired by the web implementation:

- **Primary Storage**: UserDefaults (iOS) / SharedPreferences (Android)
- **Backup Storage**: File-based storage
- **Prefix**: All keys use format `__GT_{brandId}_` to avoid conflicts
- **Fallback**: If primary storage fails, data is retrieved from backup

This ensures data persistence even if one storage mechanism fails.

### Event Queueing

Events tracked before initialization completes are automatically queued:

- **Queue Behavior**: FIFO (First In, First Out)
- **Auto-Flush**: Once session is ready, all queued events are sent
- **Session Requirement**: Events without a session ID are queued until session is available

### Automatic Screen Tracking

The SDK automatically tracks screen/page views:

- **iOS**: Uses UIViewController swizzling to detect screen changes
- **Android**: Uses ActivityLifecycleCallbacks to detect activity changes
- **Event Name**: `VIEW_PAGE`
- **Automatic**: No manual instrumentation required (but you can still track manually)

## Configuration Options

The SDK accepts the following configuration options during initialization:

| Option             | Type    | Default  | Description                                            |
| ------------------ | ------- | -------- | ------------------------------------------------------ |
| `debug`            | Boolean | `false`  | Enable detailed logging for debugging                  |
| `apiUrl`           | String  | Required | Backend API base URL (e.g., `https://api.example.com`) |
| `xApiKey`          | String  | Required | API key for authentication                             |
| `crossSiteCookie`  | Boolean | `false`  | Enable cross-domain tracking                           |
| `cookieDomain`     | String  | `null`   | Custom cookie domain for cross-domain tracking         |
| `cookieExpiration` | Integer | `365`    | Cookie expiration in days                              |

**Example Configuration:**

```swift
// iOS
let config = TrackerConfig(
    debug: true,
    apiUrl: "https://api.example.com",
    xApiKey: "your-api-key",
    crossSiteCookie: false,
    cookieExpiration: 365
)
```

```kotlin
// Android
val config = Configuration(
    debug = true,
    apiUrl = "https://api.example.com",
    xApiKey = "your-api-key",
    crossSiteCookie = false,
    cookieExpiration = 365
)
```

```typescript
// React Native
const config = {
  debug: true,
  apiUrl: 'https://api.example.com',
  xApiKey: 'your-api-key',
  crossSiteCookie: false,
  cookieExpiration: 365,
}
```

## API Reference

See [API_REFERENCE.md](./API_REFERENCE.md) for detailed documentation of all methods, parameters, and error codes.

## Examples

Complete example applications are available in the `examples/` directory:

- [iOS Example](./examples/ios/README.md) - Native iOS app with SwiftUI
- [Android Example](./examples/android/README.md) - Native Android app with Kotlin
- [React Native Example](./examples/react-native/README.md) - Cross-platform React Native app

## Architecture

The SDK follows a "Core SDK + Bridges" architecture:

- **Native SDKs** (iOS & Android) implement all tracking logic
- **React Native Bridge** provides a thin wrapper for JavaScript access
- Events are queued in memory and sent via HTTP POST to your backend
- Automatic context enrichment (platform, OS version, timestamps)
- Thread-safe operations across all platforms

## API Methods

### `init(brandId, config)`

Initialize the SDK with your brand ID and configuration. This must be called before any tracking operations.

**Parameters:**

- `brandId` (String, required): Your unique brand identifier (must be numeric)
- `config` (Object, optional): Configuration options (see Configuration Options section)

**Behavior:**

- Validates brand ID (must be non-empty and numeric)
- Merges provided config with defaults
- Creates or restores backend tracking session
- Sets up automatic page/screen view tracking
- Returns immediately if already initialized
- Waits if initialization is in progress

**Example:**

```swift
// iOS
try await MobileTracker.shared.initialize(brandId: "925", config: config)
```

### `track(eventName, attributes, metadata)`

Track a custom event with optional attributes and metadata.

**Parameters:**

- `eventName` (String, required): Name of the event (e.g., "BUTTON_CLICK", "PURCHASE")
- `attributes` (Object, optional): Event properties (e.g., `{button: "signup", value: 100}`)
- `metadata` (Object, optional): Technical metadata (e.g., `{flow_id: "abc"}`)

**Behavior:**

- Requires active session (events queued if session not ready)
- Merges attributes and metadata into event data
- Sends POST request to `/v2/tracking-session-data`

**Example:**

```swift
// iOS
await MobileTracker.shared.track(
    eventName: "BUTTON_CLICK",
    attributes: ["button": "signup", "screen": "home"]
)
```

### `identify(userId, profileData)`

Identify a user and associate them with the current session.

**Parameters:**

- `userId` (String, required): Unique user identifier
- `profileData` (Object, optional): User profile data (e.g., `{name: "John", email: "john@example.com"}`)

**Behavior:**

- Calls `updateProfile()` internally with combined data
- Sends PUT request to `/v1/customer-profiles/set`
- Associates user with current session

**Example:**

```swift
// iOS
await MobileTracker.shared.identify(
    userId: "user123",
    profileData: ["email": "user@example.com", "name": "John Doe"]
)
```

### `set(profileData)`

Update user profile data without changing the user ID.

**Parameters:**

- `profileData` (Object, required): Profile data to update (e.g., `{plan: "premium", last_login: "2025-11-27"}`)

**Behavior:**

- Calls `updateProfile()` internally
- Sends PUT request to `/v1/customer-profiles/set`
- Updates existing profile data

**Example:**

```swift
// iOS
await MobileTracker.shared.set(profileData: ["plan": "enterprise"])
```

### `setMetadata(metadata)`

Set session-level metadata that applies to all subsequent events.

**Parameters:**

- `metadata` (Object, required): Metadata object (e.g., `{session_type: "premium", feature_flags: ["new_ui"]}`)

**Behavior:**

- Requires session_id or user_id
- Sends PUT request to `/v1/customer-profiles/set`
- Metadata is included with all future events in this session

**Example:**

```swift
// iOS
await MobileTracker.shared.setMetadata(["session_type": "premium"])
```

### `reset(all)`

Clear all tracking data and optionally reset the brand ID.

**Parameters:**

- `all` (Boolean, optional, default: `false`): If `true`, also clears brand ID

**Behavior:**

- Clears storage: session_id, device_id, session_email, identify_id
- Clears brand_id if `all=true`
- Clears file backup storage
- Resets internal state (pending calls, last tracked URL)
- Creates new tracking session

**Example:**

```swift
// iOS
MobileTracker.shared.reset(all: false)  // Keep brand ID
MobileTracker.shared.reset(all: true)   // Clear everything
```

## Event Structure

All events sent to your backend follow this JSON structure:

```json
{
  "brand_id": 925,
  "session_id": "session-uuid-here",
  "event_name": "BUTTON_CLICK",
  "data": {
    "button_name": "signup",
    "screen": "home",
    "user_id": "user123"
  }
}
```

**Profile Update Structure:**

```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "metadata": {
    "plan": "premium"
  },
  "brand_id": 925,
  "user_id": "user123",
  "session_id": "session-uuid-here"
}
```

**Metadata Structure:**

```json
{
  "metadata": {
    "session_type": "premium",
    "feature_flags": ["new_ui", "dark_mode"]
  },
  "user_id": "user123",
  "brand_id": 925,
  "session_id": "session-uuid-here"
}
```

## Backend API Endpoints

The SDK communicates with the following backend endpoints:

| Endpoint                             | Method | Purpose                            |
| ------------------------------------ | ------ | ---------------------------------- |
| `/v2/tracking-session`               | POST   | Create new tracking session        |
| `/v2/tracking-session-data`          | POST   | Track events                       |
| `/v1/customer-profiles/set`          | PUT    | Update user profile or metadata    |
| `/v2/tracking-session/{id}/location` | PUT    | Update session location (optional) |

## Error Handling

The SDK handles errors gracefully and never crashes the host application:

- **Initialization Errors**: Logged in debug mode, SDK degrades gracefully
- **Network Errors**: Events are queued and retried
- **Invalid Data**: Validation errors are logged, invalid data is rejected
- **Timeout**: 30-second timeout for initialization prevents stuck state

**Best Practices:**

- Always wrap `init()` in try-catch (iOS) or error handling (Android/RN)
- Enable `debug: true` during development to see detailed logs
- Monitor initialization success before tracking critical events

## Requirements

- **iOS**: iOS 13.0+, Swift 5.5+
- **Android**: Android API 21+ (Lollipop), Kotlin 1.8+
- **React Native**: React Native 0.70+

## Project Structure

```
mobile-tracking-sdk/
├── ios/                          # iOS SDK (Swift)
│   ├── MobileTracker/           # Source files
│   │   └── Models/              # Data models
│   ├── Tests/
│   │   ├── MobileTrackerTests/          # Unit tests (XCTest)
│   │   └── MobileTrackerPropertyTests/  # Property-based tests (SwiftCheck)
│   ├── MobileTracker.podspec    # CocoaPods spec
│   └── Package.swift            # Swift Package Manager
│
├── android/                      # Android SDK (Kotlin)
│   ├── src/
│   │   ├── main/java/com/mobiletracker/     # Source files
│   │   │   └── models/                       # Data models
│   │   ├── test/java/com/mobiletracker/     # Unit tests (JUnit)
│   │   └── propertyTest/java/com/mobiletracker/  # Property-based tests (Kotest)
│   └── build.gradle             # Gradle build configuration
│
├── react-native/                 # React Native Bridge
│   ├── ios/                     # iOS bridge implementation
│   ├── android/                 # Android bridge implementation
│   ├── src/                     # TypeScript source
│   ├── __tests__/
│   │   ├── unit/               # Unit tests (Jest)
│   │   └── properties/         # Property-based tests (fast-check)
│   ├── package.json
│   └── tsconfig.json
│
├── examples/                     # Example applications
│   ├── ios/                     # iOS example app
│   ├── android/                 # Android example app
│   └── react-native/            # React Native example app
│
└── package.json                 # Root package configuration
```

## Development

### Running Tests

```bash
# All tests
npm test

# iOS tests only
npm run test:ios

# Android tests only
npm run test:android

# React Native tests only
npm run test:react-native
```

### Testing Frameworks

- **iOS**: XCTest (unit tests) + SwiftCheck (property-based tests)
- **Android**: JUnit + Mockito (unit tests) + Kotest Property Testing (property-based tests)
- **React Native**: Jest (unit tests) + fast-check (property-based tests)

## Troubleshooting

### iOS

**Issue**: Pod install fails

- Ensure you have CocoaPods installed: `sudo gem install cocoapods`
- Try updating your pod repo: `pod repo update`

**Issue**: Build errors after installation

- Clean build folder: Product → Clean Build Folder in Xcode
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### Android

**Issue**: Gradle sync fails

- Ensure you have the correct Maven repository configured
- Check that your `minSdkVersion` is 21 or higher

**Issue**: Runtime crashes

- Verify ProGuard rules if using code obfuscation
- Check that initialization is called before any tracking methods

### React Native

**Issue**: Native module not found

- Run `pod install` in the iOS directory
- Rebuild the app: `npx react-native run-ios` or `npx react-native run-android`
- For older RN versions, try manual linking

**Issue**: TypeScript errors

- Ensure `@types/react-native` is installed
- Check that your `tsconfig.json` includes the correct paths

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

MIT
