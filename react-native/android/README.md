# Mobile Tracker React Native Bridge - Android

This directory contains the Android native module bridge for the Mobile Tracking SDK.

## Architecture

The Android bridge follows React Native's native module pattern:

- **MobileTrackerBridge.kt**: The main native module that exposes SDK methods to JavaScript
- **MobileTrackerPackage.kt**: The React Native package that registers the bridge module
- **build.gradle**: Gradle build configuration for the bridge module

## Integration

### 1. Add to settings.gradle

In your React Native app's `android/settings.gradle`:

```gradle
include ':react-native-mobile-tracker'
project(':react-native-mobile-tracker').projectDir = new File(rootProject.projectDir, '../node_modules/@mobiletracker/react-native/android')

// Also include the native Android SDK
include ':mobile-tracker-android'
project(':mobile-tracker-android').projectDir = new File(rootProject.projectDir, '../node_modules/@mobiletracker/react-native/../../android')
```

### 2. Add to app build.gradle

In your app's `android/app/build.gradle`:

```gradle
dependencies {
    implementation project(':react-native-mobile-tracker')
}
```

### 3. Register the package

In your `MainApplication.java` or `MainApplication.kt`:

```kotlin
import com.mobiletracker.bridge.MobileTrackerPackage

class MainApplication : Application(), ReactApplication {
    override fun getPackages(): List<ReactPackage> {
        return PackageList(this).packages.apply {
            // Add the Mobile Tracker package
            add(MobileTrackerPackage())
        }
    }
}
```

## Data Serialization

The bridge handles automatic conversion between JavaScript and native types:

- JavaScript objects → `ReadableMap` → `HashMap<String, Any>`
- JavaScript arrays → `ReadableArray` → `ArrayList<Any>`
- JavaScript primitives → Native Kotlin types

The `ReadableMap.toHashMap()` extension method (provided by React Native) handles this conversion automatically.

## Error Handling

The bridge properly handles and forwards errors from the native SDK:

- `InvalidAPIKey` → Rejected promise with code `INVALID_API_KEY`
- `InvalidEndpoint` → Rejected promise with code `INVALID_ENDPOINT`
- Other errors → Rejected promise with code `INIT_ERROR`

## Thread Safety

React Native automatically handles threading for native modules. By default, native module methods run on a background thread, which is appropriate for the Mobile Tracker SDK's operations.

## Requirements

- Android API 21+ (Lollipop)
- Kotlin 1.8+
- React Native 0.70+
- Mobile Tracker Android SDK
