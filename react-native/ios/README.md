# MobileTracker iOS Bridge

This directory contains the iOS native module bridge for React Native.

## Files

- `MobileTrackerBridge.h` - Objective-C header file declaring the bridge module
- `MobileTrackerBridge.m` - Objective-C implementation that forwards calls to the iOS SDK

## Integration

The bridge automatically forwards all React Native calls to the native iOS SDK:

- `initialize(apiKey, endpoint)` → `MobileTracker.shared.initialize(apiKey:endpoint:maxQueueSize:error:)`
- `track(event, properties)` → `MobileTracker.shared.track(event:properties:)`
- `identify(userId, traits)` → `MobileTracker.shared.identify(userId:traits:)`
- `screen(name, properties)` → `MobileTracker.shared.screen(name:properties:)`

## Data Serialization

The bridge handles automatic serialization between JavaScript and native types:

- JavaScript objects → NSDictionary
- JavaScript arrays → NSArray
- JavaScript strings → NSString
- JavaScript numbers → NSNumber
- JavaScript booleans → NSNumber (BOOL)
- JavaScript null → nil

## Error Handling

The `initialize` method returns a Promise that:

- Resolves with `nil` on success
- Rejects with error code and message on failure

Error codes:

- `INVALID_API_KEY` - Empty or invalid API key
- `INVALID_ENDPOINT` - Empty or malformed endpoint URL
- `INIT_ERROR` - General initialization error

## Requirements

- React Native 0.70+
- iOS 13.0+
- MobileTracker iOS SDK
