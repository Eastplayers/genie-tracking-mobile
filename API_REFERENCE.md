# API Reference

Complete API documentation for the Mobile Tracking SDK across iOS, Android, and React Native platforms.

This SDK provides session-based tracking with automatic session management, user identification, profile updates, and metadata support.

## Table of Contents

- [Initialization](#initialization)
- [Event Tracking](#event-tracking)
- [User Identification and Profiles](#user-identification-and-profiles)
- [Metadata Management](#metadata-management)
- [Session Management](#session-management)
- [Storage Behavior](#storage-behavior)
- [Error Codes](#error-codes)
- [Configuration Options](#configuration-options)
- [Data Types](#data-types)
- [Backend API Endpoints](#backend-api-endpoints)

---

## Initialization

Initialize the SDK with your brand ID and configuration before using any tracking methods. This should typically be done once during application startup.

**Key Behavior:**

- Validates brand ID (must be non-empty numeric string)
- Merges provided config with defaults
- Creates or restores backend tracking session automatically
- Sets up automatic page/screen view tracking
- Returns immediately if already initialized
- Waits if initialization is in progress (with 30-second timeout)

### iOS

```swift
func initialize(brandId: String, config: TrackerConfig?) async throws
```

**Parameters:**

- `brandId` (String, required): Your unique brand identifier (must be numeric, e.g., "925")
- `config` (TrackerConfig?, optional): Configuration options

**Throws:**

- `TrackerError.invalidBrandId`: When brandId is empty or not numeric
- `TrackerError.invalidConfiguration`: When configuration validation fails
- `TrackerError.sessionCreationFailed`: When backend session creation fails

**Behavior:**

- Checks for existing session in storage before creating new one
- If no session exists, creates new backend session via POST `/v2/tracking-session`
- Stores session ID in dual storage (UserDefaults + file backup)
- Initializes automatic screen tracking via UIViewController swizzling
- Flushes any pending track calls after session is ready

**Example:**

```swift
import MobileTracker

Task {
    do {
        try await MobileTracker.shared.initialize(
            brandId: "925",
            config: TrackerConfig(
                debug: true,
                apiUrl: "https://api.yourbackend.com",
                xApiKey: "your-api-key",
                crossSiteCookie: false,
                cookieExpiration: 365
            )
        )
        print("Tracker initialized with session")
    } catch {
        print("Initialization failed: \(error)")
    }
}
```

### Android

```kotlin
suspend fun initialize(context: Context, brandId: String, config: Configuration?)
```

**Parameters:**

- `context` (Context, required): Android application context
- `brandId` (String, required): Your unique brand identifier (must be numeric, e.g., "925")
- `config` (Configuration?, optional): Configuration options

**Throws:**

- `TrackerError.InvalidBrandId`: When brandId is empty or not numeric
- `TrackerError.InvalidConfiguration`: When configuration validation fails
- `TrackerError.SessionCreationFailed`: When backend session creation fails

**Behavior:**

- Checks for existing session in storage before creating new one
- If no session exists, creates new backend session via POST `/v2/tracking-session`
- Stores session ID in dual storage (SharedPreferences + file backup)
- Initializes automatic screen tracking via ActivityLifecycleCallbacks
- Flushes any pending track calls after session is ready

**Example:**

```kotlin
import com.mobiletracker.MobileTracker
import com.mobiletracker.Configuration
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

GlobalScope.launch {
    try {
        MobileTracker.getInstance().initialize(
            context = applicationContext,
            brandId = "925",
            config = Configuration(
                debug = true,
                apiUrl = "https://api.yourbackend.com",
                xApiKey = "your-api-key",
                crossSiteCookie = false,
                cookieExpiration = 365
            )
        )
        Log.d("Tracker", "Initialized with session")
    } catch (e: Exception) {
        Log.e("Tracker", "Initialization failed", e)
    }
}
```

### React Native

```typescript
init(brandId: string, config?: TrackerConfig): Promise<void>
```

**Parameters:**

- `brandId` (string, required): Your unique brand identifier (must be numeric, e.g., "925")
- `config` (TrackerConfig, optional): Configuration object
  - `debug` (boolean, optional): Enable debug logging
  - `apiUrl` (string, required): Backend API base URL
  - `xApiKey` (string, required): API key for authentication
  - `crossSiteCookie` (boolean, optional): Enable cross-domain tracking
  - `cookieDomain` (string, optional): Custom cookie domain
  - `cookieExpiration` (number, optional): Cookie expiration in days (default: 365)

**Returns:** Promise that resolves when initialization is complete

**Rejects:** Promise rejects with error code and message if initialization fails

**Behavior:**

- Checks for existing session in storage before creating new one
- If no session exists, creates new backend session via POST `/v2/tracking-session`
- Stores session ID in native storage (bridges to iOS/Android storage)
- Initializes automatic screen tracking
- Flushes any pending track calls after session is ready

**Example:**

```typescript
import MobileTracker from '@mobiletracker/react-native'

try {
  await MobileTracker.init('925', {
    debug: true,
    apiUrl: 'https://api.yourbackend.com',
    xApiKey: 'your-api-key',
    crossSiteCookie: false,
    cookieExpiration: 365,
  })
  console.log('Tracker initialized with session')
} catch (error) {
  console.error('Initialization failed:', error)
}
```

---

## Event Tracking

Track custom events with optional attributes and metadata. Events require an active session and are automatically queued if the session is not ready.

**Key Behavior:**

- Requires active session (events queued if session not ready)
- Merges attributes and metadata into event data
- Sends POST request to `/v2/tracking-session-data`
- Includes brand_id and session_id automatically

### iOS

```swift
func track(eventName: String, attributes: [String: Any]?, metadata: [String: Any]?) async
```

**Parameters:**

- `eventName` (String, required): The name of the event (e.g., "BUTTON_CLICK", "PAGE_VIEW", "PURCHASE")
- `attributes` ([String: Any]?, optional): Event properties (e.g., button name, product ID, value)
- `metadata` ([String: Any]?, optional): Technical metadata (e.g., flow context, session context)

**Properties Support:**

- Strings, numbers, booleans
- Nested objects (dictionaries)
- Arrays
- Null values

**Behavior:**

- If initialization is pending, event is queued
- If not initialized, warning is logged and event is dropped
- If no session ID, event is queued until session is available
- Attributes and metadata are merged into single data object
- Sends to `/v2/tracking-session-data` with brand_id and session_id

**Example:**

```swift
// Simple event
await MobileTracker.shared.track(
    eventName: "BUTTON_CLICK",
    attributes: nil,
    metadata: nil
)

// Event with attributes
await MobileTracker.shared.track(
    eventName: "PRODUCT_VIEWED",
    attributes: [
        "product_id": "12345",
        "product_name": "Blue Widget",
        "price": 29.99,
        "category": "Widgets",
        "in_stock": true
    ],
    metadata: nil
)

// Event with attributes and metadata
await MobileTracker.shared.track(
    eventName: "PURCHASE",
    attributes: [
        "order_id": "ORD-789",
        "total": 149.99,
        "items": [
            ["id": "12345", "quantity": 2],
            ["id": "67890", "quantity": 1]
        ]
    ],
    metadata: [
        "flow_id": "checkout_v2",
        "experiment": "new_checkout"
    ]
)
```

### Android

```kotlin
suspend fun track(eventName: String, attributes: Map<String, Any>?, metadata: Map<String, Any>?)
```

**Parameters:**

- `eventName` (String, required): The name of the event (e.g., "BUTTON_CLICK", "PAGE_VIEW", "PURCHASE")
- `attributes` (Map<String, Any>?, optional): Event properties (e.g., button name, product ID, value)
- `metadata` (Map<String, Any>?, optional): Technical metadata (e.g., flow context, session context)

**Properties Support:**

- Strings, numbers, booleans
- Nested objects (maps)
- Lists
- Null values

**Behavior:**

- If initialization is pending, event is queued
- If not initialized, warning is logged and event is dropped
- If no session ID, event is queued until session is available
- Attributes and metadata are merged into single data object
- Sends to `/v2/tracking-session-data` with brand_id and session_id

**Example:**

```kotlin
// Simple event
GlobalScope.launch {
    MobileTracker.getInstance().track(
        eventName = "BUTTON_CLICK",
        attributes = null,
        metadata = null
    )
}

// Event with attributes
GlobalScope.launch {
    MobileTracker.getInstance().track(
        eventName = "PRODUCT_VIEWED",
        attributes = mapOf(
            "product_id" to "12345",
            "product_name" to "Blue Widget",
            "price" to 29.99,
            "category" to "Widgets",
            "in_stock" to true
        ),
        metadata = null
    )
}

// Event with attributes and metadata
GlobalScope.launch {
    MobileTracker.getInstance().track(
        eventName = "PURCHASE",
        attributes = mapOf(
            "order_id" to "ORD-789",
            "total" to 149.99,
            "items" to listOf(
                mapOf("id" to "12345", "quantity" to 2),
                mapOf("id" to "67890", "quantity" to 1)
            )
        ),
        metadata = mapOf(
            "flow_id" to "checkout_v2",
            "experiment" to "new_checkout"
        )
    )
}
```

### React Native

```typescript
track(eventName: string, attributes?: Record<string, any>, metadata?: Record<string, any>): Promise<void>
```

**Parameters:**

- `eventName` (string, required): The name of the event (e.g., "BUTTON_CLICK", "PAGE_VIEW", "PURCHASE")
- `attributes` (Record<string, any>, optional): Event properties (e.g., button name, product ID, value)
- `metadata` (Record<string, any>, optional): Technical metadata (e.g., flow context, session context)

**Properties Support:**

- Strings, numbers, booleans
- Nested objects
- Arrays
- Null/undefined values

**Behavior:**

- If initialization is pending, event is queued
- If not initialized, warning is logged and event is dropped
- If no session ID, event is queued until session is available
- Attributes and metadata are merged into single data object
- Sends to `/v2/tracking-session-data` with brand_id and session_id

**Example:**

```typescript
// Simple event
await MobileTracker.track('BUTTON_CLICK')

// Event with attributes
await MobileTracker.track('PRODUCT_VIEWED', {
  product_id: '12345',
  product_name: 'Blue Widget',
  price: 29.99,
  category: 'Widgets',
  in_stock: true,
})

// Event with attributes and metadata
await MobileTracker.track(
  'PURCHASE',
  {
    order_id: 'ORD-789',
    total: 149.99,
    items: [
      { id: '12345', quantity: 2 },
      { id: '67890', quantity: 1 },
    ],
  },
  {
    flow_id: 'checkout_v2',
    experiment: 'new_checkout',
  }
)
```

---

## User Identification and Profiles

Associate events with a specific user and manage their profile data. The SDK provides three methods for user management: `identify()`, `set()`, and `updateProfile()`.

### `identify()` - Identify User

Associate a user ID with the current session and optionally update profile data.

#### iOS

```swift
func identify(userId: String, profileData: [String: Any]?) async
```

**Parameters:**

- `userId` (String, required): Unique identifier for the user
- `profileData` ([String: Any]?, optional): User profile data (name, email, phone, etc.)

**Behavior:**

- Calls `updateProfile()` internally with combined data
- Sends PUT request to `/v1/customer-profiles/set`
- Associates user with current session
- If user_id differs from stored identify_id, calls `identifyById()` first

**Example:**

```swift
// Basic identification
await MobileTracker.shared.identify(userId: "user123", profileData: nil)

// Identification with profile data
await MobileTracker.shared.identify(
    userId: "user123",
    profileData: [
        "email": "user@example.com",
        "name": "John Doe",
        "phone": "+1234567890",
        "plan": "pro",
        "signup_date": "2025-01-15"
    ]
)
```

#### Android

```kotlin
suspend fun identify(userId: String, profileData: Map<String, Any>?)
```

**Parameters:**

- `userId` (String, required): Unique identifier for the user
- `profileData` (Map<String, Any>?, optional): User profile data (name, email, phone, etc.)

**Behavior:**

- Calls `updateProfile()` internally with combined data
- Sends PUT request to `/v1/customer-profiles/set`
- Associates user with current session
- If user_id differs from stored identify_id, calls `identifyById()` first

**Example:**

```kotlin
// Basic identification
GlobalScope.launch {
    MobileTracker.getInstance().identify("user123", null)
}

// Identification with profile data
GlobalScope.launch {
    MobileTracker.getInstance().identify(
        userId = "user123",
        profileData = mapOf(
            "email" to "user@example.com",
            "name" to "John Doe",
            "phone" to "+1234567890",
            "plan" to "pro",
            "signup_date" to "2025-01-15"
        )
    )
}
```

#### React Native

```typescript
identify(userId: string, profileData?: Record<string, any>): Promise<void>
```

**Parameters:**

- `userId` (string, required): Unique identifier for the user
- `profileData` (Record<string, any>, optional): User profile data (name, email, phone, etc.)

**Behavior:**

- Calls `updateProfile()` internally with combined data
- Sends PUT request to `/v1/customer-profiles/set`
- Associates user with current session
- If user_id differs from stored identify_id, calls `identifyById()` first

**Example:**

```typescript
// Basic identification
await MobileTracker.identify('user123')

// Identification with profile data
await MobileTracker.identify('user123', {
  email: 'user@example.com',
  name: 'John Doe',
  phone: '+1234567890',
  plan: 'pro',
  signup_date: '2025-01-15',
})
```

### `set()` - Update Profile

Update user profile data without changing the user ID.

#### iOS

```swift
func set(profileData: [String: Any]) async
```

**Parameters:**

- `profileData` ([String: Any], required): Profile data to update

**Behavior:**

- Calls `updateProfile()` internally
- Sends PUT request to `/v1/customer-profiles/set`
- Updates existing profile without changing user_id

**Example:**

```swift
await MobileTracker.shared.set(profileData: [
    "plan": "enterprise",
    "last_login": "2025-11-27",
    "preferences": [
        "theme": "dark",
        "language": "en"
    ]
])
```

#### Android

```kotlin
suspend fun set(profileData: Map<String, Any>)
```

**Parameters:**

- `profileData` (Map<String, Any>, required): Profile data to update

**Behavior:**

- Calls `updateProfile()` internally
- Sends PUT request to `/v1/customer-profiles/set`
- Updates existing profile without changing user_id

**Example:**

```kotlin
GlobalScope.launch {
    MobileTracker.getInstance().set(
        profileData = mapOf(
            "plan" to "enterprise",
            "last_login" to "2025-11-27",
            "preferences" to mapOf(
                "theme" to "dark",
                "language" to "en"
            )
        )
    )
}
```

#### React Native

```typescript
set(profileData: Record<string, any>): Promise<void>
```

**Parameters:**

- `profileData` (Record<string, any>, required): Profile data to update

**Behavior:**

- Calls `updateProfile()` internally
- Sends PUT request to `/v1/customer-profiles/set`
- Updates existing profile without changing user_id

**Example:**

```typescript
await MobileTracker.set({
  plan: 'enterprise',
  last_login: '2025-11-27',
  preferences: {
    theme: 'dark',
    language: 'en',
  },
})
```

---

## Metadata Management

Set session-level metadata that applies to all subsequent events in the current session.

### iOS

```swift
func setMetadata(_ metadata: [String: Any]) async
```

**Parameters:**

- `metadata` ([String: Any], required): Metadata object with session context

**Behavior:**

- Requires session_id or user_id (logs error if neither exists)
- Sends PUT request to `/v1/customer-profiles/set` with metadata
- Metadata is included with all future events in this session

**Example:**

```swift
await MobileTracker.shared.setMetadata([
    "session_type": "premium",
    "feature_flags": ["new_ui", "dark_mode"],
    "experiment_group": "variant_a"
])
```

### Android

```kotlin
suspend fun setMetadata(metadata: Map<String, Any>)
```

**Parameters:**

- `metadata` (Map<String, Any>, required): Metadata object with session context

**Behavior:**

- Requires session_id or user_id (logs error if neither exists)
- Sends PUT request to `/v1/customer-profiles/set` with metadata
- Metadata is included with all future events in this session

**Example:**

```kotlin
GlobalScope.launch {
    MobileTracker.getInstance().setMetadata(
        metadata = mapOf(
            "session_type" to "premium",
            "feature_flags" to listOf("new_ui", "dark_mode"),
            "experiment_group" to "variant_a"
        )
    )
}
```

### React Native

```typescript
setMetadata(metadata: Record<string, any>): Promise<void>
```

**Parameters:**

- `metadata` (Record<string, any>, required): Metadata object with session context

**Behavior:**

- Requires session_id or user_id (logs error if neither exists)
- Sends PUT request to `/v1/customer-profiles/set` with metadata
- Metadata is included with all future events in this session

**Example:**

```typescript
await MobileTracker.setMetadata({
  session_type: 'premium',
  feature_flags: ['new_ui', 'dark_mode'],
  experiment_group: 'variant_a',
})
```

---

## Session Management

Manage tracking sessions and reset user data.

### `reset()` - Clear Tracking Data

Clear all tracking data and optionally reset the brand ID. Useful for logout scenarios.

#### iOS

```swift
func reset(all: Bool = false)
```

**Parameters:**

- `all` (Bool, optional, default: false): If true, also clears brand_id

**Behavior:**

- Clears storage: session_id, device_id, session_email, identify_id
- Clears brand_id if `all=true`
- Clears file backup storage with brand prefix
- Resets internal state: isInitPending, pendingTrackCalls, lastTrackedUrl
- Creates new tracking session

**Example:**

```swift
// Clear session but keep brand ID (typical logout)
MobileTracker.shared.reset(all: false)

// Clear everything including brand ID (complete reset)
MobileTracker.shared.reset(all: true)
```

#### Android

```kotlin
fun reset(all: Boolean = false)
```

**Parameters:**

- `all` (Boolean, optional, default: false): If true, also clears brand_id

**Behavior:**

- Clears storage: session_id, device_id, session_email, identify_id
- Clears brand_id if `all=true`
- Clears file backup storage with brand prefix
- Resets internal state: isInitPending, pendingTrackCalls, lastTrackedUrl
- Creates new tracking session

**Example:**

```kotlin
// Clear session but keep brand ID (typical logout)
MobileTracker.getInstance().reset(all = false)

// Clear everything including brand ID (complete reset)
MobileTracker.getInstance().reset(all = true)
```

#### React Native

```typescript
reset(all?: boolean): void
```

**Parameters:**

- `all` (boolean, optional, default: false): If true, also clears brand_id

**Behavior:**

- Clears storage: session_id, device_id, session_email, identify_id
- Clears brand_id if `all=true`
- Clears file backup storage with brand prefix
- Resets internal state: isInitPending, pendingTrackCalls, lastTrackedUrl
- Creates new tracking session

**Example:**

```typescript
// Clear session but keep brand ID (typical logout)
MobileTracker.reset(false)

// Clear everything including brand ID (complete reset)
MobileTracker.reset(true)
```

---

## Storage Behavior

The SDK uses a **dual storage approach** for reliability, inspired by the web implementation's cookie + localStorage pattern.

### Storage Architecture

**iOS:**

- **Primary Storage**: UserDefaults (equivalent to cookies)
- **Backup Storage**: File-based storage (equivalent to localStorage)
- **Prefix Format**: `__GT_{brandId}_`

**Android:**

- **Primary Storage**: SharedPreferences (equivalent to cookies)
- **Backup Storage**: File-based storage (equivalent to localStorage)
- **Prefix Format**: `__GT_{brandId}_`

### Storage Keys

The following keys are stored with the brand prefix:

| Key             | Description                     | Expiration |
| --------------- | ------------------------------- | ---------- |
| `session_id`    | Backend session identifier      | 365 days   |
| `device_id`     | Persistent device UUID          | 365 days   |
| `session_email` | Email associated with session   | 365 days   |
| `identify_id`   | User identifier from identify() | 365 days   |
| `brand_id`      | Brand identifier                | 365 days   |

### Storage Operations

**Save:**

1. Write to primary storage (UserDefaults/SharedPreferences)
2. Write to backup storage (file)
3. Both operations must succeed for reliability

**Retrieve:**

1. Check primary storage first
2. If not found, check backup storage
3. Return value from whichever storage has it

**Remove:**

1. Remove from primary storage
2. Remove from backup storage
3. Both operations are performed

**Clear:**

1. Remove all keys with brand prefix from primary storage
2. Remove all files with brand prefix from backup storage

### Data Persistence

- Data persists across app restarts
- Session IDs are restored on app launch
- Device IDs remain constant for device lifetime
- Storage is cleared only via `reset()` or manual deletion

---

## Automatic Screen Tracking

The SDK automatically tracks screen/page views without manual instrumentation.

**Event Name**: `VIEW_PAGE`

**iOS Implementation:**

- Uses UIViewController method swizzling
- Detects `viewDidAppear` calls
- Tracks screen name and properties automatically

**Android Implementation:**

- Uses ActivityLifecycleCallbacks
- Detects Activity `onResume` events
- Tracks screen name and properties automatically

**Behavior:**

- Initial page view tracked on initialization
- Subsequent views tracked on navigation
- URL/screen name included in event data
- Duplicate consecutive views are filtered

**Manual Tracking:**
You can still manually track screen views if needed:

```swift
// iOS
await MobileTracker.shared.track(
    eventName: "VIEW_PAGE",
    attributes: ["screen": "ProductDetails", "product_id": "12345"]
)
```

---

## Screen Tracking (Legacy)

**Note:** Screen tracking is now automatic. The legacy `screen()` method is no longer needed but can still be used if you prefer manual tracking.

---

## Error Codes

### iOS Error Codes

```swift
enum TrackerError: Error {
    case invalidBrandId
    case invalidConfiguration
    case sessionCreationFailed
    case serializationFailed
    case networkError(underlying: Error)
}
```

| Error Code              | Description                             | Resolution                                            |
| ----------------------- | --------------------------------------- | ----------------------------------------------------- |
| `invalidBrandId`        | Brand ID is empty or not numeric        | Provide a valid numeric brand ID (e.g., "925")        |
| `invalidConfiguration`  | Configuration validation failed         | Check configuration options match expected format     |
| `sessionCreationFailed` | Backend session creation failed         | Check network connectivity and API credentials        |
| `serializationFailed`   | Event data cannot be serialized to JSON | Check that properties contain only serializable types |
| `networkError`          | HTTP request failed                     | Check network connectivity and endpoint availability  |

### Android Error Codes

```kotlin
sealed class TrackerError : Exception() {
    object InvalidBrandId : TrackerError()
    object InvalidConfiguration : TrackerError()
    object SessionCreationFailed : TrackerError()
    object SerializationFailed : TrackerError()
    data class NetworkError(val underlying: Throwable) : TrackerError()
}
```

| Error Code              | Description                             | Resolution                                            |
| ----------------------- | --------------------------------------- | ----------------------------------------------------- |
| `InvalidBrandId`        | Brand ID is empty or not numeric        | Provide a valid numeric brand ID (e.g., "925")        |
| `InvalidConfiguration`  | Configuration validation failed         | Check configuration options match expected format     |
| `SessionCreationFailed` | Backend session creation failed         | Check network connectivity and API credentials        |
| `SerializationFailed`   | Event data cannot be serialized to JSON | Check that properties contain only serializable types |
| `NetworkError`          | HTTP request failed                     | Check network connectivity and endpoint availability  |

### React Native Error Codes

| Error Code                | Description                      | Resolution                                     |
| ------------------------- | -------------------------------- | ---------------------------------------------- |
| `INIT_ERROR`              | Initialization failed            | Check brand ID, API key, and endpoint validity |
| `INVALID_BRAND_ID`        | Brand ID is empty or not numeric | Provide a valid numeric brand ID (e.g., "925") |
| `INVALID_CONFIGURATION`   | Configuration validation failed  | Check configuration options                    |
| `SESSION_CREATION_FAILED` | Backend session creation failed  | Check network connectivity and API credentials |
| `SERIALIZATION_ERROR`     | Data cannot be serialized        | Check that properties are JSON-serializable    |
| `NETWORK_ERROR`           | HTTP request failed              | Check network connectivity                     |

**Example Error Handling:**

```typescript
try {
  await MobileTracker.init('925', {
    debug: true,
    apiUrl: 'https://api.yourbackend.com',
    xApiKey: 'your-api-key',
  })
} catch (error: any) {
  switch (error.code) {
    case 'INVALID_BRAND_ID':
      console.error('Please provide a valid numeric brand ID')
      break
    case 'INVALID_CONFIGURATION':
      console.error('Configuration validation failed')
      break
    case 'SESSION_CREATION_FAILED':
      console.error('Failed to create backend session')
      break
    default:
      console.error('Initialization failed:', error.message)
  }
}
```

### Error Handling Best Practices

1. **Never Crash**: The SDK is designed to never crash the host application
2. **Graceful Degradation**: Errors are logged in debug mode, SDK continues operating
3. **Event Queueing**: Events are queued if session is not ready
4. **Timeout Protection**: 30-second timeout prevents stuck initialization
5. **Debug Logging**: Enable `debug: true` to see detailed error messages

---

## Configuration Options

The SDK accepts the following configuration options during initialization:

| Option             | Type    | Default | Required | Description                                            |
| ------------------ | ------- | ------- | -------- | ------------------------------------------------------ |
| `debug`            | Boolean | `false` | No       | Enable detailed logging for debugging                  |
| `apiUrl`           | String  | -       | Yes      | Backend API base URL (e.g., `https://api.example.com`) |
| `xApiKey`          | String  | -       | Yes      | API key for authentication                             |
| `crossSiteCookie`  | Boolean | `false` | No       | Enable cross-domain tracking                           |
| `cookieDomain`     | String  | `null`  | No       | Custom cookie domain for cross-domain tracking         |
| `cookieExpiration` | Integer | `365`   | No       | Cookie/storage expiration in days                      |

### Configuration Examples

**iOS:**

```swift
let config = TrackerConfig(
    debug: true,
    apiUrl: "https://api.example.com",
    xApiKey: "your-api-key",
    crossSiteCookie: false,
    cookieDomain: nil,
    cookieExpiration: 365
)

try await MobileTracker.shared.initialize(brandId: "925", config: config)
```

**Android:**

```kotlin
val config = Configuration(
    debug = true,
    apiUrl = "https://api.example.com",
    xApiKey = "your-api-key",
    crossSiteCookie = false,
    cookieDomain = null,
    cookieExpiration = 365
)

MobileTracker.getInstance().initialize(
    context = applicationContext,
    brandId = "925",
    config = config
)
```

**React Native:**

```typescript
await MobileTracker.init('925', {
  debug: true,
  apiUrl: 'https://api.example.com',
  xApiKey: 'your-api-key',
  crossSiteCookie: false,
  cookieDomain: null,
  cookieExpiration: 365,
})
```

### Configuration Behavior

**Debug Mode:**

- When `debug: true`, detailed logs are printed to console
- Includes initialization steps, API calls, errors, and warnings
- Should be disabled in production

**API URL:**

- Must be a valid HTTPS URL
- Should not include trailing slash
- Example: `https://api.example.com` (not `https://api.example.com/`)

**API Key:**

- Sent in `X-API-Key` header with all requests
- Required for backend authentication

**Cross-Site Cookie:**

- Enables cross-domain session tracking
- Useful for tracking users across multiple domains
- Requires proper cookie domain configuration

**Cookie Domain:**

- Custom domain for cookie storage
- Example: `.example.com` (note the leading dot)
- If not set, uses current domain

**Cookie Expiration:**

- Number of days before stored data expires
- Default: 365 days (1 year)
- Applies to session_id, device_id, and other stored values

### Queue Behavior

- **Queue Type**: FIFO (First In, First Out)
- **Auto-Flush**: Events queued before session is ready are automatically sent once session is available
- **Thread Safety**: All queue operations are thread-safe
- **Persistence**: Events are stored in memory only (not persisted to disk)

### Network Behavior

- **Protocol**: HTTP POST/PUT with JSON payload
- **Headers**:
  - `Content-Type: application/json`
  - `X-API-Key: <your-api-key>`
- **Timeout**: 30 seconds for initialization, standard timeout for API calls
- **Retry**: Events are queued and retried if session is not ready
- **Error Handling**: Network errors are logged, SDK continues operating

---

## Data Types

### TrackerConfig

Configuration object for SDK initialization.

**iOS:**

```swift
struct TrackerConfig {
    var debug: Bool = false
    var apiUrl: String?
    var xApiKey: String?
    var crossSiteCookie: Bool = false
    var cookieDomain: String?
    var cookieExpiration: Int = 365
}
```

**Android:**

```kotlin
data class TrackerConfig(
    val debug: Boolean = false,
    val apiUrl: String? = null,
    val xApiKey: String? = null,
    val crossSiteCookie: Boolean = false,
    val cookieDomain: String? = null,
    val cookieExpiration: Int = 365
)
```

**React Native:**

```typescript
interface TrackerConfig {
  debug?: boolean
  apiUrl: string
  xApiKey: string
  crossSiteCookie?: boolean
  cookieDomain?: string
  cookieExpiration?: number
}
```

### DeviceInfo

Device information collected during session creation.

**iOS:**

```swift
struct DeviceInfo: Codable {
    let deviceId: String
    let osName: String
    let deviceType: String
}
```

**Android:**

```kotlin
data class DeviceInfo(
    val deviceId: String,
    val osName: String,
    val deviceType: String
)
```

### LocationData

Geolocation data (optional feature).

**iOS:**

```swift
struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
}
```

**Android:**

```kotlin
data class LocationData(
    val latitude: Double,
    val longitude: Double,
    val accuracy: Double
)
```

### UpdateProfileData

User profile data structure.

**iOS:**

```swift
struct UpdateProfileData: Codable {
    var name: String?
    var phone: String?
    var gender: String?
    var businessDomain: String?
    var metadata: [String: Any]?
    var email: String?
    var source: String?
    var birthday: String?
    var userId: String?
}
```

**Android:**

```kotlin
data class UpdateProfileData(
    val name: String? = null,
    val phone: String? = null,
    val gender: String? = null,
    val businessDomain: String? = null,
    val metadata: Map<String, Any>? = null,
    val email: String? = null,
    val source: String? = null,
    val birthday: String? = null,
    val userId: String? = null
)
```

### Event Payload Structure

**Track Event:**

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

**Profile Update:**

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

**Metadata Update:**

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

**Session Creation Request:**

```json
{
  "device_id": "uuid-string",
  "os_name": "iOS",
  "device_type": "Mobile",
  "brand_id": 925
}
```

**Session Creation Response:**

```json
{
  "data": {
    "id": "session-uuid"
  }
}
```

### Supported Property Types

The following data types are supported in `attributes`, `metadata`, and `profileData`:

| Type           | iOS | Android | React Native | Example                      |
| -------------- | --- | ------- | ------------ | ---------------------------- |
| String         | ✅  | ✅      | ✅           | `"hello"`                    |
| Number         | ✅  | ✅      | ✅           | `42`, `3.14`                 |
| Boolean        | ✅  | ✅      | ✅           | `true`, `false`              |
| Null           | ✅  | ✅      | ✅           | `null`                       |
| Array          | ✅  | ✅      | ✅           | `[1, 2, 3]`                  |
| Object         | ✅  | ✅      | ✅           | `{"key": "value"}`           |
| Nested Objects | ✅  | ✅      | ✅           | `{"user": {"name": "John"}}` |

---

## Backend API Endpoints

The SDK communicates with the following backend endpoints:

### 1. Create Tracking Session

**Endpoint:** `POST /v2/tracking-session`

**Purpose:** Create a new backend tracking session

**Request Headers:**

- `Content-Type: application/json`
- `X-API-Key: <your-api-key>`

**Request Body:**

```json
{
  "device_id": "uuid-string",
  "os_name": "iOS",
  "device_type": "Mobile",
  "brand_id": 925
}
```

**Response:**

```json
{
  "data": {
    "id": "session-uuid"
  }
}
```

**Called:** During initialization if no existing session is found

---

### 2. Track Event

**Endpoint:** `POST /v2/tracking-session-data`

**Purpose:** Track custom events with attributes and metadata

**Request Headers:**

- `Content-Type: application/json`
- `X-API-Key: <your-api-key>`

**Request Body:**

```json
{
  "brand_id": 925,
  "session_id": "session-uuid",
  "event_name": "BUTTON_CLICK",
  "data": {
    "button_name": "signup",
    "screen": "home"
  }
}
```

**Response:** Success/error status

**Called:** When `track()` is called

---

### 3. Update Profile

**Endpoint:** `PUT /v1/customer-profiles/set`

**Purpose:** Update user profile data or set metadata

**Request Headers:**

- `Content-Type: application/json`
- `X-API-Key: <your-api-key>`

**Request Body (Profile Update):**

```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "brand_id": 925,
  "user_id": "user123",
  "session_id": "session-uuid"
}
```

**Request Body (Metadata Update):**

```json
{
  "metadata": {
    "session_type": "premium",
    "feature_flags": ["new_ui"]
  },
  "user_id": "user123",
  "brand_id": 925,
  "session_id": "session-uuid"
}
```

**Response:** Success/error status

**Called:** When `identify()`, `set()`, or `setMetadata()` is called

---

### 4. Update Session Location

**Endpoint:** `PUT /v2/tracking-session/{sessionId}/location`

**Purpose:** Update geolocation data for a session (optional feature)

**Request Headers:**

- `Content-Type: application/json`
- `X-API-Key: <your-api-key>`

**Request Body:**

```json
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "accuracy": 10.0
}
```

**Response:** Success/error status

**Called:** After session creation if location permissions are granted

---

## Best Practices

### Initialization

- Initialize the SDK as early as possible in your app lifecycle (Application.onCreate() for Android, AppDelegate for iOS)
- Use environment variables or configuration files for brand ID and API keys
- Handle initialization errors gracefully with try-catch
- Enable `debug: true` during development to see detailed logs
- Wait for initialization to complete before tracking critical events

**Example:**

```swift
// iOS - In AppDelegate
Task {
    do {
        try await MobileTracker.shared.initialize(
            brandId: ProcessInfo.processInfo.environment["BRAND_ID"] ?? "925",
            config: TrackerConfig(
                debug: true,
                apiUrl: "https://api.example.com",
                xApiKey: ProcessInfo.processInfo.environment["API_KEY"] ?? ""
            )
        )
    } catch {
        print("Tracker initialization failed: \(error)")
    }
}
```

### Event Naming

- Use clear, descriptive event names: `"BUTTON_CLICK"` not `"bc"`
- Use consistent naming conventions (UPPER_SNAKE_CASE recommended)
- Avoid special characters in event names
- Use semantic names that describe the action: `"PURCHASE"`, `"SIGNUP"`, `"VIEW_PAGE"`

### Properties and Attributes

- Keep property names consistent across events
- Use meaningful property names: `"product_id"` not `"pid"`
- Avoid deeply nested objects (2-3 levels max)
- Don't include sensitive data (passwords, credit cards, SSN, etc.)
- Use `attributes` for event-specific data, `metadata` for technical context

### User Identification

- Call `identify()` after user login/signup
- Use `set()` to update profile data when user information changes
- Call `reset()` on logout to clear user data
- Don't include PII unless necessary and compliant with privacy regulations (GDPR, CCPA, etc.)

### Session Management

- Sessions are created automatically during initialization
- Sessions persist across app restarts via dual storage
- Call `reset(all: false)` on logout to clear session but keep brand ID
- Call `reset(all: true)` for complete reset (rare, only for testing)

### Metadata Usage

- Use `setMetadata()` for session-level context that applies to all events
- Examples: experiment groups, feature flags, session type
- Metadata is included with all subsequent events in the session
- Don't overuse metadata - keep it focused on session context

### Performance

- The SDK is designed to be lightweight and non-blocking
- Events are queued and sent asynchronously
- Automatic screen tracking reduces manual instrumentation
- Avoid tracking excessive events (hundreds per second)
- Events are queued if session is not ready, then flushed automatically

### Error Handling

- The SDK never crashes the host application
- Errors are logged in debug mode
- Network failures are handled gracefully
- Events are queued and retried if session is not available
- Use try-catch for initialization, but tracking methods handle errors internally

---

## Platform-Specific Notes

### iOS

- Minimum iOS version: 13.0
- Swift 5.5+ required
- Thread-safe using serial dispatch queues
- Uses URLSession for networking

### Android

- Minimum Android API: 21 (Lollipop)
- Kotlin 1.8+ required
- Thread-safe using synchronized blocks
- Uses OkHttp or HttpURLConnection for networking

### React Native

- React Native 0.70+ required
- Auto-linking supported for RN 0.60+
- TypeScript definitions included
- Bridges to native iOS and Android SDKs

---

## Support

For issues, questions, or feature requests:

- GitHub Issues: https://github.com/yourusername/mobile-tracking-sdk/issues
- Documentation: https://docs.yourproject.com
- Email: support@yourproject.com
