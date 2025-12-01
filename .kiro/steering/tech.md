# Technology Stack

## Build Systems & Package Managers

### iOS

- **Build System**: Xcode Build System
- **Package Managers**: CocoaPods (primary), Swift Package Manager
- **Language**: Swift 5.5+
- **Minimum Version**: iOS 13.0+

### Android

- **Build System**: Gradle 7.0+
- **Package Managers**: JitPack (primary), Maven Central
- **Language**: Kotlin 1.8+
- **Minimum Version**: Android API 21+ (Lollipop)

### React Native

- **Build System**: Metro bundler
- **Package Manager**: npm
- **Language**: TypeScript 5.2+
- **Minimum Version**: React Native 0.70+

## Key Dependencies

### iOS

- Foundation framework (standard library)
- UIKit (for screen tracking)
- SwiftCheck (property-based testing)

### Android

- AndroidX Core KTX
- Kotlinx Serialization JSON
- Kotlinx Coroutines (Core + Android)
- OkHttp 4.11.0 (HTTP client)
- Google Play Services Location
- Kotest (property-based testing)

### React Native

- React Native bridge (NativeModules)
- fast-check (property-based testing)
- Jest (unit testing)

## Common Commands

### iOS Development

```bash
# Run tests
cd ios && swift test

# Local integration test
./ios/test-local-integration.sh

# Install dependencies in example
cd examples/ios/MobileTrackerExample
pod install

# Build in Xcode
open MobileTrackerExample.xcworkspace
# Press ⌘B to build, ⌘R to run

# Publish to CocoaPods
./ios/publish-cocoapods.sh
```

### Android Development

```bash
# Run unit tests
cd android && ./gradlew test

# Run property-based tests
./gradlew propertyTest

# Validate version format
./gradlew validateVersion

# Publish to local Maven
./gradlew publishToMavenLocal

# Build example app
cd examples/android
./gradlew build
./gradlew installDebug

# Test JitPack build
./android/test-jitpack.sh
```

### React Native Development

```bash
# Install dependencies
cd react-native && npm install

# Build TypeScript
npm run build

# Run tests
npm test

# Run property-based tests
npm run test:property

# Link locally for development
npm link

# Run example app
cd examples/react-native
npm install
npm run ios      # iOS
npm run android  # Android
```

### Monorepo Commands

```bash
# Run all tests
npm test

# Test individual platforms
npm run test:ios
npm run test:android
npm run test:react-native

# Setup git hooks
./setup-git-hooks.sh
```

## Version Management

- Follows Semantic Versioning 2.0.0 (MAJOR.MINOR.PATCH)
- Version defined in `android/gradle.properties` (VERSION_NAME)
- iOS version in `FounderOSMobileTracker.podspec` and `Package.swift`
- React Native version in `react-native/package.json`
- Git tags use `v` prefix (e.g., `v0.1.0`)

## Testing Frameworks

- **iOS**: XCTest (unit) + SwiftCheck (property-based)
- **Android**: JUnit + Mockito (unit) + Kotest Property Testing
- **React Native**: Jest (unit) + fast-check (property-based)

## HTTP Client

- **iOS**: URLSession (native)
- **Android**: OkHttp 4.11.0
- **Timeout**: 30 seconds for initialization

## Storage

Dual storage strategy across all platforms:

- **Primary**: UserDefaults (iOS) / SharedPreferences (Android)
- **Backup**: File-based storage
- **Prefix**: `__GT_{brandId}_` for all keys
