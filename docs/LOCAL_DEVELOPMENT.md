# Local Development Guide

Complete guide for developing and testing the Mobile Tracking SDK locally across all platforms.

## Table of Contents

- [Overview](#overview)
- [iOS Local Development](#ios-local-development)
- [Android Local Development](#android-local-development)
- [React Native Local Development](#react-native-local-development)
- [Testing Workflow](#testing-workflow)

---

## Overview

Local development allows you to:

- ✅ Test changes immediately without publishing
- ✅ Iterate quickly during development
- ✅ Debug issues in consumer projects
- ✅ Validate integration before release

### Monorepo Structure

```
genie-tracking-mobile/
├── ios/                    # iOS SDK
├── android/                # Android SDK
├── react-native/           # React Native bridge
└── examples/               # Example projects
    ├── ios/                # iOS example
    ├── android/            # Android example
    └── react-native/       # React Native example
```

---

## iOS Local Development

### Using CocoaPods (Recommended)

Reference the local SDK in your Podfile:

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

**From React Native example** (`examples/react-native/ios/Podfile`):

```ruby
target 'YourApp' do
  # Local development
  pod 'FounderOSMobileTracker', :path => '../../../ios'

  # Production (comment out local, uncomment this)
  # pod 'FounderOSMobileTracker', '~> 0.1.0'
end
```

**From native iOS example** (`examples/ios/MobileTrackerExample/Podfile`):

```ruby
platform :ios, '13.0'

target 'MobileTrackerExample' do
  use_frameworks!

  # Local development
  pod 'FounderOSMobileTracker', :path => '../../../ios'
end
```

### Development Workflow

1. **Make changes** to `ios/MobileTracker/*.swift`

2. **Test in React Native**:

   ```bash
   cd examples/react-native/ios
   pod install  # First time only
   cd ..
   npx react-native run-ios
   ```

3. **Test in native iOS**:

   ```bash
   cd examples/ios/MobileTrackerExample
   pod install  # First time only
   open MobileTrackerExample.xcworkspace
   # Build and run in Xcode (⌘R)
   ```

4. **Verify with automated tests**:
   ```bash
   ./ios/test-local-integration.sh
   ```

### Iterating on Changes

After making changes:

**Option A: Rebuild in Xcode**

- Just rebuild (⌘B) - Xcode recompiles changed files
- No need to run `pod install` again

**Option B: Clean reinstall** (if changes aren't reflected):

```bash
cd examples/ios/MobileTrackerExample
rm -rf Pods/ Podfile.lock
pod install
```

### Using Swift Package Manager

For SPM, use local package reference in Xcode:

1. File → Add Packages
2. Click "Add Local..."
3. Select the `ios/` directory

Or edit `Package.swift`:

```swift
dependencies: [
    .package(path: "../../../ios")
]
```

### Verification

Check that local pod is being used:

```bash
cat Podfile.lock | grep -A 3 "EXTERNAL SOURCES"
```

Should show:

```yaml
EXTERNAL SOURCES:
  FounderOSMobileTracker:
    :path: '../../../ios'
```

---

## Android Local Development

### Using Local Maven Repository

Publish to local Maven for testing:

```bash
cd android
./gradlew publishToMavenLocal
```

This publishes to `~/.m2/repository/`.

### Configure Example Project

**Option 1: Use project dependency** (monorepo):

In `examples/android/settings.gradle`:

```gradle
include ':mobiletracker'
project(':mobiletracker').projectDir = new File(rootProject.projectDir, '../../android')
```

In `examples/android/build.gradle`:

```gradle
dependencies {
    implementation project(':mobiletracker')
}
```

**Option 2: Use local Maven**:

In `examples/android/build.gradle`:

```gradle
repositories {
    mavenLocal()  // Add this
    mavenCentral()
}

dependencies {
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
}
```

### Development Workflow

1. **Make changes** to `android/src/main/java/ai/founderos/mobiletracker/*.kt`

2. **Publish to local Maven**:

   ```bash
   cd android
   ./gradlew publishToMavenLocal
   ```

3. **Test in example project**:

   ```bash
   cd examples/android
   ./gradlew clean build
   ./gradlew installDebug
   ```

4. **Or open in Android Studio**:
   ```bash
   cd examples/android
   # Open in Android Studio
   # Build and run
   ```

### Gradle Properties

Control dependency mode in `examples/android/gradle.properties`:

```properties
# Local project mode (development)
USE_LOCAL_SDK=true

# Maven dependency mode (testing published library)
USE_LOCAL_SDK=false
```

Then in `build.gradle`:

```gradle
dependencies {
    if (project.hasProperty('USE_LOCAL_SDK') && USE_LOCAL_SDK == 'true') {
        implementation project(':mobiletracker')
    } else {
        implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
    }
}
```

### Verification

Check that local SDK is being used:

```bash
cd examples/android
./gradlew dependencies | grep mobile-tracking-sdk
```

---

## React Native Local Development

### Setup

The React Native bridge depends on native iOS and Android SDKs.

### Build and Link SDK

1. **Build the SDK**:

   ```bash
   cd react-native
   npm install
   npm run build
   ```

2. **Link locally**:

   ```bash
   npm link
   ```

3. **Link in example project**:
   ```bash
   cd ../examples/react-native
   npm link @mobiletracker/react-native
   ```

### Development Workflow

1. **Make changes** to `react-native/src/*.ts`

2. **Rebuild**:

   ```bash
   cd react-native
   npm run build
   ```

3. **Test on iOS**:

   ```bash
   cd ../examples/react-native
   npm start -- --reset-cache
   # In another terminal:
   npm run ios
   ```

4. **Test on Android**:
   ```bash
   npm run android
   ```

### Native Dependencies

The React Native bridge uses local native SDKs:

**iOS** (`examples/react-native/ios/Podfile`):

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

**Android** (`examples/react-native/android/settings.gradle`):

```gradle
include ':mobiletracker'
project(':mobiletracker').projectDir = new File(rootProject.projectDir, '../../../android')
```

### Iterating on Changes

**TypeScript changes**:

```bash
cd react-native
npm run build
# Reload app: Press R twice (Android) or Cmd+R (iOS)
```

**Native iOS changes**:

```bash
# Make changes to ios/MobileTracker/*.swift
cd examples/react-native/ios
pod install  # If needed
cd ..
npm run ios
```

**Native Android changes**:

```bash
# Make changes to android/src/main/java/...
cd examples/react-native
npm run android
```

### Clearing Caches

If changes aren't reflected:

```bash
# Clear Metro cache
npm start -- --reset-cache

# Clear all caches
rm -rf node_modules
rm -rf ios/Pods ios/Podfile.lock
npm install
cd ios && pod install && cd ..
```

---

## Testing Workflow

### Automated Tests

**iOS**:

```bash
cd ios
swift test
./test-local-integration.sh
```

**Android**:

```bash
cd android
./gradlew test
./gradlew validateVersion
```

**React Native**:

```bash
cd react-native
npm test
npm run test:property  # Property-based tests
```

### Manual Testing

Test in all example projects:

```bash
# iOS native
cd examples/ios/MobileTrackerExample
pod install
open MobileTrackerExample.xcworkspace
# Build and run

# Android native
cd examples/android
./gradlew installDebug
# Or open in Android Studio

# React Native
cd examples/react-native
npm install
npm run ios     # iOS
npm run android # Android
```

### Integration Testing

Run the complete integration test suite:

```bash
# iOS integration tests
./ios/test-local-integration.sh

# Android integration tests
./android/test-jitpack.sh local
```

---

## Troubleshooting

### iOS Issues

**Changes not reflected**:

```bash
# Clean and rebuild
cd examples/ios/MobileTrackerExample
rm -rf Pods/ Podfile.lock
pod install
# In Xcode: Product → Clean Build Folder (⌘⇧K)
```

**Pod not found**:

```bash
# Verify path
ls -la ../../../ios/FounderOSMobileTracker.podspec
# Check Podfile
cat Podfile | grep FounderOS
```

### Android Issues

**Changes not reflected**:

```bash
# Republish to local Maven
cd android
./gradlew clean
./gradlew publishToMavenLocal

# Clean example project
cd ../examples/android
./gradlew clean
./gradlew build
```

**Gradle sync failed**:

```bash
# Clear Gradle cache
rm -rf ~/.gradle/caches/
cd examples/android
./gradlew clean
```

### React Native Issues

**Module not found**:

```bash
# Rebuild and relink
cd react-native
npm run build
npm link

cd ../examples/react-native
npm link @mobiletracker/react-native
```

**Metro bundler issues**:

```bash
# Clear Metro cache
npm start -- --reset-cache

# Or manually
rm -rf $TMPDIR/metro-*
rm -rf $TMPDIR/haste-*
```

**Native module issues**:

```bash
# iOS
cd ios
rm -rf Pods Podfile.lock
pod install

# Android
cd android
./gradlew clean
```

---

## Best Practices

### 1. Use Relative Paths

Always use relative paths in configuration files:

✅ Good:

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

❌ Bad:

```ruby
pod 'FounderOSMobileTracker', :path => '/Users/yourname/projects/...'
```

### 2. Test on All Platforms

Before committing changes, test on:

- iOS native example
- Android native example
- React Native iOS
- React Native Android

### 3. Run Automated Tests

```bash
# Run all tests
cd ios && swift test && cd ..
cd android && ./gradlew test && cd ..
cd react-native && npm test && cd ..
```

### 4. Keep Dependencies Updated

```bash
# Update CocoaPods
pod repo update

# Update npm packages
cd react-native
npm update

# Update Gradle
cd android
./gradlew wrapper --gradle-version=8.0
```

### 5. Document Changes

When making changes:

- Update relevant documentation
- Add comments to complex code
- Update CHANGELOG if exists

---

## Quick Reference

### Start Local Development

```bash
# iOS
cd examples/ios/MobileTrackerExample
pod install
open MobileTrackerExample.xcworkspace

# Android
cd examples/android
./gradlew installDebug

# React Native
cd react-native && npm run build && npm link && cd ..
cd examples/react-native
npm link @mobiletracker/react-native
npm run ios
```

### Rebuild After Changes

```bash
# iOS: Just rebuild in Xcode (⌘B)

# Android
cd android
./gradlew publishToMavenLocal

# React Native
cd react-native
npm run build
# Reload app
```

### Run Tests

```bash
# All platforms
./ios/test-local-integration.sh
cd android && ./gradlew test && cd ..
cd react-native && npm test && cd ..
```

---

## Additional Resources

- [iOS Local Development Details](../ios/LOCAL_DEVELOPMENT.md)
- [iOS Podfile Examples](../ios/PODFILE_EXAMPLES.md)
- [Android Version Management](../android/VERSION_MANAGEMENT.md)
- [React Native Build Guide](../react-native/BUILD_AND_RUN.md)
- [Platform Publishing Guide](PLATFORM_PUBLISHING.md)

## Support

- **Website**: https://founder-os.ai
- **Email**: contact@founder-os.ai
- **Repository**: https://github.com/Eastplayers/genie-tracking-mobile
