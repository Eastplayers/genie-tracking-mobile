# Mobile Tracking SDK

[![](https://jitpack.io/v/founderos/mobile-tracking-sdk.svg)](https://jitpack.io/#founderos/mobile-tracking-sdk)

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

### iOS (CocoaPods) - Recommended

**For both React Native and native iOS apps**

Add to your `Podfile`:

```ruby
pod 'FounderOSMobileTracker', '~> 0.1.0'
```

Then run:

```bash
pod install
```

Import in your Swift code:

```swift
import FounderOSMobileTracker
```

**Note**: This library is part of a monorepo. CocoaPods will automatically fetch the correct iOS library files from the repository.

### iOS (Swift Package Manager) - Optional

**For native iOS apps only (not React Native)**

Add the package dependency in Xcode:

1. File → Add Packages...
2. Enter the repository URL: `https://github.com/Eastplayers/genie-tracking-mobile`
3. Select version `0.1.0` or later

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Eastplayers/genie-tracking-mobile", from: "0.1.0")
]
```

Import in your Swift code:

```swift
import MobileTracker  // Note: SPM uses the target name from Package.swift
```

**Note**: The Package.swift file is located in the `/ios` subdirectory of the monorepo. Swift Package Manager is not supported for React Native projects - use CocoaPods instead.

### Android (Gradle)

#### Option 1: JitPack (Recommended)

JitPack builds the library directly from GitHub releases, making it easy to use without complex setup.

**Step 1: Add JitPack Repository**

For Gradle 7.0+ (using `settings.gradle` or `settings.gradle.kts`):

```gradle
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

For older Gradle versions (using project-level `build.gradle`):

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

**Step 2: Add Dependency**

Add to your app module's `build.gradle`:

```gradle
dependencies {
    implementation 'com.github.founderos:mobile-tracking-sdk:0.1.0'
}
```

**Version Resolution:**

JitPack supports multiple version formats:

- **Specific version**: `0.1.0` - Use exact release version
- **Latest release**: `latest` - Always use the most recent release (not recommended for production)
- **Commit hash**: `abc1234` - Use specific commit (for testing unreleased changes)
- **Branch**: `main-SNAPSHOT` - Use latest from a branch (for development)

**Examples:**

```gradle
// Use specific version (recommended for production)
implementation 'com.github.founderos:mobile-tracking-sdk:0.1.0'

// Use latest release (not recommended - may break builds)
implementation 'com.github.founderos:mobile-tracking-sdk:latest'

// Use specific commit (for testing)
implementation 'com.github.founderos:mobile-tracking-sdk:abc1234567'

// Use branch snapshot (for development)
implementation 'com.github.founderos:mobile-tracking-sdk:main-SNAPSHOT'
```

**Checking Build Status:**

Visit [https://jitpack.io/#founderos/mobile-tracking-sdk](https://jitpack.io/#founderos/mobile-tracking-sdk) to:

- View available versions
- Check build status and logs
- See build artifacts

**Troubleshooting:**

If JitPack build fails or dependency cannot be resolved:

1. **Check build status**: Visit the JitPack page for this repository
2. **Verify tag exists**: Ensure the Git tag was pushed to GitHub
3. **Clear Gradle cache**: Run `./gradlew --refresh-dependencies`
4. **Check build logs**: JitPack provides detailed logs for each build
5. **Wait for build**: First-time builds may take 2-5 minutes

#### Option 2: Maven Central

Add to your app's `build.gradle`:

```gradle
dependencies {
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
}
```

Maven Central repository is included by default in most Android projects.

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

## Documentation

Complete documentation is available in the [`docs/`](./docs/) directory:

- **[Documentation Index](./docs/README.md)** - Start here for all documentation
- **[Examples Guide](./docs/EXAMPLES_GUIDE.md)** - Complete guide to running example projects
- **[Local Development](./docs/LOCAL_DEVELOPMENT.md)** - Developing and testing locally
- **[Platform Publishing](./docs/PLATFORM_PUBLISHING.md)** - Publishing guide for all platforms
- **[Configuration Guide](./docs/CONFIGURATION.md)** - Complete configuration reference
- **[API Reference](./API_REFERENCE.md)** - Complete API documentation
- **[Security Policy](./SECURITY.md)** - Security best practices

### Quick Links

- **Getting Started**: [Documentation Index](./docs/README.md)
- **Run Examples**: [Examples Guide](./docs/EXAMPLES_GUIDE.md)
- **Develop Locally**: [Local Development](./docs/LOCAL_DEVELOPMENT.md)
- **Publish Releases**: [Platform Publishing](./docs/PLATFORM_PUBLISHING.md)

### Platform-Specific Documentation

- **iOS**: [Publishing](./ios/PUBLISHING.md) | [Local Development](./ios/LOCAL_DEVELOPMENT.md) | [Quick Reference](./ios/QUICK_REFERENCE.md)
- **Android**: [Publishing](./android/PUBLISHING.md) | [Version Management](./android/VERSION_MANAGEMENT.md) | [Quick Reference](./android/QUICK_REFERENCE.md)
- **React Native**: [Build Guide](./react-native/BUILD_AND_RUN.md) | [Commands](./REACT_NATIVE_COMMANDS.md)

## API Reference

See [API_REFERENCE.md](./API_REFERENCE.md) for detailed documentation of all methods, parameters, and error codes.

## Examples

Complete example applications are available in the `examples/` directory:

- [iOS Example](./examples/ios/README.md) - Native iOS app with SwiftUI
- [Android Example](./examples/android/README.md) - Native Android app with Kotlin
- [React Native Example](./examples/react-native/README.md) - Cross-platform React Native app

See the [Examples Guide](./docs/EXAMPLES_GUIDE.md) for detailed setup and usage instructions.

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

## Monorepo Structure

This library is organized as a **monorepo** containing iOS, Android, and React Native implementations in a single repository. This structure provides several benefits:

- **Single source of truth**: All platforms share the same version and release cycle
- **Coordinated updates**: Changes across platforms can be made in a single commit
- **Simplified maintenance**: One repository to manage instead of three separate ones

### How It Works

When you install the library via CocoaPods or Gradle:

1. The package manager clones the **entire repository**
2. It checks out the specific **version tag** you requested
3. It uses **only the files** specified for that platform (iOS or Android)
4. Other platform directories are ignored

**Example**: When you install via CocoaPods:

- CocoaPods fetches: `https://github.com/Eastplayers/genie-tracking-mobile.git`
- It uses only: `ios/MobileTracker/**/*.{swift,h,m}` (specified in podspec)
- It ignores: `android/`, `react-native/`, `examples/`, etc.

### Project Structure

```
genie-tracking-mobile/              # Monorepo root
├── ios/                            # iOS SDK (Swift)
│   ├── FounderOSMobileTracker.podspec  # CocoaPods spec
│   ├── Package.swift               # Swift Package Manager manifest
│   ├── MobileTracker/              # Source files
│   │   ├── MobileTracker.swift
│   │   ├── Configuration.swift
│   │   └── Models/                 # Data models
│   └── Tests/
│       ├── MobileTrackerTests/          # Unit tests (XCTest)
│       └── MobileTrackerPropertyTests/  # Property-based tests (SwiftCheck)
│
├── android/                        # Android SDK (Kotlin)
│   ├── build.gradle                # Gradle build configuration
│   ├── src/
│   │   ├── main/java/ai/founderos/     # Source files
│   │   │   └── models/                  # Data models
│   │   ├── test/java/ai/founderos/     # Unit tests (JUnit)
│   │   └── propertyTest/java/ai/founderos/  # Property-based tests (Kotest)
│   └── gradle.properties           # Version configuration
│
├── react-native/                   # React Native Bridge
│   ├── ios/                        # iOS bridge implementation
│   ├── android/                    # Android bridge implementation
│   ├── src/                        # TypeScript source
│   ├── __tests__/
│   │   ├── unit/                   # Unit tests (Jest)
│   │   └── properties/             # Property-based tests (fast-check)
│   ├── package.json
│   └── tsconfig.json
│
├── examples/                       # Example applications
│   ├── ios/                        # Native iOS example
│   ├── android/                    # Native Android example
│   └── react-native/               # React Native example
│
├── LICENSE                         # MIT License (repo root)
├── README.md                       # This file
└── package.json                    # Root package configuration
```

### For Library Consumers

You don't need to worry about the monorepo structure! Just install the library normally:

**iOS (CocoaPods)**:

```ruby
pod 'FounderOSMobileTracker', '~> 0.1.0'
```

**Android (JitPack)**:

```gradle
implementation 'com.github.founderos:mobile-tracking-sdk:0.1.0'
```

The package managers handle the monorepo structure automatically.

## Version Management

The library follows [Semantic Versioning 2.0.0](https://semver.org/). For detailed information about version management, including:

- Version format and validation
- When to increment MAJOR, MINOR, or PATCH versions
- Pre-release and build metadata guidelines
- Version update workflow

See [android/VERSION_MANAGEMENT.md](./android/VERSION_MANAGEMENT.md) for the complete guide.

### Creating Releases (For Maintainers)

To publish a new version via JitPack:

**1. Update Version Number**

Edit `android/gradle.properties`:

```properties
VERSION_NAME=0.2.0
```

**2. Validate Version**

```bash
cd android
./gradlew validateVersion
```

**3. Test Locally**

```bash
./gradlew publishToMavenLocal
cd ../examples/android
# Test with the published artifact
```

**4. Commit Changes**

```bash
git add android/gradle.properties
git commit -m "Bump version to 0.2.0"
git push origin main
```

**5. Create and Push Git Tag**

```bash
# Create annotated tag (recommended)
git tag -a v0.2.0 -m "Release version 0.2.0

- Feature: Add new tracking capabilities
- Fix: Resolve session persistence issue
- Docs: Update API documentation"

# Push tag to GitHub
git push origin v0.2.0
```

**6. Verify JitPack Build**

- Visit [https://jitpack.io/#founderos/mobile-tracking-sdk](https://jitpack.io/#founderos/mobile-tracking-sdk)
- Check that the new version appears and builds successfully
- Review build logs if there are any issues

**7. Update Documentation**

Update README and CHANGELOG with the new version number and release notes.

**Tag Naming Convention:**

- Use `v` prefix: `v0.1.0`, `v1.0.0`, `v2.1.3`
- Match the version in `gradle.properties`
- Use annotated tags (with `-a` flag) for better Git history
- Include meaningful release notes in tag message

**Version Resolution:**

Once a tag is pushed, users can reference it in their `build.gradle`:

```gradle
// Exact version (recommended)
implementation 'com.github.founderos:mobile-tracking-sdk:0.2.0'

// Or with 'v' prefix (JitPack handles both)
implementation 'com.github.founderos:mobile-tracking-sdk:v0.2.0'
```

## Development

### Local Development

For library contributors and maintainers:

**iOS Local Development**

Both example projects are configured for local CocoaPods development:

```bash
# Test local changes in React Native
cd examples/react-native/ios
pod install
cd ..
npx react-native run-ios

# Test local changes in native iOS
cd examples/ios/MobileTrackerExample
pod install
open MobileTrackerExample.xcworkspace
```

The Podfiles use local path references:

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

**Run automated local integration tests**:

```bash
./ios/test-local-integration.sh
```

For complete local development documentation, see:

- 📖 [ios/LOCAL_DEVELOPMENT.md](ios/LOCAL_DEVELOPMENT.md) - Local CocoaPods development guide
- 📖 [ios/PUBLISHING.md](ios/PUBLISHING.md) - Publishing guide
- 📖 [ios/QUICK_REFERENCE.md](ios/QUICK_REFERENCE.md) - Quick reference

**Android Local Development**

See [android/PUBLISHING.md](android/PUBLISHING.md) for Android local development and publishing.

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
- For JitPack: Verify the repository URL is `https://jitpack.io` (not `http://`)
- Clear Gradle cache: `./gradlew clean --refresh-dependencies`

**Issue**: JitPack dependency not found

- **Check build status**: Visit [https://jitpack.io/#founderos/mobile-tracking-sdk](https://jitpack.io/#founderos/mobile-tracking-sdk)
- **Verify tag exists**: Run `git tag -l` to list all tags, ensure the version tag was pushed
- **Wait for build**: First-time builds take 2-5 minutes; refresh the JitPack page
- **Check version format**: Use `0.1.0` or `v0.1.0` (both work with JitPack)
- **Review build logs**: Click on the version in JitPack to see detailed build logs
- **Try commit hash**: If tag build fails, try using the commit hash directly

**Issue**: JitPack build fails

- **Check Gradle version**: Ensure `gradle-wrapper.properties` specifies a compatible version
- **Verify build.gradle**: Ensure `group` and `version` are properly set
- **Review dependencies**: Check that all dependencies are available in public repositories
- **Check JDK version**: Verify `jitpack.yml` specifies the correct JDK (if needed)
- **Test locally**: Run `./gradlew publishToMavenLocal` to verify the build works

**Issue**: Runtime crashes

- Verify ProGuard rules if using code obfuscation
- Check that initialization is called before any tracking methods
- Ensure all required permissions are declared in AndroidManifest.xml

### React Native

**Issue**: Native module not found

- Run `pod install` in the iOS directory
- Rebuild the app: `npx react-native run-ios` or `npx react-native run-android`
- For older RN versions, try manual linking

**Issue**: TypeScript errors

- Ensure `@types/react-native` is installed
- Check that your `tsconfig.json` includes the correct paths

## Configuration

The SDK requires minimal configuration:

**Required:**

- `BRAND_ID` - Your brand identifier
- `X_API_KEY` - API key for authentication

**Optional:**

- `API_URL` - Custom API endpoint (defaults to `https://tracking.api.founder-os.ai/api`)

**Quick Example:**

```swift
// iOS - Minimal configuration
let config = TrackerConfig(debug: true, xApiKey: "your_api_key")
try await MobileTracker.shared.initialize(brandId: "your_brand_id", config: config)
```

```kotlin
// Android - Minimal configuration
val config = TrackerConfig(debug = true, xApiKey = "your_api_key")
MobileTracker.getInstance().initialize(context, "your_brand_id", config)
```

```typescript
// React Native - Minimal configuration
await MobileTracker.init({ apiKey: 'your_brand_id', x_api_key: 'your_api_key' })
```

**📖 For detailed configuration:** See [Configuration Guide](docs/CONFIGURATION.md)

## Security

**⚠️ Never hardcode credentials in your source code.**

Use environment variables for all sensitive configuration. See:

- **[Security Policy](SECURITY.md)** - Security best practices
- **[Configuration Guide](docs/CONFIGURATION.md)** - How to use environment variables

**Reporting Security Issues:** security@founder-os.ai

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

MIT
