# Examples Guide

Complete guide for running and understanding the example projects.

## Table of Contents

- [Overview](#overview)
- [iOS Example](#ios-example)
- [Android Example](#android-example)
- [React Native Example](#react-native-example)
- [Environment Configuration](#environment-configuration)
- [Common Issues](#common-issues)

---

## Overview

The repository includes three example projects demonstrating SDK usage:

```
examples/
├── ios/                    # Native iOS example (SwiftUI)
├── android/                # Native Android example (Jetpack Compose)
└── react-native/           # React Native example (TypeScript)
```

Each example demonstrates:

- ✅ SDK initialization
- ✅ User identification
- ✅ Event tracking
- ✅ Screen tracking
- ✅ Metadata management
- ✅ Profile updates
- ✅ Session reset

---

## iOS Example

### Quick Start

```bash
cd examples/ios
open MobileTrackerExample/MobileTrackerExample.xcodeproj
```

In Xcode:

1. Wait for package dependencies to resolve (~10 seconds)
2. Select an iPhone simulator (e.g., iPhone 16 Pro)
3. Press `Cmd+R` to build and run

### Project Structure

```
examples/ios/
├── MobileTrackerExample/          # Xcode project
│   ├── MobileTrackerExample/      # Source files
│   │   ├── ExampleApp.swift       # App entry point
│   │   ├── ContentView.swift      # Main UI
│   │   ├── Config.swift           # Configuration
│   │   └── Assets.xcassets/       # App assets
│   └── MobileTrackerExample.xcodeproj/
├── .env.example                   # Environment template
├── README.md                      # iOS example README
└── README_ENV.md                  # Environment setup
```

### Configuration

The example uses environment variables for credentials.

**Setup**:

1. Copy environment template:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your credentials:

   ```bash
   BRAND_ID=your_brand_id
   API_KEY=your_api_key
   API_URL=https://tracking.api.founder-os.ai/api
   ```

3. Load in `Config.swift`:
   ```swift
   struct Config {
       static let brandId = ProcessInfo.processInfo.environment["BRAND_ID"] ?? "925"
       static let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? "demo_key"
       static let apiUrl = ProcessInfo.processInfo.environment["API_URL"] ?? "https://tracking.api.founder-os.ai/api"
   }
   ```

### Features Demonstrated

**Initialization**:

```swift
import FounderOSMobileTracker

let config = TrackerConfig(
    debug: true,
    apiUrl: Config.apiUrl,
    xApiKey: Config.apiKey
)

MobileTracker.shared.initialize(
    brandId: Config.brandId,
    config: config
)
```

**Identify User**:

```swift
MobileTracker.shared.identify(
    userId: "user123",
    profileData: [
        "email": "user@example.com",
        "plan": "premium"
    ]
)
```

**Track Event**:

```swift
MobileTracker.shared.track(
    eventName: "Button Clicked",
    attributes: [
        "buttonName": "signup",
        "screen": "home"
    ]
)
```

**Set Metadata**:

```swift
MobileTracker.shared.setMetadata([
    "app_version": "1.2.3",
    "environment": "production"
])
```

**Update Profile**:

```swift
MobileTracker.shared.set([
    "name": "John Doe",
    "email": "john@example.com"
])
```

**Reset**:

```swift
// Reset session only
MobileTracker.shared.reset(all: false)

// Reset everything including brand ID
MobileTracker.shared.reset(all: true)
```

### Recreate Project

If you need to regenerate the Xcode project:

```bash
cd examples/ios
./create-project.sh
```

### Troubleshooting

**Package resolution issues**:

```
File → Packages → Reset Package Caches
File → Packages → Resolve Package Versions
```

**Build errors**:

```
Product → Clean Build Folder (Cmd+Shift+K)
Product → Build (Cmd+B)
```

**Simulator issues**:

```bash
# List available simulators
xcrun simctl list devices available

# Boot a specific simulator
xcrun simctl boot "iPhone 16 Pro"
```

---

## Android Example

### Quick Start

```bash
cd examples/android
./gradlew installDebug
```

Or open in Android Studio:

```bash
cd examples/android
# Open in Android Studio
# Build and run
```

### Project Structure

```
examples/android/
├── src/main/java/ai/founderos/mobiletracker/example/
│   ├── MainActivity.kt            # Main activity
│   ├── Config.kt                  # Configuration
│   └── ExampleApp.kt              # Application class
├── build.gradle                   # Dependencies
├── .env.example                   # Environment template
├── README.md                      # Android example README
└── README_ENV.md                  # Environment setup
```

### Configuration

**Setup**:

1. Copy environment template:

   ```bash
   cp .env.example local.env
   ```

2. Edit `local.env` with your credentials:

   ```properties
   BRAND_ID=your_brand_id
   API_KEY=your_api_key
   API_URL=https://tracking.api.founder-os.ai/api
   ```

3. Load in `Config.kt`:
   ```kotlin
   object Config {
       val brandId: String
       val apiKey: String
       val apiUrl: String

       init {
           val props = Properties()
           File("local.env").inputStream().use { props.load(it) }

           brandId = props.getProperty("BRAND_ID", "925")
           apiKey = props.getProperty("API_KEY", "demo_key")
           apiUrl = props.getProperty("API_URL", "https://tracking.api.founder-os.ai/api")
       }
   }
   ```

### Features Demonstrated

**Initialization**:

```kotlin
import ai.founderos.mobiletracker.MobileTracker
import ai.founderos.mobiletracker.TrackerConfig

val config = TrackerConfig(
    debug = true,
    apiUrl = Config.apiUrl,
    xApiKey = Config.apiKey
)

MobileTracker.getInstance().initialize(
    context = applicationContext,
    brandId = Config.brandId,
    config = config
)
```

**Identify User**:

```kotlin
MobileTracker.getInstance().identify(
    userId = "user123",
    profileData = mapOf(
        "email" to "user@example.com",
        "plan" to "premium"
    )
)
```

**Track Event**:

```kotlin
MobileTracker.getInstance().track(
    eventName = "Button Clicked",
    attributes = mapOf(
        "buttonName" to "signup",
        "screen" to "home"
    )
)
```

**Set Metadata**:

```kotlin
MobileTracker.getInstance().setMetadata(mapOf(
    "app_version" to "1.2.3",
    "environment" to "production"
))
```

**Update Profile**:

```kotlin
MobileTracker.getInstance().set(mapOf(
    "name" to "John Doe",
    "email" to "john@example.com"
))
```

**Reset**:

```kotlin
// Reset session only
MobileTracker.getInstance().reset(false)

// Reset everything including brand ID
MobileTracker.getInstance().reset(true)
```

### Dependency Modes

The example supports two dependency modes:

**Local Project Mode** (development):

```properties
# In gradle.properties
USE_LOCAL_SDK=true
```

**Maven Dependency Mode** (testing published library):

```properties
# In gradle.properties
USE_LOCAL_SDK=false
```

### Troubleshooting

**Gradle sync failed**:

```bash
cd android
./gradlew clean
./gradlew build
```

**Clear Gradle cache**:

```bash
rm -rf ~/.gradle/caches/
./gradlew clean
```

**Android SDK not found**:

```bash
# Set ANDROID_HOME
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

---

## React Native Example

### Quick Start

**First time setup**:

```bash
cd examples/react-native
chmod +x setup-project.sh
./setup-project.sh
```

**Run on iOS**:

```bash
npm run ios
```

**Run on Android**:

```bash
npm run android
```

### Project Structure

```
examples/react-native/
├── App.tsx                 # Main application component
├── config.ts               # Configuration
├── index.js               # App entry point
├── package.json           # Dependencies
├── .env.example           # Environment template
├── ios/                   # iOS native code
├── android/               # Android native code
├── README.md              # React Native example README
├── QUICKSTART.md          # Quick start guide
├── SETUP.md               # Detailed setup
└── COMMON_ISSUES.md       # Troubleshooting
```

### Configuration

**Setup**:

1. Copy environment template:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your credentials:

   ```bash
   BRAND_ID=your_brand_id
   API_KEY=your_api_key
   API_URL=https://tracking.api.founder-os.ai/api
   ```

3. Load in `config.ts`:

   ```typescript
   import Config from 'react-native-config'

   export default {
     brandId: Config.BRAND_ID || '925',
     apiKey: Config.API_KEY || 'demo_key',
     apiUrl: Config.API_URL || 'https://tracking.api.founder-os.ai/api',
   }
   ```

### Features Demonstrated

**Initialization**:

```typescript
import MobileTracker from '@mobiletracker/react-native'
import config from './config'

await MobileTracker.init({
  apiKey: config.brandId, // Brand ID passed as apiKey
  endpoint: config.apiUrl,
  x_api_key: config.apiKey,
  debug: true,
})
```

**Identify User**:

```typescript
MobileTracker.identify('user123', {
  email: 'user@example.com',
  plan: 'premium',
})
```

**Track Event**:

```typescript
MobileTracker.track('Button Clicked', {
  buttonName: 'signup',
  screen: 'home',
})
```

**Track Screen**:

```typescript
MobileTracker.screen('Home Screen', {
  previousScreen: 'login',
})
```

**Set Metadata**:

```typescript
await MobileTracker.setMetadata({
  app_version: '1.2.3',
  environment: 'production',
})
```

**Update Profile**:

```typescript
await MobileTracker.set({
  name: 'John Doe',
  email: 'john@example.com',
})
```

**Reset**:

```typescript
// Reset session only
MobileTracker.reset(false)

// Reset everything including brand ID
MobileTracker.reset(true)
```

### Setup Native Folders

React Native needs native iOS and Android folders:

```bash
cd examples/react-native
./setup-project.sh
```

This creates the native folders by temporarily initializing a React Native project.

**Manual alternative**:

```bash
# Create temp project
npx react-native init TempProject --version 0.72.0

# Copy native folders
cp -r TempProject/ios ./
cp -r TempProject/android ./

# Clean up
rm -rf TempProject

# Install
npm install
```

### Troubleshooting

**iOS build issues**:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

**Android build issues**:

```bash
cd android
./gradlew clean
cd ..
```

**Metro bundler issues**:

```bash
npm start -- --reset-cache
```

**Module not found**:

```bash
rm -rf node_modules
npm install
```

**CocoaPods permission error**:

```bash
chmod 600 ~/.netrc
```

See [COMMON_ISSUES.md](../examples/react-native/COMMON_ISSUES.md) for more troubleshooting.

---

## Environment Configuration

All examples use environment variables for configuration.

### Why Environment Variables?

- ✅ Keep credentials out of source code
- ✅ Different configs for dev/staging/prod
- ✅ Easy to change without code changes
- ✅ Secure - not committed to git

### Setup Process

1. **Copy template**:

   ```bash
   cp .env.example .env
   ```

2. **Edit with your credentials**:

   ```bash
   BRAND_ID=your_brand_id
   API_KEY=your_api_key
   API_URL=https://tracking.api.founder-os.ai/api
   ```

3. **Load in code** (platform-specific)

### Platform-Specific Loading

**iOS** (using ProcessInfo):

```swift
let brandId = ProcessInfo.processInfo.environment["BRAND_ID"] ?? "default"
```

**Android** (using Properties):

```kotlin
val props = Properties()
File("local.env").inputStream().use { props.load(it) }
val brandId = props.getProperty("BRAND_ID", "default")
```

**React Native** (using react-native-config):

```typescript
import Config from 'react-native-config'
const brandId = Config.BRAND_ID || 'default'
```

### Security

- ✅ `.env` files are in `.gitignore`
- ✅ Only `.env.example` (template) is committed
- ✅ Never commit actual credentials
- ✅ Use different credentials for dev/prod

See [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) for detailed setup guide.

---

## Common Issues

### All Platforms

**Credentials not working**:

- Verify `.env` file exists
- Check file is not named `.env.example`
- Ensure values don't have quotes
- Restart app after changing `.env`

**Network errors**:

- Check API_URL is correct
- Verify API_KEY is valid
- Check internet connection
- Look for firewall/proxy issues

### iOS Specific

**Package resolution fails**:

```
File → Packages → Reset Package Caches
File → Packages → Resolve Package Versions
```

**Build fails**:

```
Product → Clean Build Folder (Cmd+Shift+K)
```

**Simulator not found**:

```bash
xcrun simctl list devices available
```

### Android Specific

**Gradle sync fails**:

```bash
./gradlew clean
./gradlew build
```

**SDK not found**:

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
```

**Emulator not running**:

```bash
emulator -list-avds
emulator -avd <avd_name>
```

### React Native Specific

**Metro bundler issues**:

```bash
npm start -- --reset-cache
```

**Native module errors**:

```bash
# iOS
cd ios && pod install && cd ..

# Android
cd android && ./gradlew clean && cd ..
```

**Module not found**:

```bash
rm -rf node_modules
npm install
```

---

## Quick Reference

### Run All Examples

```bash
# iOS
cd examples/ios
open MobileTrackerExample/MobileTrackerExample.xcodeproj
# Press Cmd+R in Xcode

# Android
cd examples/android
./gradlew installDebug

# React Native iOS
cd examples/react-native
npm run ios

# React Native Android
cd examples/react-native
npm run android
```

### Setup Environment

```bash
# All examples
cd examples/ios && cp .env.example .env && cd ../..
cd examples/android && cp .env.example local.env && cd ../..
cd examples/react-native && cp .env.example .env && cd ../..

# Edit each .env file with your credentials
```

### Clean and Rebuild

```bash
# iOS
cd examples/ios/MobileTrackerExample
rm -rf Pods Podfile.lock
pod install

# Android
cd examples/android
./gradlew clean
./gradlew build

# React Native
cd examples/react-native
rm -rf node_modules ios/Pods
npm install
cd ios && pod install && cd ..
```

---

## Additional Resources

- [Configuration Guide](CONFIGURATION.md)
- [Environment Setup](ENVIRONMENT_SETUP.md)
- [Local Development](LOCAL_DEVELOPMENT.md)
- [API Reference](../API_REFERENCE.md)
- [React Native Build Guide](../react-native/BUILD_AND_RUN.md)

## Support

- **Website**: https://founder-os.ai
- **Email**: contact@founder-os.ai
- **Repository**: https://github.com/Eastplayers/genie-tracking-mobile
