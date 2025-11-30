# React Native SDK - Command Reference

Quick reference for building and running the React Native SDK and example app.

## Prerequisites Check

```bash
# Check Node version (need 16+)
node --version

# Check npm
npm --version

# Check React Native CLI
npx react-native --version

# iOS only: Check CocoaPods
pod --version

# Android only: Check Java
java -version

# Android only: Check ANDROID_HOME
echo $ANDROID_HOME
```

---

## Complete Setup (First Time)

### 1. Build the React Native SDK

```bash
cd react-native
npm install
npm run build
npm link
cd ..
```

### 2. Initialize Example Project

```bash
cd examples/react-native

# Option A: Use setup script
chmod +x setup-project.sh
./setup-project.sh

# Option B: Manual
npx react-native init TempProject --version 0.72.0
cp -r TempProject/ios ./
cp -r TempProject/android ./
rm -rf TempProject
npm install
```

### 3. Link SDK to Example

```bash
cd examples/react-native
npm link @mobiletracker/react-native
```

### 4. iOS Setup (macOS only)

```bash
cd examples/react-native/ios
pod install
cd ..
```

---

## Running the App

### iOS

```bash
cd examples/react-native

# Default simulator
npm run ios

# Specific simulator
npm run ios -- --simulator="iPhone 14 Pro"

# List available simulators
xcrun simctl list devices

# Physical device
npm run ios -- --device
```

### Android

```bash
cd examples/react-native

# Start emulator first (or connect device)
# List emulators: emulator -list-avds
# Start emulator: emulator -avd <name>

# Run app
npm run android

# Specific device
adb devices
npm run android -- --deviceId=<device_id>
```

---

## Development Commands

### SDK Development

```bash
cd react-native

# Build TypeScript
npm run build

# Run tests
npm test

# Run property tests
npm run test:property

# Watch mode
npm run test:watch

# Build and watch
npm run build -- --watch
```

### Example App Development

```bash
cd examples/react-native

# Start Metro bundler
npm start

# Clear cache and start
npm start -- --reset-cache

# Run tests
npm test

# Lint code
npm run lint
```

---

## Rebuilding After Changes

### After SDK Changes

```bash
# 1. Rebuild SDK
cd react-native
npm run build

# 2. Restart Metro with cache clear
cd ../examples/react-native
npm start -- --reset-cache

# 3. Reload app
# iOS: Cmd+R in simulator
# Android: R+R or shake device → Reload
```

### Clean Rebuild iOS

```bash
cd examples/react-native

# Clean pods
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..

# Clear Metro cache
npm start -- --reset-cache

# Run
npm run ios
```

### Clean Rebuild Android

```bash
cd examples/react-native

# Clean Gradle
cd android
./gradlew clean
./gradlew cleanBuildCache
cd ..

# Clear Metro cache
npm start -- --reset-cache

# Run
npm run android
```

---

## Debugging Commands

### View Logs

```bash
# iOS logs
react-native log-ios

# Android logs
react-native log-android

# Or use adb for Android
adb logcat | grep -i "MobileTracker"
```

### Check Device/Emulator Status

```bash
# iOS simulators
xcrun simctl list devices

# Android devices
adb devices

# Android emulators
emulator -list-avds
```

### Debug Menu

- **iOS**: Cmd+D in simulator
- **Android**: Cmd+M (Mac) or Ctrl+M (Windows/Linux), or shake device

---

## Troubleshooting Commands

### Metro Bundler Issues

```bash
# Clear all caches
npm start -- --reset-cache

# Or manually
rm -rf $TMPDIR/metro-*
rm -rf $TMPDIR/haste-*
watchman watch-del-all
```

### Module Not Found

```bash
cd examples/react-native

# Reinstall everything
rm -rf node_modules package-lock.json
npm install

# Relink SDK
npm link @mobiletracker/react-native
```

### iOS Build Failures

```bash
cd examples/react-native/ios

# Nuclear option
rm -rf Pods Podfile.lock ~/Library/Developer/Xcode/DerivedData
pod deintegrate
pod install

# Or from Xcode: Product → Clean Build Folder
```

### CocoaPods Permission Error

If you see: `Permission bits for '/Users/xxx/.netrc' should be 0600, but are 644`

```bash
# Fix .netrc permissions (security requirement)
chmod 600 ~/.netrc
```

### CocoaPods Checksum Error

If you see: `Error installing boost - Verification checksum was incorrect`

```bash
# Clear CocoaPods cache
rm -rf ~/Library/Caches/CocoaPods
pod cache clean --all
pod repo update

# Then retry
cd examples/react-native/ios
rm -rf Pods Podfile.lock
pod install
```

### Android Build Failures

```bash
cd examples/react-native/android

# Clean everything
./gradlew clean
./gradlew cleanBuildCache

# Clear Gradle cache
rm -rf ~/.gradle/caches/

# Rebuild
cd ..
npm run android
```

### Native Module Linking Issues

```bash
# Unlink and relink
cd examples/react-native
npm unlink @mobiletracker/react-native

cd ../../react-native
npm unlink
npm link

cd ../examples/react-native
npm link @mobiletracker/react-native
```

---

## Testing Commands

### Run All Tests

```bash
cd react-native
npm test
```

### Run Specific Test File

```bash
npm test -- ApiClient.test.ts
```

### Run Property Tests Only

```bash
npm run test:property
```

### Run with Coverage

```bash
npm test -- --coverage
```

### Watch Mode

```bash
npm run test:watch
```

---

## Build Commands

### Development Build

```bash
cd react-native
npm run build
```

### Production Build (if configured)

```bash
# iOS
cd examples/react-native
npx react-native run-ios --configuration Release

# Android
cd examples/react-native
cd android
./gradlew assembleRelease
```

---

## Quick Reference

| Task          | Command                                          |
| ------------- | ------------------------------------------------ |
| Build SDK     | `cd react-native && npm run build`               |
| Link SDK      | `cd react-native && npm link`                    |
| Setup Example | `cd examples/react-native && ./setup-project.sh` |
| Run iOS       | `cd examples/react-native && npm run ios`        |
| Run Android   | `cd examples/react-native && npm run android`    |
| Start Metro   | `cd examples/react-native && npm start`          |
| Clear Cache   | `npm start -- --reset-cache`                     |
| iOS Logs      | `react-native log-ios`                           |
| Android Logs  | `react-native log-android`                       |
| Run Tests     | `cd react-native && npm test`                    |
| Clean iOS     | `cd ios && rm -rf Pods && pod install`           |
| Clean Android | `cd android && ./gradlew clean`                  |

---

## Common Workflows

### Making a Change to SDK

```bash
# 1. Edit code in react-native/src/
# 2. Rebuild
cd react-native && npm run build

# 3. Restart Metro
cd ../examples/react-native
npm start -- --reset-cache

# 4. Reload app (Cmd+R or R+R)
```

### Testing on Both Platforms

```bash
# Terminal 1: Metro bundler
cd examples/react-native
npm start

# Terminal 2: iOS
npm run ios

# Terminal 3: Android
npm run android
```

### Fresh Start

```bash
# Clean everything
cd examples/react-native
rm -rf node_modules ios/Pods android/build
npm install
cd ios && pod install && cd ..
npm start -- --reset-cache
```

---

## Environment Variables

```bash
# Android SDK location
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Java (if needed)
export JAVA_HOME=$(/usr/libexec/java_home)
```

Add these to your `~/.zshrc` or `~/.bash_profile`.
