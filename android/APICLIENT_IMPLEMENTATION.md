# Android ApiClient Implementation

## Overview

This document describes the implementation of the Android ApiClient class, which mirrors the web implementation from `examples/originalWebScript/utils/api.ts`.

## Implementation Summary

### Task 7.1: Create ApiClient with storage integration ✅

**Implemented:**

- Created `ApiClient` class with constructor accepting `TrackerConfig`, `brandId`, and `Context`
- Set up storage prefix format: `__GT_{brandId}_`
- Integrated `StorageManager` for dual storage (SharedPreferences + file backup)
- Created `TrackerConfig` data class matching web interface
- Set up OkHttp client with 30-second timeouts
- Implemented JSON serialization with kotlinx.serialization

**Files:**

- `android/src/main/java/com/mobiletracker/ApiClient.kt`

### Task 7.2: Implement device ID methods ✅

**Implemented:**

- `generateUUID()`: Generates UUID using `UUID.randomUUID()`
- `getDeviceId()`: Retrieves device ID from storage
- `writeDeviceId()`: Generates and saves new device ID with 365-day expiration
- `detectOS()`: Returns "Android"
- `getDeviceInfo()`: Collects comprehensive device data (device_id, os_name, device_type)
- `detectDeviceType()`: Detects Mobile/Tablet based on screen configuration

**Web Reference:** api.ts lines 175-249

### Task 7.3: Implement session creation ✅

**Implemented:**

- `createTrackingSession()`: Creates backend session with POST to `/v2/tracking-session`
  - Collects device info
  - Sends payload with device_id, os_name, device_type, brand_id
  - Extracts session ID from response.data.id
  - Saves session ID to storage
  - Includes placeholder for location update
- `updateSessionLocation()`: PUT to `/v2/tracking-session/{sessionId}/location`
- `updateSessionEmail()`: PUT to `/v2/tracking-session/{sessionId}/email_v2`

**Web Reference:** api.ts lines 251-362

### Task 7.4: Implement profile and metadata methods ✅

**Implemented:**

- `updateProfile()`: PUT to `/v1/customer-profiles/set`
  - Calls `identifyById()` if user_id differs from stored identify_id
  - Sends profile data (name, phone, email, gender, etc.)
  - Includes brand_id, user_id, session_id in payload
- `setMetadata()`: PUT to `/v1/customer-profiles/set`
  - Checks for session_id or user_id before calling
  - Sends metadata with brand_id, user_id, session_id
- `identifyById()`: PUT to `/v2/tracking-session/{sessionId}/identify/{userId}`
  - Saves identify_id to storage
  - Handles session ID updates

**Web Reference:** api.ts lines 367-450, 530-568

### Task 7.5: Implement event tracking ✅

**Implemented:**

- `trackEvent()`: POST to `/v2/tracking-session-data`
  - Builds payload with brand_id, session_id, event_name, data
  - Includes debug logging
  - Returns boolean success/failure

**Web Reference:** api.ts lines 452-486

### Task 7.6: Implement storage helper methods ✅

**Implemented:**

- `getSessionId()`: Retrieves session ID from storage
- `setSessionId()`: Saves session ID to storage
- `getSessionEmail()`: Retrieves session email from storage
- `getBrandId()`: Retrieves brand ID from storage (as Int)
- `setBrandId()`: Saves brand ID to storage
- `clearAllTrackingCookies()`: Clears device_id, session_id, session_email, identify_id
- `linkVisitorToSession()`: POST to `/v2/tracking-session/link-session`
- `clearCookieByName()`: Clears specific cookie by name

**Web Reference:** api.ts lines 132-148, 488-594

## Data Models

Created the following data classes to match web TypeScript interfaces:

1. **TrackerConfig**: Configuration options (debug, apiUrl, xApiKey, etc.)
2. **DeviceInfo**: Device information (device_id, os_name, device_type)
3. **LocationData**: Geolocation data (latitude, longitude, accuracy)
4. **UpdateProfileData**: Profile update payload (name, phone, email, etc.)
5. **LinkVisitorToSession**: Session linking payload (session_id, user_id)

## Key Implementation Details

### Storage Pattern

- Uses `StorageManager` for dual storage (SharedPreferences + file backup)
- Mirrors web's cookie + localStorage pattern
- Storage keys prefixed with `__GT_{brandId}_`

### HTTP Communication

- Uses OkHttp for all HTTP requests
- 30-second timeouts for connect/write/read
- Proper header management (Content-Type, x-api-key)
- JSON serialization with kotlinx.serialization

### Error Handling

- All network operations wrapped in try-catch
- Debug logging for errors when config.debug = true
- Graceful degradation (returns null/false on errors)
- Never crashes the app

### Async Operations

- All network operations use `suspend` functions
- Runs on `Dispatchers.IO` for background execution
- Compatible with Kotlin coroutines

## Testing

Created comprehensive unit tests in `ApiClientTest.kt`:

- Device ID generation and retrieval
- Device info collection
- Session creation (success and failure cases)
- Event tracking
- Profile updates
- Metadata updates
- Storage helper methods
- Cookie clearing

## Differences from Web Implementation

1. **No Consent Management**: Removed all consent-related code as per requirements
2. **No Browser APIs**: Replaced window.location, sessionStorage with Android equivalents
3. **Storage**: Uses SharedPreferences + file backup instead of cookies + localStorage
4. **Device Detection**: Uses Android Configuration API instead of user agent parsing
5. **Async Pattern**: Uses Kotlin coroutines instead of JavaScript Promises

## Requirements Validated

- ✅ Requirement 2.1: ApiClient initialization with config and brandId
- ✅ Requirement 2.2-2.7: Session creation during initialization
- ✅ Requirement 3.1-3.5: Device ID generation and persistence
- ✅ Requirement 4.1-4.3: Storage management with dual storage
- ✅ Requirement 5.3: Event tracking with session ID
- ✅ Requirement 6.1-6.5: Profile updates
- ✅ Requirement 7.1-7.4: Metadata management

## Next Steps

The ApiClient is now ready to be integrated with:

1. MobileTracker main class (Task 8)
2. Location Manager (Task 9)
3. React Native bridge (Tasks 11-13)
