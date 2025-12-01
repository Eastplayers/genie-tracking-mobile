# FounderOS Mobile Tracker - React Native

React Native bridge for the FounderOS Mobile Tracking SDK. Provides event tracking, user identification, and analytics capabilities for React Native applications on iOS and Android.

## 📚 Complete Setup Guide

**👉 [Read the Complete Setup Guide](./SETUP_GUIDE.md)** for step-by-step integration instructions, best practices, troubleshooting, and examples.

The setup guide includes:

- Detailed installation instructions for iOS and Android
- Step-by-step integration walkthrough
- Complete code examples and use cases
- Best practices for performance and privacy
- Troubleshooting common issues
- Platform-specific notes and requirements

## Quick Start

### Installation

```bash
npm install @founderos/mobile-tracker-react-native
# or
yarn add @founderos/mobile-tracker-react-native
```

**iOS:** Run `cd ios && pod install && cd ..`  
**Android:** Auto-linking handles setup automatically

### Basic Usage

```typescript
import MobileTracker from '@founderos/mobile-tracker-react-native'

// Initialize the tracker
await MobileTracker.init({
  apiKey: 'your-brand-id',
  x_api_key: 'your-api-key',
  debug: true,
})

// Track an event
MobileTracker.track('BUTTON_CLICK', {
  button_name: 'signup',
  screen: 'home',
})

// Identify a user
MobileTracker.identify('user123', {
  email: 'user@example.com',
  name: 'John Doe',
})
```

**For complete integration instructions, see [SETUP_GUIDE.md](./SETUP_GUIDE.md)**

## API Reference

### Core Methods

| Method                      | Description          | Example                                                            |
| --------------------------- | -------------------- | ------------------------------------------------------------------ |
| `init(config)`              | Initialize the SDK   | `await MobileTracker.init({ apiKey: '123', x_api_key: 'key' })`    |
| `track(event, properties?)` | Track an event       | `MobileTracker.track('BUTTON_CLICK', { button: 'signup' })`        |
| `identify(userId, traits?)` | Identify a user      | `MobileTracker.identify('user123', { email: 'user@example.com' })` |
| `screen(name, properties?)` | Track screen view    | `MobileTracker.screen('Home', { section: 'main' })`                |
| `set(profileData)`          | Update user profile  | `await MobileTracker.set({ plan: 'premium' })`                     |
| `setMetadata(metadata)`     | Set session metadata | `await MobileTracker.setMetadata({ app_version: '1.0' })`          |
| `reset(all?)`               | Reset tracker state  | `MobileTracker.reset()` or `MobileTracker.reset(true)`             |

### Configuration Options

```typescript
interface MobileTrackerConfig {
  apiKey: string // Required: Your brand ID
  x_api_key: string // Required: API authentication key
  debug?: boolean // Optional: Enable debug logging (default: false)
  endpoint?: string // Optional: Custom API endpoint
}
```

**For detailed API documentation with examples, see [SETUP_GUIDE.md](./SETUP_GUIDE.md)**

## Features

- ✅ **Native Performance** - Uses native iOS (Swift) and Android (Kotlin) SDKs
- ✅ **TypeScript Support** - Full TypeScript definitions included
- ✅ **Auto-Linking** - Works with React Native 0.60+ auto-linking
- ✅ **Automatic Context** - Device info, platform, OS version added automatically
- ✅ **Session Management** - Automatic session creation and persistence
- ✅ **Offline Support** - Events queued and sent when online
- ✅ **Thread-Safe** - All methods are thread-safe

## Platform Support

| Platform     | Minimum Version    | Notes                       |
| ------------ | ------------------ | --------------------------- |
| iOS          | 13.0+              | Swift SDK, CocoaPods or SPM |
| Android      | API 21+ (Lollipop) | Kotlin SDK, auto-linking    |
| React Native | 0.70+              | TypeScript support included |

## Example App

See the [example app](../examples/react-native) for a complete working implementation with all features demonstrated.

## Documentation

- **[Setup Guide](./SETUP_GUIDE.md)** - Complete integration guide with examples
- **[API Reference](../API_REFERENCE.md)** - Full API documentation
- **[Example App](../examples/react-native)** - Working example application

## Related SDKs

- [iOS SDK](../ios) - Native iOS SDK (Swift)
- [Android SDK](../android) - Native Android SDK (Kotlin)

## Support

- **Issues:** [GitHub Issues](https://github.com/Eastplayers/genie-tracking-mobile/issues)
- **Documentation:** [https://founder-os.ai/docs](https://founder-os.ai/docs)
- **Dashboard:** [https://founder-os.ai/dashboard](https://founder-os.ai/dashboard)

## License

MIT
