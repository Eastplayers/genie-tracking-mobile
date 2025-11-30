# Android Bridge Implementation Details

## Overview

The Android bridge for Mobile Tracker SDK follows React Native's native module architecture. It provides a thin wrapper around the native Android SDK, handling data serialization and forwarding method calls.

## Components

### MobileTrackerBridge

The main native module class that implements `ReactContextBaseJavaModule`. Key responsibilities:

1. **Module Registration**: Exposes itself as "MobileTrackerBridge" to JavaScript
2. **Method Forwarding**: Delegates all tracking calls to `MobileTracker.getInstance()`
3. **Data Conversion**: Converts React Native `ReadableMap` to Kotlin `Map<String, Any>`
4. **Error Handling**: Catches native SDK errors and rejects promises appropriately

### MobileTrackerPackage

The React Native package class that implements `ReactPackage`. Responsibilities:

1. **Module Registration**: Returns `MobileTrackerBridge` in `createNativeModules()`
2. **Package Lifecycle**: Integrates with React Native's module system

## Method Implementations

### initialize(apiKey, endpoint, promise)

- **Type**: Async method returning a Promise
- **Behavior**:
  - Calls `MobileTracker.getInstance().initialize()`
  - Resolves promise on success
  - Rejects promise with specific error codes on failure
- **Error Codes**:
  - `INVALID_API_KEY`: Empty or blank API key
  - `INVALID_ENDPOINT`: Empty or blank endpoint
  - `INIT_ERROR`: Other initialization errors

### track(event, properties)

- **Type**: Sync method (fire-and-forget)
- **Behavior**:
  - Converts `ReadableMap` properties to `HashMap`
  - Forwards to `MobileTracker.getInstance().track()`
  - No return value or error handling (follows SDK design)

### identify(userId, traits)

- **Type**: Sync method (fire-and-forget)
- **Behavior**:
  - Converts `ReadableMap` traits to `HashMap`
  - Forwards to `MobileTracker.getInstance().identify()`
  - No return value or error handling

### screen(name, properties)

- **Type**: Sync method (fire-and-forget)
- **Behavior**:
  - Converts `ReadableMap` properties to `HashMap`
  - Forwards to `MobileTracker.getInstance().screen()`
  - No return value or error handling

## Data Serialization

React Native provides automatic conversion between JavaScript and native types:

### JavaScript → Native

```
JavaScript Object  → ReadableMap  → HashMap<String, Any>
JavaScript Array   → ReadableArray → ArrayList<Any>
JavaScript String  → String
JavaScript Number  → Double
JavaScript Boolean → Boolean
JavaScript null    → null
```

### Nested Structures

The bridge preserves nested data structures:

```javascript
// JavaScript
{
  user: {
    name: "John",
    preferences: {
      theme: "dark",
      notifications: true
    }
  }
}

// Becomes Kotlin
mapOf(
  "user" to mapOf(
    "name" to "John",
    "preferences" to mapOf(
      "theme" to "dark",
      "notifications" to true
    )
  )
)
```

The native Android SDK's `Event` class handles this nested structure correctly through its `JsonElement` type system.

## Threading Model

React Native native modules run on a background thread by default, which is appropriate for the Mobile Tracker SDK:

- Network operations (HTTP requests) don't block the UI
- Queue operations are thread-safe (synchronized in `EventQueue`)
- No main thread requirements for the SDK

## Error Handling Strategy

The bridge follows React Native best practices:

1. **Initialization**: Uses Promise rejection for async errors
2. **Tracking Methods**: Fire-and-forget (no error propagation to JS)
3. **Native SDK Errors**: Logged internally, don't crash the app

This matches the design philosophy that tracking failures should not impact app functionality.

## Testing Considerations

The bridge can be tested at multiple levels:

1. **Unit Tests**: Mock `MobileTracker` singleton to verify method forwarding
2. **Integration Tests**: Test with real Android SDK instance
3. **Property Tests**: Verify data serialization preserves structure (Property 12)

## Requirements Validation

This implementation satisfies the following requirements:

- **6.1**: ✅ Exposes `init` method that forwards to native SDK
- **6.2**: ✅ Exposes `track` method that forwards to native SDK
- **6.3**: ✅ Exposes `identify` method that forwards to native SDK
- **6.4**: ✅ Exposes `screen` method that forwards to native SDK
- **6.5**: ✅ Handles data serialization between JavaScript and native

## Comparison with iOS Bridge

The Android bridge mirrors the iOS implementation:

| Feature         | iOS (Objective-C)                 | Android (Kotlin)                  |
| --------------- | --------------------------------- | --------------------------------- |
| Module Name     | MobileTrackerBridge               | MobileTrackerBridge               |
| Initialize      | Promise-based                     | Promise-based                     |
| Track           | Fire-and-forget                   | Fire-and-forget                   |
| Identify        | Fire-and-forget                   | Fire-and-forget                   |
| Screen          | Fire-and-forget                   | Fire-and-forget                   |
| Error Codes     | INVALID_API_KEY, INVALID_ENDPOINT | INVALID_API_KEY, INVALID_ENDPOINT |
| Data Conversion | NSDictionary → [String: Any]      | ReadableMap → Map<String, Any>    |

This ensures cross-platform consistency (Requirement 8.3).
