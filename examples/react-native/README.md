# React Native Example App

This is a React Native example application demonstrating how to use the MobileTracker SDK through the React Native bridge. The app features an interactive configuration UI that allows you to set up tracking credentials directly in the app before initializing the SDK.

## Features

- **Interactive Configuration UI**: Configure API credentials and environment directly in the app
- **Environment Selection**: Choose between QC (staging) and Production environments
- **Configuration Persistence**: Automatically save and restore configuration across app restarts
- **Session Management**: Automatic session creation and management during initialization
- **Identify Users**: Enter a user ID to identify the current user with traits
- **Track Events**: Track custom events with properties
- **Track Screens**: Track screen views with properties
- **Set Metadata**: Add session-level metadata that persists across events
- **Update Profile**: Update user profile data using the set() method
- **Reset Tracking**: Clear session data or reset all tracking data including brand ID
- **Quick Actions**: Pre-configured buttons to track common events (button clicks, purchases, signups)
- **Reconfiguration**: Change configuration settings at any time without reinstalling the app

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

## Configuration UI

### First Launch

When you launch the app for the first time, you'll see the Configuration Screen with the following fields:

- **API Key**: Your authentication token for the backend API (X-API-KEY header)
- **Brand ID**: Unique identifier for your tracking brand/organization
- **User ID** (optional): Unique identifier for the current user being tracked
- **Environment**: Dropdown to select between QC (staging) and Production environments

### Configuring the SDK

1. **Enter API Key**: Paste your API key in the "API Key" field
2. **Enter Brand ID**: Enter your brand ID in the "Brand ID" field
3. **Select Environment**: Choose "QC" for staging or "Production" for live tracking
4. **Enter User ID** (optional): If you want to track a specific user, enter their ID
5. **Tap Initialize**: Press the "Initialize Tracker" button to save configuration and start tracking

The app will validate that required fields (API Key and Brand ID) are filled before allowing initialization.

### Environment URLs

The app automatically maps environments to the correct API URLs:

- **QC Environment**: `https://tracking.api.qc.founder-os.ai/api`
- **Production Environment**: `https://tracking.api.founder-os.ai/api`

### Configuration Persistence

Once you initialize the SDK with valid credentials, the configuration is automatically saved to the device's AsyncStorage. This means:

- **Automatic Initialization**: On subsequent app launches, the saved configuration is loaded and the SDK initializes automatically
- **No Configuration Screen**: If configuration exists, you'll go directly to the demo screen
- **Pre-filled Values**: If you access the configuration screen again, all fields will be pre-filled with your saved values

### Changing Configuration

To change your configuration after initialization:

1. **Tap Settings**: Press the ⚙️ Settings button in the top-right corner of the demo screen
2. **Modify Values**: Update any of the configuration fields
3. **Tap Initialize**: Press "Initialize Tracker" to save the new configuration
4. **Automatic Reset**: The SDK will automatically reset and reinitialize with the new configuration

### Clearing Configuration

To clear the saved configuration and return to the setup screen:

1. Tap Settings to open the configuration screen
2. Clear the fields and tap Initialize with empty values (this will show validation errors)
3. Alternatively, use the Reset All button in the demo screen to clear all tracking data including configuration

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

## Configuration Examples

### Example 1: Initial Setup with QC Environment

1. Launch the app for the first time
2. You'll see the Configuration Screen
3. Enter:
   - API Key: `your-api-key-here`
   - Brand ID: `925`
   - User ID: `test-user-123` (optional)
   - Environment: Select "QC"
4. Tap "Initialize Tracker"
5. The configuration is saved and you'll see the demo screen

### Example 2: Switching to Production

1. Tap the ⚙️ Settings button in the top-right corner
2. The configuration screen opens with your current values pre-filled
3. Change the Environment dropdown from "QC" to "Production"
4. Tap "Initialize Tracker"
5. The SDK resets and reinitializes with the production API URL

### Example 3: Changing User ID

1. Tap the ⚙️ Settings button
2. Update the User ID field with a different user
3. Tap "Initialize Tracker"
4. The SDK resets and reinitializes with the new user ID

### Example 4: Testing Different Credentials

1. Tap the ⚙️ Settings button
2. Update the API Key and/or Brand ID
3. Tap "Initialize Tracker"
4. The new credentials are saved and the SDK reinitializes
5. All subsequent events will use the new credentials

## Code Examples

### Configuration Management

#### Load Saved Configuration

```typescript
import { useConfigurationManager } from './src/useConfigurationManager'

const configManager = useConfigurationManager()

// Load configuration from AsyncStorage
const savedConfig = await configManager.loadConfiguration()
if (savedConfig) {
  console.log('Configuration found:', savedConfig)
} else {
  console.log('No configuration saved')
}
```

#### Save Configuration

```typescript
import { useConfigurationManager } from './src/useConfigurationManager'

const configManager = useConfigurationManager()

const config = {
  apiKey: 'your-api-key',
  brandId: '925',
  userId: 'user123',
  environment: 'qc' as const,
}

// Save configuration to AsyncStorage
await configManager.saveConfiguration(config)
```

#### Validate Configuration

```typescript
import { useConfigurationManager } from './src/useConfigurationManager'

const configManager = useConfigurationManager()

const config = {
  apiKey: 'your-api-key',
  brandId: '925',
  userId: 'user123',
  environment: 'qc' as const,
}

// Validate configuration
const validation = configManager.validateConfiguration(config)
if (validation.valid) {
  console.log('Configuration is valid')
} else {
  console.log('Validation errors:', validation.errors)
}
```

#### Get API URL for Environment

```typescript
import { useConfigurationManager } from './src/useConfigurationManager'

const configManager = useConfigurationManager()

// Get API URL based on environment
const qcUrl = configManager.getApiUrl('qc')
// Returns: https://tracking.api.qc.founder-os.ai/api

const prodUrl = configManager.getApiUrl('production')
// Returns: https://tracking.api.founder-os.ai/api
```

### Initialize SDK with Session Management

```typescript
import MobileTracker from '@mobiletracker/react-native'

// Initialize with brand ID, API key, and configuration
await MobileTracker.init({
  apiKey: '925', // Your Brand ID (passed as apiKey for React Native bridge)
  endpoint: 'https://tracking.api.qc.founder-os.ai/api', // Backend API URL
  x_api_key: '03dbd95123137cc76b075f50107d8d2d', // Your API key for authentication
  debug: true,
})
// Session is automatically created during initialization
```

### Identify User

```typescript
MobileTracker.identify('user123', {
  email: 'user@example.com',
  plan: 'premium',
})
```

### Track Event

```typescript
MobileTracker.track('Button Clicked', {
  buttonName: 'signup',
  screen: 'home',
})
```

### Track Screen

```typescript
MobileTracker.screen('Home Screen', {
  previousScreen: 'login',
})
```

### Set Metadata

```typescript
await MobileTracker.setMetadata({
  app_version: '1.2.3',
  feature_flags: ['new_ui', 'beta_feature'],
  environment: 'production',
})
```

### Update Profile with set()

```typescript
await MobileTracker.set({
  name: 'John Doe',
  email: 'john@example.com',
  plan: 'premium',
})
```

### Reset Tracking

```typescript
// Reset session data but keep brand ID
MobileTracker.reset(false)

// Reset all data including brand ID
MobileTracker.reset(true)
```

## Project Structure

```
examples/react-native/
├── App.tsx                              # Main application component with configuration management
├── src/
│   ├── ConfigurationScreen.tsx          # Configuration UI component
│   ├── configurationManager.ts          # Configuration utilities and validation
│   └── useConfigurationManager.ts       # Configuration management hook
├── index.js                             # App entry point
├── package.json                         # Dependencies and scripts
├── tsconfig.json                        # TypeScript configuration
├── babel.config.js                      # Babel configuration
├── metro.config.js                      # Metro bundler configuration
├── app.json                             # App metadata
└── README.md                            # This file
```

### Key Files

- **App.tsx**: Main component that handles app initialization, configuration loading, and screen switching between ConfigurationScreen and DemoScreen
- **ConfigurationScreen.tsx**: UI component for entering API credentials, selecting environment, and initializing the SDK
- **configurationManager.ts**: Utility functions for configuration validation, environment URL mapping, and AsyncStorage key management
- **useConfigurationManager.ts**: React hook that provides methods for loading, saving, and managing configuration

## Requirements

- React Native 0.70+
- Node.js 16+
- iOS 13.0+ (for iOS)
- Android API 21+ (for Android)
- MobileTracker React Native Bridge

## Features Demonstrated

This example app demonstrates all the requirements specified in the React Native Example Config UI spec:

### Configuration UI Requirements

- **Requirement 1.1**: Display configuration screen with input fields for API key, brand ID, user ID, and environment selection
- **Requirement 1.2**: Validate inputs and prevent initialization with missing required fields
- **Requirement 1.3**: Display error messages for validation failures
- **Requirement 1.4**: Map QC environment to correct API URL
- **Requirement 1.5**: Map Production environment to correct API URL
- **Requirement 1.6**: Dismiss configuration screen and display demo interface after successful initialization
- **Requirement 2.1**: Persist configuration to AsyncStorage on successful initialization
- **Requirement 2.2**: Load persisted configuration and automatically initialize on app restart
- **Requirement 2.4**: Pre-fill configuration screen with saved values
- **Requirement 3.1**: Provide settings button to access configuration
- **Requirement 3.2**: Display configuration screen with current values pre-filled
- **Requirement 3.3**: Reset tracker and reinitialize with new configuration
- **Requirement 3.4**: Persist new configuration values to AsyncStorage

### SDK Tracking Features

- **Session Management**: Automatic session creation and management during initialization
- **Track Events**: Track custom events with properties
- **Track Screens**: Track screen views with properties
- **Identify Users**: Associate events with specific users
- **Set Metadata**: Add session-level metadata
- **Update Profile**: Update user profile data
- **Reset Tracking**: Clear session data or all tracking data

## Notes

- **Configuration UI**: The app features an interactive configuration screen for easy setup without editing files
- **AsyncStorage Persistence**: Configuration is automatically saved to device storage and restored on app restart
- **Environment Switching**: Easily switch between QC and Production environments without reinstalling
- **Validation**: The app validates required fields (API Key and Brand ID) before allowing initialization
- **Pre-filled Values**: When accessing settings, all configuration fields are pre-filled with current values
- **Automatic Initialization**: If configuration exists, the SDK initializes automatically on app launch
- **All events are logged to the console for debugging**
- **Status messages appear at the top of the screen**
- **The app works on both iOS and Android platforms**
- **Sessions are automatically created during SDK initialization**
- **Automatic screen tracking is enabled by default on native platforms**
- **Internet permission is automatically included for network requests**
- **The bridge handles data serialization between JavaScript and native code**
- **Reset All includes a confirmation dialog to prevent accidental data loss**

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
