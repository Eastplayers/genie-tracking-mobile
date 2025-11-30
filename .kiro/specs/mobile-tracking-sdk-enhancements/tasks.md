# Implementation Plan

## Overview

This implementation plan ports the web tracking script to mobile platforms WITHOUT consent management. Each task references specific files and line numbers from `examples/originalWebScript`.

**Primary Reference:** `examples/originalWebScript/core/tracker.ts`  
**Secondary Reference:** `examples/originalWebScript/utils/api.ts`

**Key Change:** Session creation happens during initialization (not lazily).

---

## iOS Implementation

- [x] 1. Implement iOS StorageManager (Web: api.ts lines 37-127)

  - [x] 1.1 Create StorageManager class with dual storage
    - Implement save() using UserDefaults (primary) + file backup (secondary)
    - Implement retrieve() checking UserDefaults first, then file backup
    - Implement remove() clearing both storages
    - Implement clear() removing all keys with prefix
    - Use storage prefix format `__GT_{brandId}_` (web: line 18)
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
    - _Web Reference: api.ts getCookie(), writeCookie(), clearCookie() methods_

- [x] 2. Implement iOS ApiClient class (Web: api.ts entire file)

  - [x] 2.1 Create ApiClient with storage integration

    - Initialize with config and brandId
    - Set storagePrefix = `__GT_{brandId}_`
    - Create StorageManager instance
    - _Requirements: 2.1, 4.1_
    - _Web Reference: api.ts lines 14-19 (constructor)_

  - [x] 2.2 Implement device ID methods

    - Implement generateUUID() using UUID() (web: lines 175-184)
    - Implement getDeviceId() checking storage (web: line 231)
    - Implement writeDeviceId() generating and saving UUID (web: lines 233-235)
    - Implement detectOS() from UIDevice.current.systemName (web: lines 186-199)
    - Implement getDeviceInfo() collecting device data (web: lines 225-249)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
    - _Web Reference: api.ts lines 175-249_

  - [x] 2.3 Implement session creation

    - Implement createTrackingSession() (web: lines 251-291)
    - POST to `/v2/tracking-session` with device data
    - Extract session ID from response.data.id (web: line 272)
    - Save session ID to storage (web: lines 274-277)
    - Call requestLocationUpdate() after session creation (web: line 280)
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_
    - _Web Reference: api.ts lines 251-291_

  - [x] 2.4 Implement profile and metadata methods

    - Implement updateProfile() PUT to `/v1/customer-profiles/set` (web: lines 367-410)
    - Call identifyById() if user_id differs from stored (web: lines 374-376)
    - Implement setMetadata() PUT to `/v1/customer-profiles/set` (web: lines 412-450)
    - Check for session_id or user_id before calling (web: lines 416-421)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4_
    - _Web Reference: api.ts lines 367-450_

  - [x] 2.5 Implement event tracking

    - Implement trackEvent() POST to `/v2/tracking-session-data` (web: lines 452-486)
    - Build payload with brand_id, session_id, event_name, data (web: lines 459-464)
    - _Requirements: 5.3_
    - _Web Reference: api.ts lines 452-486_

  - [x] 2.6 Implement storage helper methods
    - Implement getSessionId() retrieving from storage (web: lines 488-490)
    - Implement setSessionId() saving to storage (web: lines 492-496)
    - Implement getBrandId() retrieving from storage (web: lines 502-511)
    - Implement setBrandId() saving to storage (web: lines 513-517)
    - Implement clearAllTrackingCookies() (web: lines 132-148)
    - _Requirements: 4.1, 4.2, 4.3_
    - _Web Reference: api.ts lines 488-575_

- [x] 3. Implement iOS MobileTracker main class (Web: tracker.ts lines 20-662)

  - [x] 3.1 Create MobileTracker singleton with properties

    - Create shared singleton instance (web: line 665)
    - Add config property with default (web: line 39)
    - Add apiClient optional property (web: line 40)
    - Add brandId string property (web: line 41)
    - Add initialized boolean (web: line 42)
    - Add isInitPending boolean (web: line 43)
    - Add initPromise optional (web: line 44)
    - Add pendingTrackCalls array (web: line 46)
    - Add lastTrackedUrl optional (web: line 47)
    - _Requirements: 1.1_
    - _Web Reference: tracker.ts lines 39-47_

  - [x] 3.2 Implement initialize() method

    - Check if already initialized, return early (web: lines 63-68)
    - Check if init pending, wait for promise (web: lines 70-77)
    - Set isInitPending = true (web: line 80)
    - Create 30-second timeout (web: lines 82-89)
    - Call performInitialization() (web: line 92)
    - Clear timeout on completion (web: lines 96-99)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.6_
    - _Web Reference: tracker.ts lines 56-104_

  - [x] 3.3 Implement performInitialization() method with session creation

    - Validate brandId is non-empty (web: lines 112-114)
    - Validate brandId is numeric (web: lines 116-118)
    - Store brandId (web: line 121)
    - Merge config with defaults (web: line 122)
    - Validate config (web: lines 124-128)
    - Create ApiClient instance (web: lines 131-132)
    - Set brandId on ApiClient (web: line 133)
    - **Check for existing session: sessionId = apiClient.getSessionId()**
    - **If no sessionId: create session via apiClient.createTrackingSession()**
    - Set initialized = true (web: line 136)
    - Initialize background services async (web: lines 147-149)
    - Catch errors gracefully, never crash (web: lines 150-155)
    - Set isInitPending = false in finally (web: line 157)
    - Flush pending track calls (web: lines 159-161)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2_
    - _Web Reference: tracker.ts lines 106-172 + session creation logic_

  - [x] 3.4 Implement track() method

    - If init pending, queue event (web: lines 287-290)
    - If not initialized, warn and return (web: lines 292-297)
    - Get sessionId from apiClient (web: line 299)
    - If no sessionId, queue event (web: lines 302-308)
    - Get brandId from apiClient (web: line 317)
    - Merge attributes and metadata (web: line 323)
    - Call apiClient.trackEvent() (web: line 326)
    - Log success/error in debug mode (web: lines 328-334)
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
    - _Web Reference: tracker.ts lines 280-346_

  - [x] 3.5 Implement identify() method

    - Check if initialized (web: lines 354-359)
    - Validate user_id is not empty (web: lines 369-374)
    - Call updateProfile() with combined data (web: lines 376-378)
    - _Requirements: 6.1_
    - _Web Reference: tracker.ts lines 348-379_

  - [x] 3.6 Implement set() method

    - Check if initialized (web: lines 387-392)
    - Call updateProfile() with data (web: line 402)
    - _Requirements: 6.2_
    - _Web Reference: tracker.ts lines 381-403_

  - [x] 3.7 Implement setMetadata() method

    - Check if initialized (web: lines 432-437)
    - Get brandId from apiClient (web: lines 443-449)
    - Call apiClient.setMetadata() (web: line 451)
    - Log success/error in debug mode (web: lines 453-459)
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
    - _Web Reference: tracker.ts lines 426-461_

  - [x] 3.8 Implement reset() method

    - Clear storage: session_id, device_id, session_email, identify_id (web: lines 469-479)
    - If all=true, also clear brand_id (web: lines 470-472)
    - Clear file backup items with brand prefix (web: lines 482-489)
    - Reset internal state: isInitPending, pendingTrackCalls, lastTrackedUrl (web: lines 492-494)
    - Create new tracking session (web: lines 495-497)
    - Log completion in debug mode (web: lines 499-501)
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
    - _Web Reference: tracker.ts lines 463-502_

  - [x] 3.9 Implement helper methods

    - Implement flushPendingTrackCalls() looping through queue (web: lines 619-623)
    - _Requirements: 5.4_
    - _Web Reference: tracker.ts lines 619-623_

  - [x] 3.10 Implement setupPageViewTracking() for auto screen tracking
    - Track initial VIEW_PAGE event (web: lines 631-632)
    - Store lastTrackedUrl (web: line 633)
    - Create trackPageView() closure (web: lines 635-641)
    - Swizzle UIViewController viewDidAppear to detect screen changes
    - Track VIEW_PAGE when screen changes
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
    - _Web Reference: tracker.ts lines 625-662 (adapted for iOS)_

- [x] 4. Implement iOS Location Manager (Web: api.ts lines 300-362)

  - [x] 4.1 Create LocationManager class
    - Implement CLLocationManagerDelegate
    - Implement requestLocationUpdate() (web: lines 300-322)
    - Request location using CLLocationManager
    - Extract latitude, longitude, accuracy (web: lines 309-313)
    - Call updateSessionLocation() with data (web: line 314)
    - Handle errors gracefully (web: lines 315-318)
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
    - _Web Reference: api.ts lines 300-362_

- [x] 5. Checkpoint - Ensure iOS SDK tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Android Implementation

- [x] 6. Implement Android StorageManager (Web: api.ts lines 37-127)

  - [x] 6.1 Create StorageManager class with dual storage
    - Implement save() using SharedPreferences (primary) + file backup (secondary)
    - Implement retrieve() checking SharedPreferences first, then file backup
    - Implement remove() clearing both storages
    - Implement clear() removing all keys with prefix
    - Use storage prefix format `__GT_{brandId}_` (web: line 18)
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
    - _Web Reference: api.ts getCookie(), writeCookie(), clearCookie() methods_

- [x] 7. Implement Android ApiClient class (Web: api.ts entire file)

  - [x] 7.1 Create ApiClient with storage integration

    - Initialize with config, brandId, and context
    - Set storagePrefix = `__GT_{brandId}_`
    - Create StorageManager instance
    - _Requirements: 2.1, 4.1_
    - _Web Reference: api.ts lines 14-19 (constructor)_

  - [x] 7.2 Implement device ID methods

    - Implement generateUUID() using UUID.randomUUID() (web: lines 175-184)
    - Implement getDeviceId() checking storage (web: line 231)
    - Implement writeDeviceId() generating and saving UUID (web: lines 233-235)
    - Implement detectOS() returning "Android" (web: lines 186-199)
    - Implement getDeviceInfo() collecting device data (web: lines 225-249)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
    - _Web Reference: api.ts lines 175-249_

  - [x] 7.3 Implement session creation

    - Implement createTrackingSession() (web: lines 251-291)
    - POST to `/v2/tracking-session` with device data
    - Extract session ID from response.data.id (web: line 272)
    - Save session ID to storage (web: lines 274-277)
    - Call requestLocationUpdate() after session creation (web: line 280)
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_
    - _Web Reference: api.ts lines 251-291_

  - [x] 7.4 Implement profile and metadata methods

    - Implement updateProfile() PUT to `/v1/customer-profiles/set` (web: lines 367-410)
    - Call identifyById() if user_id differs from stored (web: lines 374-376)
    - Implement setMetadata() PUT to `/v1/customer-profiles/set` (web: lines 412-450)
    - Check for session_id or user_id before calling (web: lines 416-421)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4_
    - _Web Reference: api.ts lines 367-450_

  - [x] 7.5 Implement event tracking

    - Implement trackEvent() POST to `/v2/tracking-session-data` (web: lines 452-486)
    - Build payload with brand_id, session_id, event_name, data (web: lines 459-464)
    - _Requirements: 5.3_
    - _Web Reference: api.ts lines 452-486_

  - [x] 7.6 Implement storage helper methods
    - Implement getSessionId() retrieving from storage (web: lines 488-490)
    - Implement setSessionId() saving to storage (web: lines 492-496)
    - Implement getBrandId() retrieving from storage (web: lines 502-511)
    - Implement setBrandId() saving to storage (web: lines 513-517)
    - Implement clearAllTrackingCookies() (web: lines 132-148)
    - _Requirements: 4.1, 4.2, 4.3_
    - _Web Reference: api.ts lines 488-575_

- [x] 8. Implement Android MobileTracker main class (Web: tracker.ts lines 20-662)

  - [x] 8.1 Create MobileTracker singleton with properties

    - Create getInstance() singleton pattern (web: line 665)
    - Add config property with default (web: line 39)
    - Add apiClient optional property (web: line 40)
    - Add brandId string property (web: line 41)
    - Add initialized boolean (web: line 42)
    - Add isInitPending boolean (web: line 43)
    - Add initJob optional (web: line 44)
    - Add pendingTrackCalls mutableList (web: line 46)
    - Add lastTrackedUrl optional (web: line 47)
    - _Requirements: 1.1_
    - _Web Reference: tracker.ts lines 39-47_

  - [x] 8.2 Implement initialize() method

    - Check if already initialized, return early (web: lines 63-68)
    - Check if init pending, wait for job (web: lines 70-77)
    - Set isInitPending = true (web: line 80)
    - Create 30-second timeout (web: lines 82-89)
    - Call performInitialization() (web: line 92)
    - Clear timeout on completion (web: lines 96-99)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.6_
    - _Web Reference: tracker.ts lines 56-104_

  - [x] 8.3 Implement performInitialization() method with session creation

    - Validate brandId is non-empty (web: lines 112-114)
    - Validate brandId is numeric (web: lines 116-118)
    - Store brandId (web: line 121)
    - Merge config with defaults (web: line 122)
    - Validate config (web: lines 124-128)
    - Create ApiClient instance (web: lines 131-132)
    - Set brandId on ApiClient (web: line 133)
    - **Check for existing session: sessionId = apiClient.getSessionId()**
    - **If no sessionId: create session via apiClient.createTrackingSession()**
    - Set initialized = true (web: line 136)
    - Initialize background services async (web: lines 147-149)
    - Catch errors gracefully, never crash (web: lines 150-155)
    - Set isInitPending = false in finally (web: line 157)
    - Flush pending track calls (web: lines 159-161)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2_
    - _Web Reference: tracker.ts lines 106-172 + session creation logic_

  - [x] 8.4 Implement track() method

    - If init pending, queue event (web: lines 287-290)
    - If not initialized, warn and return (web: lines 292-297)
    - Get sessionId from apiClient (web: line 299)
    - If no sessionId, queue event (web: lines 302-308)
    - Get brandId from apiClient (web: line 317)
    - Merge attributes and metadata (web: line 323)
    - Call apiClient.trackEvent() (web: line 326)
    - Log success/error in debug mode (web: lines 328-334)
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
    - _Web Reference: tracker.ts lines 280-346_

  - [x] 8.5 Implement identify() method

    - Check if initialized (web: lines 354-359)
    - Validate user_id is not empty (web: lines 369-374)
    - Call updateProfile() with combined data (web: lines 376-378)
    - _Requirements: 6.1_
    - _Web Reference: tracker.ts lines 348-379_

  - [x] 8.6 Implement set() method

    - Check if initialized (web: lines 387-392)
    - Call updateProfile() with data (web: line 402)
    - _Requirements: 6.2_
    - _Web Reference: tracker.ts lines 381-403_

  - [x] 8.7 Implement setMetadata() method

    - Check if initialized (web: lines 432-437)
    - Get brandId from apiClient (web: lines 443-449)
    - Call apiClient.setMetadata() (web: line 451)
    - Log success/error in debug mode (web: lines 453-459)
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
    - _Web Reference: tracker.ts lines 426-461_

  - [x] 8.8 Implement reset() method

    - Clear storage: session_id, device_id, session_email, identify_id (web: lines 469-479)
    - If all=true, also clear brand_id (web: lines 470-472)
    - Clear file backup items with brand prefix (web: lines 482-489)
    - Reset internal state: isInitPending, pendingTrackCalls, lastTrackedUrl (web: lines 492-494)
    - Create new tracking session (web: lines 495-497)
    - Log completion in debug mode (web: lines 499-501)
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
    - _Web Reference: tracker.ts lines 463-502_

  - [x] 8.9 Implement helper methods

    - Implement flushPendingTrackCalls() looping through queue (web: lines 619-623)
    - _Requirements: 5.4_
    - _Web Reference: tracker.ts lines 619-623_

  - [x] 8.10 Implement setupPageViewTracking() for auto screen tracking
    - Track initial VIEW_PAGE event (web: lines 631-632)
    - Store lastTrackedUrl (web: line 633)
    - Create trackPageView() function (web: lines 635-641)
    - Use ActivityLifecycleCallbacks to detect screen changes
    - Track VIEW_PAGE when Activity resumes
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
    - _Web Reference: tracker.ts lines 625-662 (adapted for Android)_

- [x] 9. Implement Android Location Manager (Web: api.ts lines 300-362)

  - [x] 9.1 Create LocationManager class
    - Use FusedLocationProviderClient
    - Implement requestLocationUpdate() (web: lines 300-322)
    - Request location using FusedLocationProviderClient
    - Extract latitude, longitude, accuracy (web: lines 309-313)
    - Call updateSessionLocation() with data (web: line 314)
    - Handle errors gracefully (web: lines 315-318)
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
    - _Web Reference: api.ts lines 300-362_

- [x] 10. Checkpoint - Ensure Android SDK tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## React Native Bridge

- [-] 11. Update React Native bridge for iOS (Web: tracker.ts public methods)

  - [x] 11.1 Add new methods to iOS bridge
    - Add setMetadata bridge method (web: tracker.ts lines 426-461)
    - Add set bridge method (web: tracker.ts lines 381-403)
    - Add reset bridge method (web: tracker.ts lines 463-502)
    - Handle data serialization for all methods
    - _Requirements: 6.2, 7.1, 8.1_
    - _Web Reference: tracker.ts method signatures_

- [x] 12. Update React Native bridge for Android (Web: tracker.ts public methods)

  - [x] 12.1 Add new methods to Android bridge
    - Add setMetadata bridge method (web: tracker.ts lines 426-461)
    - Add set bridge method (web: tracker.ts lines 381-403)
    - Add reset bridge method (web: tracker.ts lines 463-502)
    - Handle data serialization for all methods
    - _Requirements: 6.2, 7.1, 8.1_
    - _Web Reference: tracker.ts method signatures_

- [x] 13. Update React Native JavaScript module (Web: types/index.ts)

  - [x] 13.1 Add new methods to TypeScript interface
    - Add setMetadata(metadata: Record<string, any>): Promise<void>
    - Add set(profileData: CommonProfileData): Promise<void>
    - Add reset(all?: boolean): void
    - Update TrackerConfig interface with new options (web: types/index.ts lines 1-30)
    - Export updated interface
    - _Requirements: 6.2, 7.1, 8.1, 11.1, 11.2, 11.3, 11.4, 11.5_
    - _Web Reference: types/index.ts TrackerConfig and TrackerInstance interfaces_

---

## Documentation and Examples

- [x] 14. Update example applications

  - [x] 14.1 Update iOS example app

    - Add session management demonstration
    - Add setMetadata() usage example
    - Add set() profile update example
    - Add reset() functionality example
    - _Requirements: 1.1, 6.2, 7.1, 8.1_
    - _Web Reference: examples/originalWebScript/README.md usage examples_

  - [x] 14.2 Update Android example app

    - Add session management demonstration
    - Add setMetadata() usage example
    - Add set() profile update example
    - Add reset() functionality example
    - _Requirements: 1.1, 6.2, 7.1, 8.1_
    - _Web Reference: examples/originalWebScript/README.md usage examples_

  - [x] 14.3 Update React Native example app
    - Add session management demonstration
    - Add setMetadata() usage example
    - Add set() profile update example
    - Add reset() functionality example
    - _Requirements: 6.2, 7.1, 8.1_
    - _Web Reference: examples/originalWebScript/README.md usage examples_

- [x] 15. Update documentation

  - [x] 15.1 Update README with new features

    - Document init() with brandId and config (web: tracker.ts lines 56-104)
    - Document track() with session ID requirement (web: tracker.ts lines 280-346)
    - Document identify() and set() methods (web: tracker.ts lines 348-403)
    - Document setMetadata() API (web: tracker.ts lines 426-461)
    - Document reset() functionality (web: tracker.ts lines 463-502)
    - Document configuration options (web: types/index.ts lines 1-30)
    - _Requirements: 1.1, 6.1, 6.2, 7.1, 8.1, 11.1, 11.2, 11.3, 11.4, 11.5_
    - _Web Reference: examples/originalWebScript/README.md_

  - [x] 15.2 Create API reference documentation
    - Document all public methods with exact signatures from web
    - Document TrackerConfig options matching web config
    - Document error codes and handling patterns from web
    - Document storage behavior (dual storage like web's cookie + localStorage)
    - _Requirements: 1.1, 4.1, 11.1, 11.2, 11.3, 11.4, 11.5_
    - _Web Reference: types/index.ts and tracker.ts JSDoc comments_

- [ ] 16. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
