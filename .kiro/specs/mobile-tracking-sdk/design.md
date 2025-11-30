# Design Document

## Overview

The Mobile Tracking SDK follows a "Core SDK + Bridges" architecture where native iOS and Android SDKs provide the core tracking functionality, and a thin React Native bridge exposes this functionality to JavaScript. This design ensures:

- Native performance and reliability on both platforms
- Consistent behavior across iOS, Android, and React Native
- Independent usage - native apps can use the SDKs directly without React Native
- Minimal bridge overhead for React Native applications

The SDK provides three main capabilities: event tracking, user identification, and screen tracking. Events are queued in memory and sent to a configurable backend endpoint via HTTP POST requests.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    React Native Layer                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         MobileTracker JavaScript Module                 │ │
│  │  - init(config)                                         │ │
│  │  - track(event, properties)                             │ │
│  │  - identify(userId, traits)                             │ │
│  │  - screen(name, properties)                             │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Native Bridge
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌──────────────────┐                  ┌──────────────────┐
│   iOS SDK        │                  │  Android SDK     │
│   (Swift)        │                  │  (Kotlin)        │
├──────────────────┤                  ├──────────────────┤
│ • Configuration  │                  │ • Configuration  │
│ • Event Queue    │                  │ • Event Queue    │
│ • User Context   │                  │ • User Context   │
│ • HTTP Client    │                  │ • HTTP Client    │
└──────────────────┘                  └──────────────────┘
        │                                       │
        └───────────────────┬───────────────────┘
                            │
                            ▼
                   ┌────────────────┐
                   │ Backend API    │
                   │ (HTTP POST)    │
                   └────────────────┘
```

### Component Layers

1. **Native Core SDKs** (iOS & Android)

   - Implement all tracking logic
   - Manage event queue and user context
   - Handle HTTP communication with backend
   - Provide public API for native apps

2. **React Native Bridge**

   - Thin wrapper around native SDKs
   - Handles JavaScript ↔ Native data serialization
   - Exposes identical API surface to JavaScript
   - No business logic - pure delegation

3. **Backend Communication**
   - Simple HTTP POST to configured endpoint
   - JSON payload format
   - Basic error handling

## Components and Interfaces

### iOS SDK (Swift)

#### Public API

```swift
public class MobileTracker {
    // Singleton instance
    public static let shared = MobileTracker()

    // Initialize SDK
    public func initialize(apiKey: String, endpoint: String) throws

    // Track custom event
    public func track(event: String, properties: [String: Any]?)

    // Identify user
    public func identify(userId: String, traits: [String: Any]?)

    // Track screen view
    public func screen(name: String, properties: [String: Any]?)
}
```

#### Internal Components

```swift
// Configuration storage
class Configuration {
    var apiKey: String
    var endpoint: String
    var maxQueueSize: Int = 100
}

// User context management
class UserContext {
    var userId: String?
    var traits: [String: Any]?
}

// Event queue
class EventQueue {
    private var events: [Event] = []
    private let maxSize: Int

    func enqueue(_ event: Event)
    func dequeue() -> [Event]
    func clear()
}

// HTTP client
class HTTPClient {
    func send(events: [Event], to endpoint: String, apiKey: String, completion: @escaping (Result<Void, Error>) -> Void)
}

// Event model
struct Event: Codable {
    let type: String // "track", "identify", "screen"
    let name: String?
    let userId: String?
    let traits: [String: Any]?
    let properties: [String: Any]?
    let context: EventContext
    let timestamp: String
}

struct EventContext: Codable {
    let platform: String // "ios"
    let osVersion: String
    let appVersion: String?
}
```

### Android SDK (Kotlin)

#### Public API

```kotlin
class MobileTracker private constructor() {
    companion object {
        @Volatile
        private var instance: MobileTracker? = null

        fun getInstance(): MobileTracker {
            return instance ?: synchronized(this) {
                instance ?: MobileTracker().also { instance = it }
            }
        }
    }

    // Initialize SDK
    fun initialize(apiKey: String, endpoint: String)

    // Track custom event
    fun track(event: String, properties: Map<String, Any>?)

    // Identify user
    fun identify(userId: String, traits: Map<String, Any>?)

    // Track screen view
    fun screen(name: String, properties: Map<String, Any>?)
}
```

#### Internal Components

```kotlin
// Configuration storage
data class Configuration(
    val apiKey: String,
    val endpoint: String,
    val maxQueueSize: Int = 100
)

// User context management
data class UserContext(
    var userId: String? = null,
    var traits: Map<String, Any>? = null
)

// Event queue
class EventQueue(private val maxSize: Int) {
    private val events = mutableListOf<Event>()

    fun enqueue(event: Event)
    fun dequeue(): List<Event>
    fun clear()
}

// HTTP client
class HTTPClient {
    fun send(
        events: List<Event>,
        endpoint: String,
        apiKey: String,
        callback: (Result<Unit>) -> Unit
    )
}

// Event model
data class Event(
    val type: String, // "track", "identify", "screen"
    val name: String?,
    val userId: String?,
    val traits: Map<String, Any>?,
    val properties: Map<String, Any>?,
    val context: EventContext,
    val timestamp: String
)

data class EventContext(
    val platform: String, // "android"
    val osVersion: String,
    val appVersion: String?
)
```

### React Native Bridge

#### JavaScript API

```typescript
interface MobileTrackerConfig {
  apiKey: string
  endpoint: string
}

interface MobileTracker {
  // Initialize SDK
  init(config: MobileTrackerConfig): Promise<void>

  // Track custom event
  track(event: string, properties?: Record<string, any>): void

  // Identify user
  identify(userId: string, traits?: Record<string, any>): void

  // Track screen view
  screen(name: string, properties?: Record<string, any>): void
}

export default MobileTracker
```

#### Native Module Implementation

**iOS Bridge (Objective-C/Swift)**

```swift
@objc(MobileTrackerBridge)
class MobileTrackerBridge: NSObject {

    @objc
    func initialize(_ apiKey: String, endpoint: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        do {
            try MobileTracker.shared.initialize(apiKey: apiKey, endpoint: endpoint)
            resolver(nil)
        } catch {
            rejecter("INIT_ERROR", error.localizedDescription, error)
        }
    }

    @objc
    func track(_ event: String, properties: [String: Any]?) {
        MobileTracker.shared.track(event: event, properties: properties)
    }

    @objc
    func identify(_ userId: String, traits: [String: Any]?) {
        MobileTracker.shared.identify(userId: userId, traits: traits)
    }

    @objc
    func screen(_ name: String, properties: [String: Any]?) {
        MobileTracker.shared.screen(name: name, properties: properties)
    }
}
```

**Android Bridge (Kotlin)**

```kotlin
class MobileTrackerBridge(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName() = "MobileTrackerBridge"

    @ReactMethod
    fun initialize(apiKey: String, endpoint: String, promise: Promise) {
        try {
            MobileTracker.getInstance().initialize(apiKey, endpoint)
            promise.resolve(null)
        } catch (e: Exception) {
            promise.reject("INIT_ERROR", e.message, e)
        }
    }

    @ReactMethod
    fun track(event: String, properties: ReadableMap?) {
        val propsMap = properties?.toHashMap()
        MobileTracker.getInstance().track(event, propsMap)
    }

    @ReactMethod
    fun identify(userId: String, traits: ReadableMap?) {
        val traitsMap = traits?.toHashMap()
        MobileTracker.getInstance().identify(userId, traitsMap)
    }

    @ReactMethod
    fun screen(name: String, properties: ReadableMap?) {
        val propsMap = properties?.toHashMap()
        MobileTracker.getInstance().screen(name, propsMap)
    }
}
```

## Data Models

### Event Structure

All events sent to the backend follow this JSON structure:

```json
{
  "type": "track",
  "name": "Button Clicked",
  "userId": "user123",
  "traits": {
    "email": "user@example.com",
    "plan": "pro"
  },
  "properties": {
    "button_name": "signup",
    "screen": "home"
  },
  "context": {
    "platform": "ios",
    "osVersion": "17.0",
    "appVersion": "1.2.3"
  },
  "timestamp": "2025-11-27T10:30:00.000Z"
}
```

### Event Types

1. **Track Event**

   - `type`: "track"
   - `name`: Event name (required)
   - `properties`: Custom event properties (optional)
   - Includes user context if identified

2. **Identify Event**

   - `type`: "identify"
   - `userId`: User identifier (required)
   - `traits`: User attributes (optional)
   - Updates stored user context

3. **Screen Event**
   - `type`: "screen"
   - `name`: Screen name (required)
   - `properties`: Screen properties (optional)
   - Includes user context if identified

### Context Data

Automatically added to all events:

- `platform`: "ios" or "android"
- `osVersion`: Operating system version
- `appVersion`: Application version (if available)
- `timestamp`: ISO 8601 formatted timestamp

##

Correctness Properties

_A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees._

Property 1: Initialization enables tracking
_For any_ valid API key and endpoint, after calling initialize, subsequent track/identify/screen calls should successfully queue events without errors
**Validates: Requirements 1.1, 1.2**

Property 2: Invalid initialization is rejected
_For any_ invalid initialization parameters (empty strings, null values, malformed URLs), the SDK should reject initialization and return a clear error
**Validates: Requirements 1.4**

Property 3: Event data preservation
_For any_ event name and properties object, calling track or screen should create a queued event containing exactly the same name and properties
**Validates: Requirements 2.1, 4.2**

Property 4: Queue growth on tracking
_For any_ initialized SDK with queue size N, tracking an event should result in queue size N+1 (unless max size is reached)
**Validates: Requirements 2.2, 5.1**

Property 5: Context enrichment
_For any_ tracked event (track, identify, or screen), the resulting event should contain context fields including timestamp, platform, and osVersion
**Validates: Requirements 2.3, 4.3**

Property 6: Nested data structure preservation
_For any_ event properties or user traits containing nested objects or arrays, the data structure should be preserved exactly in the queued event
**Validates: Requirements 2.4, 3.4**

Property 7: User identity persistence
_For any_ user ID and traits, after calling identify, all subsequently tracked events should include the same user ID and traits
**Validates: Requirements 3.1, 3.2**

Property 8: Identity updates
_For any_ sequence of identify calls with different user data, the most recent user ID and traits should be included in subsequent events
**Validates: Requirements 3.3**

Property 9: Events are sent to backend
_For any_ queued events, the SDK should make HTTP POST requests to the configured endpoint containing the event data
**Validates: Requirements 5.2**

Property 10: Queue cleanup after send
_For any_ events that are successfully sent to the backend, those events should be removed from the queue
**Validates: Requirements 5.3**

Property 11: Queue eviction policy
_For any_ SDK with max queue size M, when tracking event M+1, the oldest event should be removed from the queue
**Validates: Requirements 5.4**

Property 12: Bridge data preservation
_For any_ data passed through the React Native bridge (init, track, identify, screen), the data received by the native SDK should be equivalent to the data sent from JavaScript
**Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5**

Property 13: Cross-platform payload equivalence
_For any_ event tracked with the same parameters on iOS and Android, the resulting event payloads should be equivalent except for platform-specific context fields
**Validates: Requirements 8.1**

Property 14: Cross-platform queue consistency
_For any_ sequence of tracking operations, the queue behavior (FIFO ordering, size limits, eviction) should be identical on iOS and Android
**Validates: Requirements 8.2**

## Error Handling

### Initialization Errors

- **Invalid API Key**: Empty or null API key should throw/reject with error code `INVALID_API_KEY`
- **Invalid Endpoint**: Empty, null, or malformed URL should throw/reject with error code `INVALID_ENDPOINT`
- **Already Initialized**: Subsequent initialization calls should update configuration without error

### Runtime Errors

- **Network Failures**: Failed HTTP requests should be logged but not crash the app
- **Queue Overflow**: When max queue size is reached, oldest events are silently dropped with a warning log
- **Serialization Errors**: If event data cannot be serialized to JSON, log error and skip that event
- **Bridge Errors**: If React Native bridge fails to serialize data, reject the promise with descriptive error

### Error Response Format

```swift
enum TrackerError: Error {
    case invalidAPIKey
    case invalidEndpoint
    case serializationFailed
    case networkError(underlying: Error)
}
```

```kotlin
sealed class TrackerError : Exception() {
    object InvalidAPIKey : TrackerError()
    object InvalidEndpoint : TrackerError()
    object SerializationFailed : TrackerError()
    data class NetworkError(val underlying: Throwable) : TrackerError()
}
```

## Testing Strategy

### Unit Testing

The SDK will use platform-specific testing frameworks:

- **iOS**: XCTest for unit tests
- **Android**: JUnit + Mockito for unit tests
- **React Native**: Jest for JavaScript bridge tests

Unit tests will cover:

- Initialization with valid and invalid parameters
- Event creation and queueing
- User context management
- HTTP client request formatting
- Error handling edge cases
- Bridge data serialization

### Property-Based Testing

Property-based testing will verify universal properties across all inputs using:

- **iOS**: SwiftCheck (Swift property testing library)
- **Android**: Kotest Property Testing (Kotlin property testing library)
- **React Native**: fast-check (JavaScript property testing library)

Each property-based test will:

- Run a minimum of 100 iterations with randomly generated inputs
- Be tagged with a comment referencing the specific correctness property from this design document
- Use the format: `// Feature: mobile-tracking-sdk, Property N: [property text]`

Property-based tests will verify:

1. **Property 1**: Initialization with random valid credentials enables tracking
2. **Property 2**: Random invalid parameters are rejected
3. **Property 3**: Random event names/properties are preserved
4. **Property 4**: Queue grows correctly for random event sequences
5. **Property 5**: Random events all receive context enrichment
6. **Property 6**: Random nested structures are preserved
7. **Property 7**: Random user identities persist across events
8. **Property 8**: Random identity update sequences use latest values
9. **Property 9**: Random events trigger HTTP requests
10. **Property 10**: Queue cleanup after random successful sends
11. **Property 11**: Random overflow sequences evict oldest events
12. **Property 12**: Random data survives bridge crossing
13. **Property 13**: Same random events produce equivalent payloads cross-platform
14. **Property 14**: Random operation sequences produce consistent queue behavior cross-platform

### Integration Testing

Integration tests will verify:

- End-to-end event flow from API call to HTTP request
- React Native bridge integration with native modules
- Cross-platform behavior consistency
- Real HTTP communication with test backend

### Test Organization

```
ios/
  Tests/
    MobileTrackerTests/          # Unit tests
    MobileTrackerPropertyTests/  # Property-based tests

android/
  src/
    test/                        # Unit tests
    propertyTest/                # Property-based tests

react-native/
  __tests__/
    unit/                        # Unit tests
    properties/                  # Property-based tests
```

## Implementation Notes

### Thread Safety

- **iOS**: Use serial dispatch queue for event queue operations
- **Android**: Use synchronized blocks or concurrent collections for thread-safe queue access
- Both platforms should ensure thread-safe access to user context

### Memory Management

- Event queue has configurable max size (default: 100 events)
- Oldest events are evicted when queue is full (FIFO eviction)
- No persistent storage in this basic version - events are memory-only

### Network Strategy

- Simple HTTP POST with JSON payload
- No automatic retry in this basic version
- No batching - events sent individually or in small groups
- Timeout: 30 seconds for HTTP requests

### Platform-Specific Considerations

**iOS:**

- Use URLSession for HTTP requests
- Support iOS 13.0+
- Swift 5.5+ with async/await support optional

**Android:**

- Use OkHttp or HttpURLConnection for HTTP requests
- Support Android API 21+ (Lollipop)
- Kotlin 1.8+

**React Native:**

- Support React Native 0.70+
- Use TurboModules for better performance (optional)
- Fallback to legacy NativeModules for compatibility

### Package Structure

```
mobile-tracking-sdk/
├── ios/
│   ├── MobileTracker/
│   │   ├── MobileTracker.swift
│   │   ├── Configuration.swift
│   │   ├── UserContext.swift
│   │   ├── EventQueue.swift
│   │   ├── HTTPClient.swift
│   │   └── Models/
│   │       ├── Event.swift
│   │       └── EventContext.swift
│   └── MobileTracker.podspec
├── android/
│   └── src/main/java/com/mobiletracker/
│       ├── MobileTracker.kt
│       ├── Configuration.kt
│       ├── UserContext.kt
│       ├── EventQueue.kt
│       ├── HTTPClient.kt
│       └── models/
│           ├── Event.kt
│           └── EventContext.kt
└── react-native/
    ├── ios/
    │   └── MobileTrackerBridge.swift
    ├── android/
    │   └── MobileTrackerBridge.kt
    ├── src/
    │   └── index.ts
    └── package.json
```

### Configuration Defaults

```typescript
{
  maxQueueSize: 100,        // Maximum events in queue
  requestTimeout: 30000,    // HTTP timeout in milliseconds
  flushOnBackground: false  // Not implemented in basic version
}
```

## Future Enhancements

This basic design can be extended with:

- Persistent offline storage
- Automatic retry with exponential backoff
- Event batching for efficiency
- Background event sending
- Device identifier collection
- Application lifecycle tracking
- Push notification tracking
- Configurable flush intervals
- Debug logging modes
