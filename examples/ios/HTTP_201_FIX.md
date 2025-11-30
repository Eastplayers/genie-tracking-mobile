# iOS HTTP 201 Status Code Fix

## Problem

The iOS SDK was failing to initialize with the error:

```
[ApiClient] Error: HTTP 201
[ApiClient] Response: {"success":true,"data":{"id":"...","profile_id":"..."}}
[MobileTracker] ❌ Initialization failed: initializationFailed("Failed to create tracking session")
```

Even though the API was returning a successful response with a valid session ID.

## Root Cause

The API correctly returns **HTTP 201 (Created)** when creating a new tracking session, which is the standard REST convention for resource creation. However, the SDK was only accepting **HTTP 200 (OK)** as a success status code.

```swift
// Before - Only accepted 200
guard httpResponse.statusCode == 200 else {
    throw NSError(...)
}
```

## Fix Applied

Updated both `createTrackingSession()` and `trackEvent()` methods in `ApiClient.swift` to accept both 200 and 201 as success:

```swift
// After - Accepts both 200 and 201
guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
    if config.debug {
        print("[ApiClient] Error: HTTP \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("[ApiClient] Response: \(responseString)")
        }
    }
    throw NSError(domain: "ApiClient", code: httpResponse.statusCode,
                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
}
```

## Additional Improvements

Added comprehensive debug logging to help diagnose issues:

1. **Request logging**: Shows URL, payload, and headers
2. **Response logging**: Shows status code and response body on errors
3. **Success logging**: Confirms when operations complete successfully

Example output:

```
[ApiClient] Creating session: POST https://tracking.api.qc.founder-os.ai/api/v2/tracking-session
[ApiClient] Payload: [device_id: ..., os_name: iOS, ...]
[ApiClient] ✅ Session created successfully
[ApiClient] Response: {"success":true,"data":{"id":"5cc588ce-5566-4711-a9d4-012127469542",...}}
[MobileTracker] Initialization completed
✅ MobileTracker initialized successfully
```

## Files Modified

- `ios/MobileTracker/ApiClient.swift`
  - Updated `createTrackingSession()` to accept HTTP 201
  - Updated `trackEvent()` to accept HTTP 201
  - Added comprehensive debug logging throughout

## Testing

The SDK now successfully initializes and creates tracking sessions:

```bash
cd ios
swift build
# Build complete!

cd ../examples/ios
./create-project.sh
open MobileTrackerExample/MobileTrackerExample.xcodeproj
# Run in Xcode - initialization succeeds
```

## HTTP Status Code Reference

- **200 OK**: Standard response for successful HTTP requests
- **201 Created**: The request has been fulfilled and a new resource has been created
- Both are valid success responses and should be treated as such

This is a common pattern in REST APIs where:

- GET requests return 200
- POST requests that create resources return 201
- PUT/PATCH requests return 200
- DELETE requests return 200 or 204

The SDK now correctly handles both success codes.
