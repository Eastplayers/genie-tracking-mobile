# React Native SDK - Build and Run Guide

This guide shows you how to build the React Native SDK and run the example project locally on both Android and iOS.

## Prerequisites

### General Requirements

- Node.js 16+ installed
- npm or yarn package manager
- Git

### iOS Requirements

- macOS (required for iOS development)
- Xcode 14+ installed
- CocoaPods installed: `sudo gem install cocoapods`
- iOS Simulator or physical iOS device

### Android Requirements

- Android Studio installed
- Android SDK (API 21+)
- Java Development Kit (JDK) 11 or newer
- Android Emulator or physical Android device
- ANDROID_HOME environment variable set

---

## Part 1: Build the React Native SDK

### Step 1: Navigate to the SDK directory

```bash
cd react-native
```

### Step 2: Install dependencies

```bash
npm install
```

### Step 3: Build the TypeScript code

```bash
npm run build
```

This compiles the TypeScript source files in `src/` to JavaScript in `lib/` directory.

### Step 4: Verify the build

Check that the following files were created:

- `lib/index.js` - Compiled JavaScript
- `lib/index.d.ts` - TypeScript type definitions

---

## Part 2: Link SDK to Example Project Locally

Since we're developing locally, we need to link the SDK to the example project.

### Option A: Using npm link (Recommended for development)

#### Step 1: Create a global link from the SDK

```bash
# From the react-native/ directory
npm link
```

#### Step 2: Link the SDK in the example project

```bash
cd ../examples/react-native
npm link @mobiletracker/react-native
```

### Option B: Using local file path

Edit `examples/react-native/package.json` and add:

```json
{
  "dependencies": {
    "@mobiletracker/react-native": "file:../../react-native",
    "react": "18.2.0",
    "react-native": "0.72.0"
  }
}
```

Then run:

```bash
cd examples/react-native
npm install
```

---

## Part 3: Initialize the Example Project

⚠️ **Important**: The React Native example needs native iOS and Android folders first.

### Step 1: Navigate to example directory

```bash
cd examples/react-native
```

### Step 2: Initialize React Native project structure

**Option A: Use the setup script (Recommended)**

```bash
chmod +x setup-project.sh
./setup-project.sh
```

**Option B: Manual initialization**

```bash
# Create temporary project to get native folders
npx react-native init TempProject --version 0.72.0

# Copy native folders
cp -r TempProject/ios ./
cp -r TempProject/android ./

# Clean up
rm -rf TempProject

# Install dependencies
npm install
```

### Step 3: Verify structure

You should now have:

```
examples/react-native/
├── android/          # ✓ Android native code
├── ios/              # ✓ iOS native code
├── App.tsx
├── package.json
└── ...
```

See `SETUP.md` in this directory for more detailed setup instructions.

---

## Part 4: Run the Example Project

### Running on iOS

#### Step 1: Install iOS dependencies (CocoaPods)

```bash
cd ios
pod install
cd ..
```

#### Step 2: Start Metro bundler (in one terminal)

```bash
npm start
```

#### Step 3: Run on iOS (in another terminal)

```bash
# Run on default simulator
npm run ios

# Or specify a simulator
npm run ios -- --simulator="iPhone 14 Pro"

# Or run on a physical device
npm run ios -- --device
```

#### Alternative: Build from Xcode

```bash
cd ios
open MobileTrackerExample.xcworkspace
```

Then press the "Play" button in Xcode.

---

### Running on Android

#### Step 1: Start an Android emulator

Open Android Studio → AVD Manager → Start an emulator

Or use command line:

```bash
emulator -avd <your_avd_name>
```

#### Step 2: Start Metro bundler (in one terminal)

```bash
npm start
```

#### Step 3: Run on Android (in another terminal)

```bash
# Run on connected device/emulator
npm run android

# Or specify a device
npm run android -- --deviceId=<device_id>
```

#### Alternative: Build from Android Studio

```bash
cd android
```

Open the `android` folder in Android Studio, then click "Run".

---

## Part 5: CLI Commands Reference

### React Native CLI Commands

#### Start Metro Bundler

```bash
npm start
# or
react-native start
```

#### Run on iOS

```bash
# Default simulator
react-native run-ios

# Specific simulator
react-native run-ios --simulator="iPhone 14 Pro"

# Physical device
react-native run-ios --device

# Specific iOS version
react-native run-ios --simulator="iPhone 14 Pro" --udid=<device-udid>
```

#### Run on Android

```bash
# Default device/emulator
react-native run-android

# Specific device
react-native run-android --deviceId=<device_id>

# Specific variant
react-native run-android --variant=release

# List devices
adb devices
```

#### Clean and Rebuild

**iOS:**

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
npm start -- --reset-cache
npm run ios
```

**Android:**

```bash
cd android
./gradlew clean
cd ..
npm start -- --reset-cache
npm run android
```

---

## Part 6: Development Workflow

### Making Changes to the SDK

1. **Edit SDK source code** in `react-native/src/`

2. **Rebuild the SDK:**

   ```bash
   cd react-native
   npm run build
   ```

3. **Restart Metro bundler** in the example project:

   ```bash
   cd examples/react-native
   npm start -- --reset-cache
   ```

4. **Reload the app:**
   - iOS: Press `Cmd + R` in simulator
   - Android: Press `R` twice or shake device and select "Reload"

### Testing Changes

Run tests in the SDK:

```bash
cd react-native
npm test
```

Run property-based tests:

```bash
npm run test:property
```

---

## Part 7: Troubleshooting

### Common Issues

#### Metro Bundler Issues

```bash
# Clear Metro cache
npm start -- --reset-cache

# Or manually clear
rm -rf $TMPDIR/metro-*
rm -rf $TMPDIR/haste-*
```

#### iOS Build Failures

```bash
# Clean CocoaPods
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..

# Clean Xcode build
cd ios
xcodebuild clean
cd ..
```

#### Android Build Failures

```bash
# Clean Gradle
cd android
./gradlew clean
./gradlew cleanBuildCache
cd ..

# Clear Gradle cache
rm -rf ~/.gradle/caches/
```

#### Module Not Found Errors

```bash
# Reinstall dependencies
rm -rf node_modules
npm install

# For iOS
cd ios
pod install
cd ..
```

#### Native Module Linking Issues

```bash
# Unlink and relink
npm unlink @mobiletracker/react-native
cd ../../react-native
npm link
cd ../examples/react-native
npm link @mobiletracker/react-native
```

### Checking Device/Emulator Status

**iOS Simulators:**

```bash
xcrun simctl list devices
```

**Android Devices:**

```bash
adb devices
```

### Viewing Logs

**iOS:**

```bash
# View all logs
react-native log-ios

# Or use Xcode console
```

**Android:**

```bash
# View all logs
react-native log-android

# Or use adb
adb logcat
```

---

## Part 8: Quick Start Script

Create a script to automate the build and run process:

### For iOS (create `run-ios-local.sh`)

```bash
#!/bin/bash
set -e

echo "Building SDK..."
cd react-native
npm run build

echo "Installing example dependencies..."
cd ../examples/react-native
npm install

echo "Installing iOS pods..."
cd ios
pod install
cd ..

echo "Starting Metro bundler..."
npm start &
METRO_PID=$!

sleep 5

echo "Running on iOS..."
npm run ios

# Cleanup
trap "kill $METRO_PID" EXIT
```

### For Android (create `run-android-local.sh`)

```bash
#!/bin/bash
set -e

echo "Building SDK..."
cd react-native
npm run build

echo "Installing example dependencies..."
cd ../examples/react-native
npm install

echo "Starting Metro bundler..."
npm start &
METRO_PID=$!

sleep 5

echo "Running on Android..."
npm run android

# Cleanup
trap "kill $METRO_PID" EXIT
```

Make scripts executable:

```bash
chmod +x run-ios-local.sh run-android-local.sh
```

---

## Summary

**Build SDK:**

```bash
cd react-native && npm install && npm run build
```

**Link locally:**

```bash
npm link
cd ../examples/react-native && npm link @mobiletracker/react-native
```

**Run iOS:**

```bash
cd examples/react-native
npm install
cd ios && pod install && cd ..
npm run ios
```

**Run Android:**

```bash
cd examples/react-native
npm install
npm run android
```

That's it! You now have the React Native SDK built and running locally on both platforms.
