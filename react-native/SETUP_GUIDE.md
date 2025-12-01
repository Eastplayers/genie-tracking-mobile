# React Native Setup Guide

Complete integration guide for the FounderOS Mobile Tracking SDK for React Native applications.

## Introduction

The FounderOS Mobile Tracking SDK provides simple, reliable event tracking with automatic context enrichment, user identification, session management, and screen tracking capabilities for React Native applications. This guide will walk you through installing and integrating the SDK into your React Native app.

**What you'll accomplish:**

- Install the SDK using npm or yarn
- Configure platform-specific setup for iOS and Android
- Initialize the tracker with your configuration
- Track custom events with attributes
- Identify users and update profiles
- Set session-level metadata
- Handle user logout with session reset
- Verify tracking is working correctly

**Time to complete:** 10-15 minutes

---

## Installation

### Option 1: npm (Recommended)

```bash
npm install @founderos/mobile-tracker-react-native
```

### Option 2: yarn

```bash
yarn add @founderos/mobile-tracker-react-native
```

### Platform-Specific Setup

#### iOS Setup

Navigate to the iOS directory and install CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

**Note:** React Native 0.60+ supports auto-linking, so no manual linking is required.

#### Android Setup

For React Native 0.60+, auto-linking handles the setup automatically. No additional configuration needed.

**Verify auto-linking:** Check that the module is linked by running:

```bash
npx react-native config
```

---

## Quick Start

Get up and running in under 5 minutes with this minimal example:

```typescript
import MobileTracker from '@founderos/mobile-tracker-react-native'

// Initialize on app launch
await MobileTracker.init({
  apiKey: 'YOUR_BRAND_ID',
  x_api_key: 'YOUR_API_KEY',
  debug: true,
})

// Track an event
MobileTracker.track('BUTTON_CLICK', {
  button_name: 'signup',
})
```

---

## Step-by-Step Setup

### Step 1: Installation

Follow the installation instructions above using npm or yarn, then complete the platform-specific setup.

**Expected result:** The SDK is added to your project and you can import `MobileTracker` in your TypeScript/JavaScript files.

---

### Step 2: Initialize the SDK

Initialize the tracker when your app launches. The best place is in your root component (usually `App.tsx` or `index.js`).

**App.tsx Example:**

```typescript
import React, { useEffect } from 'react'
import { View, Text } from 'react-native'
import MobileTracker from '@founderos/mobile-tracker-react-native'

const App = () => {
  useEffect(() => {
    // Initialize SDK on app launch
    const initTracker = async () => {
      try {
        await MobileTracker.init({
          apiKey: '123', // Your brand ID
          x_api_key: 'your-api-key-here',
          debug: true,
          endpoint: undefined, // Optional: defaults to production
        })
        console.log('✅ Tracker initialized')
      } catch (error) {
        console.error('❌ Tracker initialization failed:', error)
      }
    }

    initTracker()
  }, [])

  return (
    <View>
      <Text>My App</Text>
    </View>
  )
}

export default App
```

**What this does:**

- Creates a tracking session with the backend
- Initializes storage for session and device data
- Sets up automatic screen view tracking
- Prepares the SDK to queue and send events

**Configuration Parameters:**

- `apiKey` (string, required): Your unique brand identifier (must be numeric)
- `x_api_key` (string, required): API key for authentication
- `debug` (boolean, optional): Enable debug logging (default: `false`)
- `endpoint` (string, optional): Custom API endpoint (default: `https://tracking.api.founder-os.ai/api`)

**Expected result:** The SDK initializes without errors and you see a success message in the console.

---

### Step 3: Track Events

Track user actions and behaviors throughout your app.

**Basic Event Tracking:**

```typescript
import MobileTracker from '@founderos/mobile-tracker-react-native'

// Simple event
MobileTracker.track('BUTTON_CLICK')

// Event with properties
MobileTracker.track('PURCHASE_COMPLETED', {
  product_id: 'prod_123',
  amount: 29.99,
  currency: 'USD',
})
```

**Real-World Examples:**

```typescript
import React from 'react'
import { Button, View } from 'react-native'
import MobileTracker from '@founderos/mobile-tracker-react-native'

const MyComponent = () => {
  const handleSignup = () => {
    // Track button click
    MobileTracker.track('BUTTON_CLICK', {
      button_name: 'signup',
      screen: 'home',
    })
  }

  const handlePurchase = () => {
    // Track purchase
    MobileTracker.track('PURCHASE_COMPLETED', {
      product_id: 'prod_123',
      amount: 29.99,
      currency: 'USD',
    })
  }

  const handleFormSubmit = () => {
    // Track form submission
    MobileTracker.track('FORM_SUBMITTED', {
      form_name: 'contact',
      fields_count: 5,
    })
  }

  return (
    <View>
      <Button title="Sign Up" onPress={handleSignup} />
      <Button title="Purchase" onPress={handlePurchase} />
      <Button title="Submit Form" onPress={handleFormSubmit} />
    </View>
  )
}
```

**What this does:**

- Sends events to the backend with automatic context enrichment
- Adds device info, platform, OS version, and timestamps automatically
- Queues events if network is unavailable and retries later

**Expected result:** Events appear in your FounderOS dashboard within seconds.

---

### Step 4: Identify Users

Associate events with specific users after login or signup.

```typescript
import MobileTracker from '@founderos/mobile-tracker-react-native'

// Basic identification
MobileTracker.identify('user_12345')

// Identification with traits
MobileTracker.identify('user_12345', {
  email: 'user@example.com',
  name: 'John Doe',
  plan: 'premium',
})
```

**When to call identify:**

- After successful login
- After user registration
- When user data is loaded from storage

**Example in login flow:**

```typescript
import React, { useState } from 'react'
import { View, TextInput, Button } from 'react-native'
import MobileTracker from '@founderos/mobile-tracker-react-native'

const LoginScreen = () => {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const handleLogin = async () => {
    try {
      const user = await authService.login(email, password)

      // Identify user after successful login
      MobileTracker.identify(user.id, {
        email: user.email,
        name: user.name,
        created_at: user.createdAt,
      })

      console.log('✅ User identified')
    } catch (error) {
      console.error('❌ Login failed:', error)
    }
  }

  return (
    <View>
      <TextInput placeholder="Email" value={email} onChangeText={setEmail} />
      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      <Button title="Login" onPress={handleLogin} />
    </View>
  )
}
```

**What this does:**

- Links all subsequent events to this user
- Updates the user profile in the backend
- Persists user ID across app sessions

**Expected result:** Events in your dashboard show the associated user ID and profile data.

---

### Step 5: Update User Profiles

Update user profile information as it changes.

```typescript
import MobileTracker from '@founderos/mobile-tracker-react-native'

// Update profile data
await MobileTracker.set({
  plan: 'enterprise',
  company: 'Acme Corp',
  phone: '+1234567890',
})

// Update single field
await MobileTracker.set({
  last_login: new Date().toISOString(),
})
```

**Common use cases:**

```typescript
// After subscription upgrade
await MobileTracker.set({
  plan: 'premium',
  subscription_date: new Date().toISOString(),
})

// After profile edit
await MobileTracker.set({
  name: updatedName,
  phone: updatedPhone,
  preferences: userPreferences,
})
```

**What this does:**

- Updates user profile without changing user ID
- Merges new data with existing profile
- Useful for tracking user progression and changes

**Expected result:** User profile in dashboard reflects the updated information.

---

### Step 6: Set Session Metadata

Add context that applies to all events in the current session.

```typescript
import MobileTracker from '@founderos/mobile-tracker-react-native'

// Set session-level metadata
await MobileTracker.setMetadata({
  app_version: '2.1.0',
  build_number: '145',
  environment: 'production',
})

// Add experiment/feature flag data
await MobileTracker.setMetadata({
  experiment_group: 'variant_b',
  feature_new_ui: true,
  ab_test_id: 'test_123',
})
```

**When to use metadata:**

- Feature flags and A/B test assignments
- App version and build information
- Session type (guest vs authenticated)
- Environment information (staging, production)

**Example with feature flags:**

```typescript
import { useEffect } from 'react'
import MobileTracker from '@founderos/mobile-tracker-react-native'
import DeviceInfo from 'react-native-device-info'

const setupSessionContext = async () => {
  await MobileTracker.setMetadata({
    app_version: DeviceInfo.getVersion(),
    feature_dark_mode:
      (await AsyncStorage.getItem('dark_mode_enabled')) === 'true',
    experiment_checkout_flow: 'variant_a',
    user_segment: 'power_user',
  })
}

// Call in App component
useEffect(() => {
  setupSessionContext()
}, [])
```

**What this does:**

- Attaches metadata to all subsequent events in the session
- Useful for filtering and segmenting events in analytics
- Persists until session is reset or app is restarted

**Expected result:** All tracked events include the metadata fields in your dashboard.

---

### Step 7: Track Screen Views

Track when users navigate to different screens in your app.

```typescript
import MobileTracker from '@founderos/mobile-tracker-react-native'

// Track screen view
MobileTracker.screen('Home Screen', {
  section: 'main',
  tab: 'feed',
})
```

**React Navigation Integration:**

```typescript
import React from 'react'
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import MobileTracker from '@founderos/mobile-tracker-react-native'

const Stack = createNativeStackNavigator()

const App = () => {
  const navigationRef = React.useRef(null)

  return (
    <NavigationContainer
      ref={navigationRef}
      onStateChange={() => {
        const currentRoute = navigationRef.current?.getCurrentRoute()
        if (currentRoute) {
          MobileTracker.screen(currentRoute.name, {
            params: currentRoute.params,
          })
        }
      }}
    >
      <Stack.Navigator>{/* Your screens */}</Stack.Navigator>
    </NavigationContainer>
  )
}
```

**What this does:**

- Records screen navigation patterns
- Helps understand user flow through your app
- Automatically includes screen name and properties

**Expected result:** Screen view events appear in your dashboard showing navigation patterns.

---

### Step 8: Reset on Logout

Clear user data and create a new session when users log out.

```typescript
import MobileTracker from '@founderos/mobile-tracker-react-native'

// Reset user data but keep session
MobileTracker.reset(false)

// Reset everything including brand ID (rare)
MobileTracker.reset(true)
```

**Example in logout flow:**

```typescript
const handleLogout = async () => {
  // Clear user session
  await authService.logout()

  // Reset tracker to clear user identification
  MobileTracker.reset(false)

  console.log('✅ User logged out and tracker reset')

  // Navigate to login screen
  navigation.navigate('Login')
}
```

**What `reset()` does:**

- Clears `session_id`, `device_id`, `session_email`, `identify_id`
- Creates a new tracking session
- Clears pending events
- Resets internal state

**What `reset(true)` does:**

- Everything above, plus clears `brand_id`
- Use only when completely reinitializing the SDK

**Expected result:** New events after reset are not associated with the previous user.

---

### Step 9: Verify Tracking

Confirm the SDK is working correctly.

**1. Enable Debug Mode:**

```typescript
await MobileTracker.init({
  apiKey: '123',
  x_api_key: 'your-api-key',
  debug: true, // Enable debug logging
})
```

**2. Check Console Logs:**

Look for these messages in your development console:

```
✅ Tracker initialized
[MobileTracker] Session created asynchronously: success
[MobileTracker] Event tracked: BUTTON_CLICK
```

**3. Check Dashboard:**

- Log into your FounderOS dashboard
- Navigate to Events or Analytics section
- Verify events appear with correct data
- Check that user identification is working

**4. Test Event Flow:**

```typescript
// Test complete flow
const testTracking = async () => {
  try {
    // 1. Initialize
    await MobileTracker.init({
      apiKey: '123',
      x_api_key: 'your-api-key',
      debug: true,
    })

    // 2. Track test event
    MobileTracker.track('TEST_EVENT', { test: true })

    // 3. Identify test user
    MobileTracker.identify('test_user_123', {
      email: 'test@example.com',
    })

    // 4. Track another event
    MobileTracker.track('TEST_EVENT_AFTER_IDENTIFY', {
      identified: true,
    })

    console.log('✅ Test flow completed - check dashboard')
  } catch (error) {
    console.error('❌ Test failed:', error)
  }
}
```

**Expected result:**

- Console shows successful initialization and event tracking
- Dashboard displays all test events
- Events after `identify()` show user association

---

## All-in-One Example

Complete integration showing all features together:

```typescript
import React, { useEffect, useState } from 'react'
import { View, Text, Button, StyleSheet, SafeAreaView } from 'react-native'
import MobileTracker from '@founderos/mobile-tracker-react-native'

const App = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false)

  useEffect(() => {
    // Initialize on app launch
    const initTracker = async () => {
      try {
        await MobileTracker.init({
          apiKey: '123',
          x_api_key: 'your-api-key-here',
          debug: true,
        })

        // Set session metadata
        await MobileTracker.setMetadata({
          app_version: '1.0.0',
          environment: 'production',
        })

        console.log('✅ Tracker ready')
      } catch (error) {
        console.error('❌ Tracker failed:', error)
      }
    }

    initTracker()
  }, [])

  useEffect(() => {
    // Track screen view
    MobileTracker.screen('Home Screen', {
      logged_in: isLoggedIn,
    })
  }, [isLoggedIn])

  const handleLogin = () => {
    // Simulate login
    const userId = 'user_12345'

    // Identify user
    MobileTracker.identify(userId, {
      email: 'user@example.com',
      name: 'John Doe',
    })

    // Track login event
    MobileTracker.track('USER_LOGGED_IN', {
      method: 'email',
    })

    setIsLoggedIn(true)
  }

  const handlePurchase = () => {
    MobileTracker.track('PURCHASE_COMPLETED', {
      product_id: 'prod_123',
      amount: 29.99,
    })
  }

  const handleUpdateProfile = async () => {
    await MobileTracker.set({
      plan: 'premium',
      last_active: new Date().toISOString(),
    })
  }

  const handleLogout = () => {
    // Reset tracker on logout
    MobileTracker.reset(false)
    setIsLoggedIn(false)
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Mobile Tracker Demo</Text>

        {isLoggedIn ? (
          <>
            <Text style={styles.status}>✅ Logged In</Text>
            <Button title="Track Purchase" onPress={handlePurchase} />
            <Button title="Update Profile" onPress={handleUpdateProfile} />
            <Button title="Logout" onPress={handleLogout} />
          </>
        ) : (
          <>
            <Text style={styles.status}>Not Logged In</Text>
            <Button title="Login" onPress={handleLogin} />
          </>
        )}
      </View>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  status: {
    fontSize: 16,
    marginBottom: 20,
  },
})

export default App
```

**What this example demonstrates:**

- ✅ SDK initialization on app launch
- ✅ Session metadata setup
- ✅ Event tracking with properties
- ✅ User identification on login
- ✅ Profile updates
- ✅ Session reset on logout
- ✅ Screen view tracking

---

## Best Practices

### Performance

**Initialize Early:**

```typescript
// ✅ Good: Initialize in App component
const App = () => {
  useEffect(() => {
    MobileTracker.init({...});
  }, []);
};

// ❌ Bad: Don't initialize in every screen
const MyScreen = () => {
  useEffect(() => {
    MobileTracker.init({...});  // Wrong!
  }, []);
};
```

**Batch Events:**

```typescript
// ✅ Good: Track meaningful events
MobileTracker.track('CHECKOUT_COMPLETED')

// ❌ Bad: Don't track every tiny interaction
MobileTracker.track('TEXT_INPUT_CHANGED') // Too granular
```

**Avoid Blocking Operations:**

```typescript
// ✅ Good: Non-blocking tracking
MobileTracker.track('EVENT');  // Returns immediately

// ✅ Good: Async operations with await
await MobileTracker.init({...});
await MobileTracker.set({...});
```

### Privacy

**Respect User Consent:**

```typescript
// Check consent before initializing
if (userHasGrantedTrackingConsent) {
  await MobileTracker.init({
    apiKey: 'your-brand-id',
    x_api_key: 'your-api-key',
  })
}
```

**Don't Track PII Without Consent:**

```typescript
// ✅ Good: Use hashed or anonymized IDs
MobileTracker.identify('user_abc123')

// ⚠️ Careful: Only if user consented
MobileTracker.identify('user_123', {
  email: 'user@example.com', // Requires consent
})
```

**Clear Data on Logout:**

```typescript
// Always reset on logout
const logout = () => {
  MobileTracker.reset(false)
  // Clear other user data...
}
```

### Event Naming

**Use Consistent Naming:**

```typescript
// ✅ Good: SCREAMING_SNAKE_CASE
MobileTracker.track('BUTTON_CLICK')
MobileTracker.track('PURCHASE_COMPLETED')
MobileTracker.track('VIDEO_PLAYED')

// ❌ Bad: Inconsistent naming
MobileTracker.track('buttonClick')
MobileTracker.track('purchase-completed')
MobileTracker.track('Video Played')
```

**Be Descriptive:**

```typescript
// ✅ Good: Clear and specific
MobileTracker.track('CHECKOUT_PAYMENT_METHOD_SELECTED')

// ❌ Bad: Too vague
MobileTracker.track('CLICK')
```

### Properties vs Metadata

**Use Properties for Event-Specific Data:**

```typescript
// Event-specific information
MobileTracker.track('PRODUCT_VIEWED', {
  product_id: 'prod_123',
  category: 'electronics',
  price: 299.99,
})
```

**Use Metadata for Session-Wide Context:**

```typescript
// Session-wide information
await MobileTracker.setMetadata({
  app_version: '2.1.0',
  user_segment: 'premium',
  ab_test_variant: 'B',
})
```

### Error Handling

**Handle Initialization Errors:**

```typescript
try {
  await MobileTracker.init({
    apiKey: '123',
    x_api_key: 'key',
  })
} catch (error) {
  // Log error but don't crash the app
  console.error('Tracker initialization failed:', error)
  // Optionally report to error tracking service
}
```

**Graceful Degradation:**

```typescript
// SDK handles errors internally - tracking failures won't crash your app
MobileTracker.track('EVENT') // Safe even if not initialized
```

---

## Troubleshooting

### SDK Not Loading

**Problem:** Import fails or SDK not found

**Solutions:**

1. **Reinstall dependencies:**

   ```bash
   # npm
   npm install

   # yarn
   yarn install
   ```

2. **Clear cache and reinstall:**

   ```bash
   # npm
   rm -rf node_modules package-lock.json
   npm install

   # yarn
   rm -rf node_modules yarn.lock
   yarn install
   ```

3. **iOS: Reinstall pods:**

   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   cd ..
   ```

4. **Android: Clean build:**

   ```bash
   cd android
   ./gradlew clean
   cd ..
   ```

5. **Check React Native version:** SDK requires React Native 0.70+

   ```json
   // package.json
   {
     "dependencies": {
       "react-native": ">=0.70.0"
     }
   }
   ```

### Events Not Tracking

**Problem:** Events don't appear in dashboard

**Solutions:**

1. **Check initialization:**

   ```typescript
   // Enable debug mode
   await MobileTracker.init({
     apiKey: '123',
     x_api_key: 'key',
     debug: true, // Enable debug logging
   })
   // Look for "✅ Tracker initialized" in console
   ```

2. **Verify API key and brand ID:**

   ```typescript
   // Ensure these are correct
   apiKey: '123' // Must be numeric string
   x_api_key: 'your-actual-api-key' // Check dashboard for correct key
   ```

3. **Check network connectivity:**

   - Events are queued if offline and sent when online
   - Check console for network errors
   - Test on a real device with internet connection

4. **Wait for initialization:**
   ```typescript
   // Ensure init completes before tracking
   await MobileTracker.init({...});
   MobileTracker.track('EVENT');  // Now safe to track
   ```

### Initialization Failures

**Problem:** Initialization throws error or times out

**Solutions:**

1. **Invalid brand ID:**

   ```typescript
   // ❌ Wrong: Non-numeric
   apiKey: 'my-brand'

   // ✅ Correct: Numeric string
   apiKey: '123'
   ```

2. **Missing API key:**

   ```typescript
   // ❌ Wrong: Missing x_api_key
   await MobileTracker.init({
     apiKey: '123',
   })

   // ✅ Correct: Include x_api_key
   await MobileTracker.init({
     apiKey: '123',
     x_api_key: 'your-api-key',
   })
   ```

3. **Network timeout:**

   - Check internet connection
   - Verify API URL is reachable
   - Check firewall/proxy settings

4. **Invalid endpoint:**

   ```typescript
   // ✅ Correct: Valid URL or undefined for default
   endpoint: undefined // Uses default
   endpoint: 'https://tracking.api.founder-os.ai/api'

   // ❌ Wrong: Invalid URL
   endpoint: 'not-a-url'
   ```

### Events Not Associated with User

**Problem:** Events tracked after `identify()` don't show user info

**Solutions:**

1. **Call identify after initialization:**

   ```typescript
   // ✅ Correct order
   await MobileTracker.init({...});
   MobileTracker.identify('user_123');
   MobileTracker.track('EVENT');

   // ❌ Wrong: identify before init
   MobileTracker.identify('user_123');  // Won't work
   await MobileTracker.init({...});
   ```

2. **Check user ID is not empty:**

   ```typescript
   // ❌ Wrong: Empty user ID
   MobileTracker.identify('')

   // ✅ Correct: Valid user ID
   MobileTracker.identify('user_123')
   ```

### Build Errors

**Problem:** Compilation errors or warnings

**Solutions:**

1. **TypeScript errors:**

   - Ensure TypeScript is properly configured
   - Check `tsconfig.json` includes the SDK

2. **iOS build errors:**

   ```bash
   # Clean and rebuild
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   cd ..
   npx react-native run-ios
   ```

3. **Android build errors:**

   ```bash
   # Clean and rebuild
   cd android
   ./gradlew clean
   cd ..
   npx react-native run-android
   ```

4. **Auto-linking issues:**
   ```bash
   # Check auto-linking status
   npx react-native config
   ```

### Debug Logging

Enable detailed logging to diagnose issues:

```typescript
await MobileTracker.init({
  apiKey: '123',
  x_api_key: 'key',
  debug: true, // Enable debug logs
})
```

**What to look for in console:**

- `✅ Tracker initialized` - Initialization succeeded
- `Session created asynchronously: success` - Session created
- `Event tracked: EVENT_NAME` - Event sent successfully
- `⚠️ Not initialized` - SDK not initialized before use
- `❌ Initialization failed` - Initialization error

**Enable native logs:**

**iOS (Xcode):**

- Open Xcode console
- Filter by "MobileTracker"

**Android (Logcat):**

```bash
adb logcat | grep MobileTracker
```

---

## Platform-Specific Notes

### React Native Version Requirements

- **Minimum React Native Version:** 0.70+
- **Minimum Node Version:** 14+
- **TypeScript Support:** Full TypeScript support included

### Auto-Linking

React Native 0.60+ supports auto-linking:

- **iOS:** CocoaPods automatically links the native module
- **Android:** Gradle automatically links the native module
- **No manual linking required**

**Verify auto-linking:**

```bash
npx react-native config
```

Look for `@founderos/mobile-tracker-react-native` in the output.

### TypeScript Support

The SDK includes full TypeScript definitions:

```typescript
import MobileTracker, {
  MobileTrackerConfig,
  CommonProfileData,
} from '@founderos/mobile-tracker-react-native'

// Type-safe configuration
const config: MobileTrackerConfig = {
  apiKey: '123',
  x_api_key: 'key',
  debug: true,
}

// Type-safe profile data
const profile: CommonProfileData = {
  email: 'user@example.com',
  name: 'John Doe',
  plan: 'premium',
}
```

### iOS-Specific Notes

**Minimum iOS Version:** 13.0

**CocoaPods:**

- Automatically installed via `pod install`
- No manual configuration needed

**Permissions:**

For location tracking (optional), add to `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to provide better analytics</string>
```

**App Tracking Transparency (iOS 14.5+):**

```typescript
import { Platform } from 'react-native';
import { requestTrackingPermission } from 'react-native-tracking-transparency';

if (Platform.OS === 'ios') {
  const status = await requestTrackingPermission();
  if (status === 'authorized') {
    await MobileTracker.init({...});
  }
}
```

### Android-Specific Notes

**Minimum Android Version:** API 21+ (Android 5.0 Lollipop)

**Gradle:**

- Automatically configured via auto-linking
- No manual configuration needed

**Permissions:**

Required permissions (automatically added):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Optional permissions for location tracking:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**ProGuard/R8:**

If using ProGuard or R8, rules are automatically included. No manual configuration needed.

### Expo Support

**Note:** This SDK requires native modules and is **not compatible with Expo Go**. You must use:

- **Expo with Development Builds** (recommended)
- **Bare React Native workflow**

**Using with Expo Development Builds:**

1. Install the SDK:

   ```bash
   npx expo install @founderos/mobile-tracker-react-native
   ```

2. Create a development build:
   ```bash
   npx expo prebuild
   npx expo run:ios
   npx expo run:android
   ```

### Metro Bundler

No special Metro configuration required. The SDK works with default Metro settings.

### Thread Safety

All SDK methods are thread-safe and can be called from any JavaScript thread. The SDK handles native threading internally.

### Storage

The SDK uses native storage on each platform:

- **iOS:** UserDefaults (primary) + File storage (backup)
- **Android:** SharedPreferences (primary) + File storage (backup)

Data persists across app launches and is automatically synced.

### Network Behavior

- **Timeout:** 30 seconds for initialization
- **Retry:** Events are queued and retried if network fails
- **Background:** Events can be sent in background (platform-dependent)

### Hot Reload & Fast Refresh

The SDK is compatible with React Native's Hot Reload and Fast Refresh. However, initialization state is preserved, so you may need to fully reload the app to test initialization logic.

---

## API Quick Reference

### Initialization

| Method   | Parameters                    | Description                                        |
| -------- | ----------------------------- | -------------------------------------------------- |
| `init()` | `config: MobileTrackerConfig` | Initialize the SDK with brand ID and configuration |

### Event Tracking

| Method     | Parameters                                            | Description                                  |
| ---------- | ----------------------------------------------------- | -------------------------------------------- |
| `track()`  | `event: string`<br>`properties?: Record<string, any>` | Track an event with optional properties      |
| `screen()` | `name: string`<br>`properties?: Record<string, any>`  | Track a screen view with optional properties |

### User Identification

| Method       | Parameters                                         | Description                                 |
| ------------ | -------------------------------------------------- | ------------------------------------------- |
| `identify()` | `userId: string`<br>`traits?: Record<string, any>` | Identify a user with ID and optional traits |
| `set()`      | `profileData: CommonProfileData`                   | Update user profile data                    |

### Session Management

| Method          | Parameters                      | Description                            |
| --------------- | ------------------------------- | -------------------------------------- |
| `setMetadata()` | `metadata: Record<string, any>` | Set session-level metadata             |
| `reset()`       | `all?: boolean`                 | Reset tracker state (default: `false`) |

### Configuration

| Property    | Type      | Required | Default        | Description                |
| ----------- | --------- | -------- | -------------- | -------------------------- |
| `apiKey`    | `string`  | Yes      | -              | Brand ID                   |
| `x_api_key` | `string`  | Yes      | -              | API key for authentication |
| `debug`     | `boolean` | No       | `false`        | Enable debug logging       |
| `endpoint`  | `string`  | No       | Production URL | Custom API endpoint        |

### Common Event Names

| Event                | Description        | Example Properties                 |
| -------------------- | ------------------ | ---------------------------------- |
| `VIEW_PAGE`          | Screen/page view   | `url`, `screen_name`               |
| `BUTTON_CLICK`       | Button interaction | `button_name`, `screen`            |
| `PURCHASE_COMPLETED` | Purchase event     | `product_id`, `amount`, `currency` |
| `USER_LOGGED_IN`     | Login event        | `method` (email, social, etc.)     |
| `USER_SIGNED_UP`     | Registration event | `method`, `plan`                   |
| `FORM_SUBMITTED`     | Form submission    | `form_name`, `fields_count`        |
| `VIDEO_PLAYED`       | Video playback     | `video_id`, `duration`             |
| `ERROR_OCCURRED`     | Error tracking     | `error_code`, `error_message`      |

---

## Next Steps

### Explore Full API Documentation

For detailed API documentation, see [API_REFERENCE.md](../API_REFERENCE.md)

### Check Out Examples

See complete working examples:

- [React Native Example App](../examples/react-native/README.md)
- [Example Code](../examples/react-native/App.tsx)

### Advanced Topics

- **Custom Event Schemas:** Define your own event structure
- **Event Validation:** Validate events before sending
- **Offline Support:** Handle offline scenarios
- **Performance Optimization:** Tips for high-volume tracking
- **Testing:** How to test tracking in your app
- **Navigation Integration:** Deep integration with React Navigation

### Get Help

- **Documentation:** [https://founder-os.ai/docs](https://founder-os.ai/docs)
- **Dashboard:** [https://founder-os.ai/dashboard](https://founder-os.ai/dashboard)
- **Support:** contact@founder-os.ai
- **GitHub:** [https://github.com/Eastplayers/genie-tracking-mobile](https://github.com/Eastplayers/genie-tracking-mobile)

---

## Summary

You've successfully integrated the FounderOS Mobile Tracking SDK! Here's what you accomplished:

✅ Installed the SDK via npm or yarn  
✅ Configured platform-specific setup for iOS and Android  
✅ Initialized the tracker with your configuration  
✅ Tracked custom events with properties  
✅ Identified users and updated profiles  
✅ Set session-level metadata  
✅ Tracked screen views  
✅ Handled logout with session reset  
✅ Verified tracking is working

**Your app is now tracking events and user behavior!** 🎉

Check your FounderOS dashboard to see events flowing in and start analyzing user behavior.
