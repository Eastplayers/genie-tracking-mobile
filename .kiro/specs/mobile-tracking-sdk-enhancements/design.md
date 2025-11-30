# Design Document

## Overview

This design document specifies how to port the web tracking script (`examples/originalWebScript`) to mobile platforms, excluding consent management. The implementation mirrors the web version's architecture, API surface, and behavior.

**Primary Reference:** `examples/originalWebScript/core/tracker.ts` (FounderOS class)  
**Secondary Reference:** `examples/originalWebScript/utils/api.ts` (ApiClient class)

**Key Change from Web:** Session creation happens during initialization (not lazily), since consent management is removed.

## Architecture

### Initialization Flow (Corrected)

```
User calls init(brandId, config)
  ↓
Check if already initialized → return early
  ↓
Check if init pending → wait for promise
  ↓
Set isInitPending = true
  ↓
Create 30-second timeout
  ↓
performInitialization():
  - Validate brandId (non-empty, numeric)
  - Merge config with defaults
  - Validate config
  - Create ApiClient instance
  - Set brandId on ApiClient
  - Check for existing session in storage
  - If no session: create backend session ← NEW
  - Set initialized = true
  - Initialize background services (page tracking)
  - Flush pending track calls
  ↓
Clear timeout
  ↓
Set isInitPending = false
```

### Mobile Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    React Native Layer                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         MobileTracker JavaScript Module                 │ │
│  │  - init(brandId, config)                                │ │
│  │  - track(eventName, attributes, metadata)               │ │
│  │  - identify(userId, profileData)                        │ │
│  │  - set(profileData)                                     │ │
│  │  - setMetadata(metadata)                                │ │
│  │  - reset(all?)                                          │ │
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
│ MobileTracker    │                  │ MobileTracker    │
│ ├─ config        │                  │ ├─ config        │
│ ├─ apiClient     │                  │ ├─ apiClient     │
│ ├─ brandId       │                  │ ├─ brandId       │
│ ├─ initialized   │                  │ ├─ initialized   │
│ ├─ isInitPending │                  │ ├─ isInitPending │
│ └─ pendingCalls  │                  │ └─ pendingCalls  │
│                  │                  │                  │
│ ApiClient        │                  │ ApiClient        │
│ ├─ config        │                  │ ├─ config        │
│ ├─ storagePrefix │                  │ ├─ storagePrefix │
│ └─ storage       │                  │ └─ storage       │
└──────────────────┘                  └──────────────────┘
        │                                       │
        └───────────────────┬───────────────────┘
                            │
                            ▼
                   ┌────────────────┐
                   │ Backend API    │
                   │ - POST /v2/tracking-session
                   │ - POST /v2/tracking-session-data
                   │ - PUT /v1/customer-profiles/set
                   │ - PUT /v2/tracking-session/{id}/location
                   └────────────────┘
```

## Components and Interfaces

### 1. MobileTracker Class (Main SDK Class)

**Web Reference:** `examples/originalWebScript/core/tracker.ts` - FounderOS class

#### iOS Implementation

```swift
public class MobileTracker {
    // Singleton pattern
    public static let shared = MobileTracker()

    // Properties matching web implementation
    private var config: TrackerConfig = TrackerConfig.default
    private var apiClient: ApiClient?
    private var brandId: String = ""
    private var initialized: Bool = false
    private var isInitPending: Bool = false
    private var initPromise: Task<Void, Error>?
    private var pendingTrackCalls: [(String, [String: Any]?, [String: Any]?)] = []
    private var lastTrackedUrl: String?

    // Public API matching web exactly
    public func initialize(brandId: String, config: TrackerConfig?) async throws
    public func track(eventName: String, attributes: [String: Any]?, metadata: [String: Any]?) async
    public func identify(userId: String, profileData: [String: Any]?) async
    public func set(profileData: [String: Any]) async
    public func setMetadata(_ metadata: [String: Any]) async
    public func reset(all: Bool = false)

    // Internal methods
    private func performInitialization(brandId: String, config: TrackerConfig?) async throws
    private func flushPendingTrackCalls() async
    private func setupPageViewTracking()
}
```

**Key Implementation Notes:**

- Session creation happens in `performInitialization()` after ApiClient is created
- No consent checks - session is created immediately
- Same property names and types (converted to Swift conventions)

#### Android Implementation

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

    // Properties matching web implementation
    private var config: TrackerConfig = TrackerConfig.default()
    private var apiClient: ApiClient? = null
    private var brandId: String = ""
    private var initialized: Boolean = false
    private var isInitPending: Boolean = false
    private var initJob: Job? = null
    private val pendingTrackCalls = mutableListOf<Triple<String, Map<String, Any>?, Map<String, Any>?>>()
    private var lastTrackedUrl: String? = null

    // Public API matching web exactly
    suspend fun initialize(brandId: String, config: TrackerConfig? = null)
    suspend fun track(eventName: String, attributes: Map<String, Any>? = null, metadata: Map<String, Any>? = null)
    suspend fun identify(userId: String, profileData: Map<String, Any>? = null)
    suspend fun set(profileData: Map<String, Any>)
    suspend fun setMetadata(metadata: Map<String, Any>)
    fun reset(all: Boolean = false)

    // Internal methods
    private suspend fun performInitialization(brandId: String, config: TrackerConfig?)
    private suspend fun flushPendingTrackCalls()
    private fun setupPageViewTracking()
}
```

### 2. ApiClient Class

**Web Reference:** `examples/originalWebScript/utils/api.ts` - ApiClient class

#### iOS Implementation

```swift
class ApiClient {
    private let config: TrackerConfig
    private let storagePrefix: String
    private let storage: StorageManager

    init(config: TrackerConfig, brandId: String) {
        self.config = config
        self.storagePrefix = "__GT_\(brandId)_"
        self.storage = StorageManager(prefix: storagePrefix)
    }

    // Storage methods (web: lines 37-127 in api.ts)
    func getCookie(_ name: String) -> String?
    func writeCookie(_ name: String, value: String, expires: Int?, domain: String?)
    func clearCookie(_ name: String, domain: String?)
    func clearAllTrackingCookies()

    // Device methods (web: lines 175-249 in api.ts)
    func generateUUID() -> String
    func detectOS() -> String
    func getDeviceId() -> String?
    func writeDeviceId() async -> String
    func getDeviceInfo() async -> DeviceInfo

    // Session methods (web: lines 251-332 in api.ts)
    func createTrackingSession(_ brandId: Int) async -> String?
    func updateSessionLocation(_ sessionId: String, location: LocationData) async -> Bool
    func updateSessionEmail(_ sessionId: String, newEmail: String, brandId: Int) async -> String?

    // Profile methods (web: lines 367-450 in api.ts)
    func updateProfile(_ data: UpdateProfileData, brandId: Int) async -> Bool
    func setMetadata(_ metadata: [String: Any], brandId: Int) async -> Bool

    // Event tracking (web: lines 452-486 in api.ts)
    func trackEvent(_ brandId: Int, sessionId: String, eventName: String, eventData: [String: Any]?) async -> Bool

    // Session getters/setters (web: lines 488-528 in api.ts)
    func getSessionId() -> String?
    func setSessionId(_ sessionId: String)
    func getSessionEmail() -> String?
    func getBrandId() -> Int?
    func setBrandId(_ brandId: Int)

    // Identity methods (web: lines 530-568 in api.ts)
    func identifyById(sessionId: String, userId: String) async -> String?
    func linkVisitorToSession(_ payload: LinkVisitorToSession) async -> Bool

    // Utility (web: lines 570-575 in api.ts)
    func clearCookieByName(_ name: String, domain: String?)
}
```

**Key Implementation Notes:**

- No consent-related methods
- Storage uses UserDefaults (primary) + file backup (like web's cookie + localStorage)

#### Android Implementation

```kotlin
class ApiClient(
    private val config: TrackerConfig,
    brandId: String,
    private val context: Context
) {
    private val storagePrefix = "__GT_${brandId}_"
    private val storage = StorageManager(context, storagePrefix)

    // Storage methods (web: lines 37-127 in api.ts)
    fun getCookie(name: String): String?
    fun writeCookie(name: String, value: String, expires: Int? = null, domain: String? = null)
    fun clearCookie(name: String, domain: String? = null)
    fun clearAllTrackingCookies()

    // Device methods (web: lines 175-249 in api.ts)
    fun generateUUID(): String
    fun detectOS(): String
    fun getDeviceId(): String?
    suspend fun writeDeviceId(): String
    suspend fun getDeviceInfo(): DeviceInfo

    // Session methods (web: lines 251-332 in api.ts)
    suspend fun createTrackingSession(brandId: Int): String?
    suspend fun updateSessionLocation(sessionId: String, location: LocationData): Boolean
    suspend fun updateSessionEmail(sessionId: String, newEmail: String, brandId: Int): String?

    // Profile methods (web: lines 367-450 in api.ts)
    suspend fun updateProfile(data: UpdateProfileData, brandId: Int): Boolean
    suspend fun setMetadata(metadata: Map<String, Any>, brandId: Int): Boolean

    // Event tracking (web: lines 452-486 in api.ts)
    suspend fun trackEvent(brandId: Int, sessionId: String, eventName: String, eventData: Map<String, Any>?): Boolean

    // Session getters/setters (web: lines 488-528 in api.ts)
    fun getSessionId(): String?
    fun setSessionId(sessionId: String)
    fun getSessionEmail(): String?
    fun getBrandId(): Int?
    fun setBrandId(brandId: Int)

    // Identity methods (web: lines 530-568 in api.ts)
    suspend fun identifyById(sessionId: String, userId: String): String?
    suspend fun linkVisitorToSession(payload: LinkVisitorToSession): Boolean

    // Utility (web: lines 570-575 in api.ts)
    fun clearCookieByName(name: String, domain: String? = null)
}
```

### 3. StorageManager Class

**Web Reference:** `examples/originalWebScript/utils/api.ts` - cookie and localStorage methods

Handles persistent storage, replicating web's cookie + localStorage dual storage.

#### iOS Implementation

```swift
class StorageManager {
    private let prefix: String
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default

    init(prefix: String) {
        self.prefix = prefix
    }

    // Primary storage (UserDefaults = cookies)
    func save(key: String, value: String, expires: Int? = nil) {
        let fullKey = prefix + key
        userDefaults.set(value, forKey: fullKey)

        // Also save to file backup (= localStorage)
        saveToFileBackup(key: fullKey, value: value)
    }

    func retrieve(key: String) -> String? {
        let fullKey = prefix + key
        // Try UserDefaults first
        if let value = userDefaults.string(forKey: fullKey) {
            return value
        }
        // Fallback to file backup
        return retrieveFromFileBackup(key: fullKey)
    }

    func remove(key: String) {
        let fullKey = prefix + key
        userDefaults.removeObject(forKey: fullKey)
        removeFromFileBackup(key: fullKey)
    }

    func clear() {
        // Clear all keys with prefix
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix(prefix) {
            userDefaults.removeObject(forKey: key)
        }
        clearFileBackup()
    }

    // File backup methods (replicating localStorage)
    private func saveToFileBackup(key: String, value: String)
    private func retrieveFromFileBackup(key: String) -> String?
    private func removeFromFileBackup(key: String)
    private func clearFileBackup()
}
```

#### Android Implementation

```kotlin
class StorageManager(
    context: Context,
    private val prefix: String
) {
    private val prefs = context.getSharedPreferences("MobileTracker", Context.MODE_PRIVATE)
    private val fileBackupDir = File(context.filesDir, "tracker_backup")

    init {
        fileBackupDir.mkdirs()
    }

    // Primary storage (SharedPreferences = cookies)
    fun save(key: String, value: String, expires: Int? = null) {
        val fullKey = prefix + key
        prefs.edit().putString(fullKey, value).apply()

        // Also save to file backup (= localStorage)
        saveToFileBackup(fullKey, value)
    }

    fun retrieve(key: String): String? {
        val fullKey = prefix + key
        // Try SharedPreferences first
        prefs.getString(fullKey, null)?.let { return it }
        // Fallback to file backup
        return retrieveFromFileBackup(fullKey)
    }

    fun remove(key: String) {
        val fullKey = prefix + key
        prefs.edit().remove(fullKey).apply()
        removeFromFileBackup(fullKey)
    }

    fun clear() {
        // Clear all keys with prefix
        val editor = prefs.edit()
        prefs.all.keys.filter { it.startsWith(prefix) }.forEach { editor.remove(it) }
        editor.apply()
        clearFileBackup()
    }

    // File backup methods (replicating localStorage)
    private fun saveToFileBackup(key: String, value: String)
    private fun retrieveFromFileBackup(key: String): String?
    private fun removeFromFileBackup(key: String)
    private fun clearFileBackup()
}
```

### 4. Data Models

**Web Reference:** `examples/originalWebScript/types/index.ts`

#### TrackerConfig

```swift
// iOS
public struct TrackerConfig {
    var debug: Bool = false
    var apiUrl: String?
    var xApiKey: String?
    var crossSiteCookie: Bool = false
    var cookieDomain: String?
    var cookieExpiration: Int = 365

    static let `default` = TrackerConfig()
}

// Android
data class TrackerConfig(
    val debug: Boolean = false,
    val apiUrl: String? = null,
    val xApiKey: String? = null,
    val crossSiteCookie: Boolean = false,
    val cookieDomain: String? = null,
    val cookieExpiration: Int = 365
) {
    companion object {
        fun default() = TrackerConfig()
    }
}
```

#### DeviceInfo

```swift
// iOS
struct DeviceInfo: Codable {
    let deviceId: String
    let osName: String
    let deviceType: String
}

// Android
data class DeviceInfo(
    val deviceId: String,
    val osName: String,
    val deviceType: String
)
```

#### LocationData

```swift
// iOS
struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
}

// Android
data class LocationData(
    val latitude: Double,
    val longitude: Double,
    val accuracy: Double
)
```

#### UpdateProfileData

```swift
// iOS
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

// Android
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

## API Endpoints and Payloads

### 1. Create Tracking Session

**Web Reference:** `api.ts` lines 258-272

**Endpoint:** `POST /v2/tracking-session`

**Request:**

```json
{
  "device_id": "uuid-string",
  "os_name": "iOS" | "Android",
  "device_type": "Mobile" | "Tablet",
  "brand_id": 123
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

### 2. Track Event

**Web Reference:** `api.ts` lines 459-471

**Endpoint:** `POST /v2/tracking-session-data`

**Request:**

```json
{
  "brand_id": 123,
  "session_id": "session-uuid",
  "event_name": "BUTTON_CLICK",
  "data": {
    "button": "purchase",
    "value": 100
  }
}
```

### 3. Update Profile

**Web Reference:** `api.ts` lines 382-399

**Endpoint:** `PUT /v1/customer-profiles/set`

**Request:**

```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "metadata": {},
  "brand_id": 123,
  "user_id": "user123",
  "session_id": "session-uuid"
}
```

### 4. Set Metadata

**Web Reference:** `api.ts` lines 424-436

**Endpoint:** `PUT /v1/customer-profiles/set`

**Request:**

```json
{
  "metadata": {
    "plan": "premium",
    "feature_flags": ["new_ui"]
  },
  "user_id": "user123",
  "brand_id": 123,
  "session_id": "session-uuid"
}
```

### 5. Update Location

**Web Reference:** `api.ts` lines 348-360

**Endpoint:** `PUT /v2/tracking-session/{sessionId}/location`

**Request:**

```json
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "accuracy": 10.0
}
```

## Implementation Flow

### Initialization Flow (Corrected for No Consent)

**Web Reference:** `tracker.ts` lines 56-172

```
1. User calls init(brandId, config)
2. Check if already initialized → return early
3. Check if init pending → wait for existing promise
4. Set isInitPending = true
5. Create 30-second timeout
6. Validate brandId (must be numeric string)
7. Merge config with defaults
8. Validate config
9. Create ApiClient instance
10. Set brandId on ApiClient
11. Check for existing session: sessionId = apiClient.getSessionId()
12. If no sessionId: create session via apiClient.createTrackingSession()
13. Mark initialized = true
14. Initialize background services (page tracking)
15. Flush pending track calls
16. Clear timeout
17. Set isInitPending = false
```

### Track Event Flow

**Web Reference:** `tracker.ts` lines 280-346

```
1. User calls track(eventName, attributes, metadata)
2. If init pending → queue event and return
3. If not initialized → warn and return
4. Get sessionId from ApiClient
5. If no sessionId → queue event and return
6. Get brandId from ApiClient
7. Merge attributes and metadata
8. Call apiClient.trackEvent()
9. Log success/error in debug mode
```

### Session Creation Flow

**Web Reference:** `api.ts` lines 251-291

```
1. Get device info (deviceId, osName, deviceType)
2. Build payload with device data + brand_id
3. POST to /v2/tracking-session
4. Extract session ID from response.data.id
5. Save session ID to storage
6. Request location update (async, non-blocking)
7. Return session ID
```

## Error Handling

**Web Reference:** Throughout `tracker.ts` and `api.ts`

### Initialization Errors

- **Invalid Brand ID:** Throw error "Brand ID must be a number" (line 119)
- **Config Validation:** Throw error with validation message (line 128)
- **Timeout:** Reset state after 30 seconds (lines 86-91)
- **Never crash:** Catch all errors, log in debug mode, gracefully degrade (lines 160-165)

### Runtime Errors

- **Network Failures:** Log error, return false/null (e.g., line 289 in api.ts)
- **Missing Session:** Queue events, log warning (lines 315-321 in tracker.ts)

## Testing Strategy

### Unit Testing

Test each method independently:

- Storage save/retrieve/clear operations
- Device ID generation and persistence
- Session creation with mocked HTTP
- Event tracking with mocked HTTP
- Reset functionality

### Integration Testing

Test end-to-end flows:

- Full initialization → session creation → event tracking
- Profile updates with backend
- Reset clearing all data

## Platform-Specific Notes

### iOS

- **Storage:** UserDefaults (primary) + file backup (secondary)
- **HTTP:** URLSession
- **Async:** Swift async/await
- **Location:** CLLocationManager (for geolocation feature)
- **Screen Tracking:** UIViewController swizzling (for auto screen tracking)

### Android

- **Storage:** SharedPreferences (primary) + file backup (secondary)
- **HTTP:** OkHttp or HttpURLConnection
- **Async:** Kotlin coroutines
- **Location:** FusedLocationProviderClient (for geolocation feature)
- **Screen Tracking:** ActivityLifecycleCallbacks (for auto screen tracking)

### React Native

- **Bridge:** Expose all MobileTracker methods to JavaScript
- **Types:** Provide TypeScript definitions matching web types
- **API:** Identical to web API surface

## Migration from Basic SDK

The existing basic SDK already has:

- ✅ Event queue
- ✅ HTTP client
- ✅ User context
- ✅ Configuration

We need to add:

- ❌ Backend session creation (during init)
- ❌ Device ID generation and persistence
- ❌ Storage manager (dual storage)
- ❌ Pending event queue
- ❌ setMetadata() method
- ❌ set() method for profiles
- ❌ reset() method
- ❌ Async initialization with timeout
- ❌ Auto page/screen view tracking
- ❌ Geolocation tracking
