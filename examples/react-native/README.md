# React Native Example App

This is a simple React Native example application demonstrating how to use the MobileTracker SDK through the React Native bridge.

## Features

- **Initialize SDK**: The SDK is initialized when the app loads with demo credentials
- **Session Management**: Automatic session creation and management during initialization
- **Identify Users**: Enter a user ID to identify the current user with traits
- **Track Events**: Track custom events with properties
- **Track Screens**: Track screen views with properties
- **Set Metadata**: Add session-level metadata that persists across events
- **Update Profile**: Update user profile data using the set() method
- **Reset Tracking**: Clear session data or reset all tracking data including brand ID
- **Quick Actions**: Pre-configured buttons to track common events (button clicks, purchases, signups)

## Setup

### Prerequisites

- Node.js 16+
- React Native development environment set up for iOS and/or Android
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. Install dependencies:
```bash
cd examples/react-native
npm install
```

2. For iOS, install CocoaPods dependencies:
```bash
cd ios
pod install
cd ..
```

3. Run the app:

**iOS:**
```bash
npm run ios
```

**Android:**
```bash
npm run android
```

## Usage

### Initialize
The SDK is automatically initialized when the app loads with:
- Brand ID: `925` (identifies your application/brand, passed as `apiKey` in React Native)
- API Key: `03dbd95123137cc76b075f50107d8d2d` (for authentication, passed as `x_api_key`)
- API URL: `https://tracking.api.qc.founder-os.ai/api` (backend endpoint)

### Identify a User
1. Enter a user ID in the "Identify User" section
2. Tap "Identify" to associate future events with this user
3. The SDK will automatically add traits like email and plan

### Track Custom Events
1. Enter an event name in the "Track Event" section
2. Tap "Track Event" to send the event
3. The event will include custom properties like source and timestamp

### Track Screen Views
1. Enter a screen name in the "Track Screen" section
2. Tap "Track Screen" to record the screen view
3. The screen event will include properties like previous screen and load time

### Set Metadata
1. Enter a metadata key and value in the "Set Metadata" section
2. Tap "Set Metadata" to add session-level metadata
3. This metadata will be included with all subsequent events

### Update Profile
1. Enter name and/or email in the "Update Profile (set)" section
2. Tap "Update Profile" to update the user's profile data
3. This uses the set() method to update profile without requiring a user ID

### Reset Tracking
Use the reset functionality to clear tracking data:
- **Reset Session**: Clears session data but preserves brand ID
- **Reset All**: Clears all tracking data including brand ID (with confirmation)

### Quick Actions
Use the pre-configured buttons to quickly test common tracking scenarios:
- **Button Click**: Tracks a button interaction event
- **Purchase**: Tracks a purchase with product details and price
- **Signup**: Tracks a user signup event

## Code Examples

### Initialize SDK with Session Management
```typescript
import MobileTracker from '@mobiletracker/react-native';

// Initialize with brand ID, API key, and configuration
await MobileTracker.init({
  apiKey: '925',  // Your Brand ID (passed as apiKey for React Native bridge)
  endpoint: 'https://tracking.api.qc.founder-os.ai/api',  // Backend API URL
  x_api_key: '03dbd95123137cc76b075f50107d8d2d',  // Your API key for authentication
  debug: true
});
// Session is automatically created during initialization
```

### Identify User
```typescript
MobileTracker.identify('user123', {
  email: 'user@example.com',
  plan: 'premium'
});
```

### Track Event
```typescript
MobileTracker.track('Button Clicked', {
  buttonName: 'signup',
  screen: 'home'
});
```

### Track Screen
```typescript
MobileTracker.screen('Home Screen', {
  previousScreen: 'login'
});
```

### Set Metadata
```typescript
await MobileTracker.setMetadata({
  app_version: '1.2.3',
  feature_flags: ['new_ui', 'beta_feature'],
  environment: 'production'
});
```

### Update Profile with set()
```typescript
await MobileTracker.set({
  name: 'John Doe',
  email: 'john@example.com',
  plan: 'premium'
});
```

### Reset Tracking
```typescript
// Reset session data but keep brand ID
MobileTracker.reset(false);

// Reset all data including brand ID
MobileTracker.reset(true);
```

## Project Structure

```
examples/react-native/
├── App.tsx                 # Main application component
├── index.js               # App entry point
├── package.json           # Dependencies and scripts
├── tsconfig.json          # TypeScript configuration
├── babel.config.js        # Babel configuration
├── metro.config.js        # Metro bundler configuration
├── app.json              # App metadata
└── README.md             # This file
```

## Requirements

- React Native 0.70+
- Node.js 16+
- iOS 13.0+ (for iOS)
- Android API 21+ (for Android)
- MobileTracker React Native Bridge

## Features Demonstrated

This example app demonstrates all the requirements specified in:
- **Requirements 1.1**: Initialize with brand ID and configuration
- **Requirements 2.1, 2.2**: Session management and automatic session creation
- **Requirements 5.1-5.5**: Track events through React Native bridge
- **Requirements 6.1, 6.2**: Identify users and update profiles through React Native bridge
- **Requirements 7.1**: Set metadata through React Native bridge
- **Requirements 8.1**: Reset tracking data through React Native bridge

## Notes

- All events are logged to the console for debugging
- Status messages appear at the top of the screen
- The app works on both iOS and Android platforms
- Sessions are automatically created during SDK initialization
- Automatic screen tracking is enabled by default on native platforms
- Internet permission is automatically included for network requests
- The bridge handles data serialization between JavaScript and native code
- Reset All includes a confirmation dialog to prevent accidental data loss

## Troubleshooting

### iOS Build Issues
- Make sure CocoaPods are installed: `pod install`
- Clean build folder in Xcode if needed

### Android Build Issues
- Make sure Android SDK is properly configured
- Run `./gradlew clean` in the android directory if needed

### Metro Bundler Issues
- Clear Metro cache: `npm start -- --reset-cache`
- Delete `node_modules` and reinstall: `rm -rf node_modules && npm install`
