# Requirements Document

## Introduction

This specification ports the core web tracking script (`examples/originalWebScript`) to mobile platforms (iOS, Android, React Native), excluding consent management features. The goal is to achieve feature parity with the web implementation for session management, device identification, storage, and event tracking.

**Reference Implementation:** `examples/originalWebScript/core/tracker.ts` and `examples/originalWebScript/utils/api.ts`

## Glossary

- **Brand ID**: Unique identifier for the application/brand (from web: `brandId` parameter in `init()`)
- **Session ID**: Backend-generated unique identifier for a tracking session (from web: `ApiClient.getSessionId()`)
- **Device ID**: Persistent UUID for device identification (from web: `ApiClient.getDeviceId()`)
- **API Client**: HTTP client for backend communication (from web: `ApiClient` class in `utils/api.ts`)
- **Pending Track Calls**: Queue of events tracked before initialization completes (from web: `pendingTrackCalls` array)
- **Storage**: Persistent local storage for session data (from web: cookies + localStorage)

## Requirements

### Requirement 1: Initialize with Brand ID and Configuration

**Reference:** `tracker.ts` - `init()` method (lines 56-104) and `performInitialization()` (lines 106-172)

**User Story:** As a mobile app developer, I want to initialize the SDK with a brand ID and configuration options, so that the SDK can communicate with the backend and track events.

#### Acceptance Criteria

1. WHEN the SDK receives an `init(brandId, config)` call, THEN the Mobile Tracking SDK SHALL validate that brandId is a non-empty string representing a number
2. WHEN initialization is called, THEN the Mobile Tracking SDK SHALL merge the provided config with default configuration values
3. WHEN initialization is called, THEN the Mobile Tracking SDK SHALL validate the configuration
4. WHEN initialization is called, THEN the Mobile Tracking SDK SHALL create an ApiClient instance with the config and brandId
5. WHEN initialization is called, THEN the Mobile Tracking SDK SHALL create a backend tracking session immediately
6. WHEN initialization is already in progress, THEN the Mobile Tracking SDK SHALL wait for the existing initialization to complete

### Requirement 2: Backend Session Creation During Initialization

**Reference:** `api.ts` - `createTrackingSession()` method (lines 251-291)  
**Note:** Session creation should be called during `performInitialization()` after ApiClient is created

**User Story:** As a mobile app developer, I want the SDK to create backend tracking sessions during initialization, so that all events are immediately associated with a server-side session.

#### Acceptance Criteria

1. WHEN initialization completes, THEN the Mobile Tracking SDK SHALL check for an existing session ID in storage
2. WHEN no existing session ID is found, THEN the Mobile Tracking SDK SHALL create a new backend session
3. WHEN a session is created, THEN the Mobile Tracking SDK SHALL collect device information including device_id, os_name, and device_type
4. WHEN a session is created, THEN the Mobile Tracking SDK SHALL send a POST request to `/v2/tracking-session` with device data and brand_id
5. WHEN a session is created successfully, THEN the Mobile Tracking SDK SHALL extract the session ID from `data.data.id` in the response
6. WHEN a session ID is received, THEN the Mobile Tracking SDK SHALL persist the session ID to local storage
7. WHEN a session is created, THEN the Mobile Tracking SDK SHALL optionally request location update

### Requirement 3: Device ID Generation and Persistence

**Reference:** `api.ts` - `getDeviceInfo()` method (lines 225-249)

**User Story:** As a mobile app developer, I want persistent device identification, so that users can be tracked across app sessions.

#### Acceptance Criteria

1. WHEN device info is requested, THEN the Mobile Tracking SDK SHALL check for an existing device_id in storage
2. WHEN no device ID exists, THEN the Mobile Tracking SDK SHALL generate a new UUID
3. WHEN a device ID is generated, THEN the Mobile Tracking SDK SHALL persist it to storage with 365-day expiration
4. WHEN device info is collected, THEN the Mobile Tracking SDK SHALL detect OS name
5. WHEN device info is collected, THEN the Mobile Tracking SDK SHALL detect device type as Mobile, Tablet, or Desktop

### Requirement 4: Storage Management (Cookies + LocalStorage Pattern)

**Reference:** `api.ts` - `getCookie()`, `writeCookie()`, `clearCookie()` methods (lines 37-127)

**User Story:** As a mobile app developer, I want session data persisted locally, so that tracking continues across app restarts.

#### Acceptance Criteria

1. WHEN data is saved to storage, THEN the Mobile Tracking SDK SHALL use a key prefix format `__GT_{brandId}_`
2. WHEN data is saved to storage, THEN the Mobile Tracking SDK SHALL store to both primary storage and backup storage
3. WHEN cookies are written, THEN the Mobile Tracking SDK SHALL set expiration, path, domain attributes
4. WHEN data is retrieved from storage, THEN the Mobile Tracking SDK SHALL check primary storage first
5. WHEN storage is cleared, THEN the Mobile Tracking SDK SHALL remove from both primary and backup storage

### Requirement 5: Track Events with Session ID

**Reference:** `tracker.ts` - `track()` method (lines 280-346)

**User Story:** As a mobile app developer, I want to track events that are associated with the backend session, so that analytics data is properly recorded.

#### Acceptance Criteria

1. WHEN an event is tracked before initialization completes, THEN the Mobile Tracking SDK SHALL queue the event in `pendingTrackCalls`
2. WHEN an event is tracked without a session ID, THEN the Mobile Tracking SDK SHALL queue the event and log a warning
3. WHEN an event is tracked with a valid session, THEN the Mobile Tracking SDK SHALL send a POST request to `/v2/tracking-session-data`
4. WHEN pending events exist after initialization, THEN the Mobile Tracking SDK SHALL flush all pending events
5. WHEN an event is tracked, THEN the Mobile Tracking SDK SHALL merge attributes and metadata into event data

### Requirement 6: Identify Users and Update Profiles

**Reference:** `tracker.ts` - `identify()`, `set()`, `updateProfile()` methods (lines 348-424)

**User Story:** As a mobile app developer, I want to identify users and update their profiles, so that events are associated with user data.

#### Acceptance Criteria

1. WHEN `identify(user_id, profileData)` is called, THEN the Mobile Tracking SDK SHALL call `updateProfile()` with the combined data
2. WHEN `set(profileData)` is called, THEN the Mobile Tracking SDK SHALL call `updateProfile()` with the profile data
3. WHEN profile is updated, THEN the Mobile Tracking SDK SHALL send a PUT request to `/v1/customer-profiles/set`
4. WHEN user_id is provided and differs from stored identify_id, THEN the Mobile Tracking SDK SHALL call `identifyById()` first
5. WHEN profile update succeeds, THEN the Mobile Tracking SDK SHALL log success in debug mode

### Requirement 7: Set Metadata for Session Context

**Reference:** `tracker.ts` - `setMetadata()` method (lines 426-456)

**User Story:** As a mobile app developer, I want to set session-level metadata, so that contextual information is included with all events.

#### Acceptance Criteria

1. WHEN `setMetadata(metadata)` is called, THEN the Mobile Tracking SDK SHALL send a PUT request to `/v1/customer-profiles/set` with the metadata
2. WHEN metadata is set, THEN the Mobile Tracking SDK SHALL include session_id and user_id in the request
3. WHEN neither session_id nor user_id exists, THEN the Mobile Tracking SDK SHALL log an error and return false
4. WHEN metadata is set successfully, THEN the Mobile Tracking SDK SHALL log success in debug mode

### Requirement 8: Reset Tracking Data

**Reference:** `tracker.ts` - `reset()` method (lines 458-502)

**User Story:** As a mobile app developer, I want to reset all tracking data, so that I can clear user data on logout.

#### Acceptance Criteria

1. WHEN `reset()` is called, THEN the Mobile Tracking SDK SHALL clear storage for session_id, device_id, session_email, and identify_id
2. WHEN `reset(all=true)` is called, THEN the Mobile Tracking SDK SHALL also clear the brand_id
3. WHEN reset is called, THEN the Mobile Tracking SDK SHALL clear all localStorage items with the brand prefix
4. WHEN reset is called, THEN the Mobile Tracking SDK SHALL reset internal state including pendingTrackCalls and lastTrackedUrl
5. WHEN reset is called, THEN the Mobile Tracking SDK SHALL create a new tracking session

### Requirement 9: Automatic Page View Tracking

**Reference:** `tracker.ts` - `setupPageViewTracking()` method (lines 625-662)

**User Story:** As a mobile app developer, I want automatic screen view tracking, so that navigation is tracked without manual instrumentation.

#### Acceptance Criteria

1. WHEN page view tracking is set up, THEN the Mobile Tracking SDK SHALL track an initial VIEW_PAGE event with the current URL
2. WHEN the URL changes, THEN the Mobile Tracking SDK SHALL track a VIEW_PAGE event with the new URL
3. WHEN history.pushState is called, THEN the Mobile Tracking SDK SHALL detect the navigation and track it
4. WHEN history.replaceState is called, THEN the Mobile Tracking SDK SHALL detect the navigation and track it
5. WHEN browser back/forward navigation occurs, THEN the Mobile Tracking SDK SHALL detect it via popstate event

### Requirement 10: Geolocation Tracking

**Reference:** `api.ts` - `requestLocationUpdate()` method (lines 300-322)

**User Story:** As a mobile app developer, I want optional geolocation tracking, so that I can understand where users are located.

#### Acceptance Criteria

1. WHEN a session is created, THEN the Mobile Tracking SDK SHALL automatically request location update
2. WHEN location permissions are granted, THEN the Mobile Tracking SDK SHALL retrieve latitude, longitude, and accuracy
3. WHEN location is retrieved, THEN the Mobile Tracking SDK SHALL send a PUT request to `/v2/tracking-session/{sessionId}/location`
4. WHEN location retrieval fails, THEN the Mobile Tracking SDK SHALL log the error in debug mode
5. WHEN geolocation is not available, THEN the Mobile Tracking SDK SHALL continue tracking without location data

### Requirement 11: Configuration Options

**Reference:** `types/index.ts` - `TrackerConfig` interface and `config.ts`

**User Story:** As a mobile app developer, I want configuration options for the SDK, so that I can customize behavior for my app's needs.

#### Acceptance Criteria

1. WHEN the SDK is initialized, THEN the Mobile Tracking SDK SHALL accept a `debug` boolean to enable detailed logging
2. WHEN the SDK is initialized, THEN the Mobile Tracking SDK SHALL accept an `api_url` string for the backend endpoint
3. WHEN the SDK is initialized, THEN the Mobile Tracking SDK SHALL accept an `x_api_key` string for API authentication
4. WHEN the SDK is initialized, THEN the Mobile Tracking SDK SHALL accept `cross_site_cookie` boolean for cross-domain tracking
5. WHEN the SDK is initialized, THEN the Mobile Tracking SDK SHALL accept `cookie_domain` string for cookie domain configuration
