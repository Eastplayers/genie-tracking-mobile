# Quick Start - React Native Example

## TL;DR - Get Running Fast

### First Time Setup

```bash
# 1. Build the SDK
cd react-native
npm install && npm run build && npm link

# 2. Setup the example project
cd ../examples/react-native
chmod +x setup-project.sh
./setup-project.sh

# 3. Link the SDK
npm link @mobiletracker/react-native
```

### Run on iOS

```bash
cd examples/react-native
npm run ios
```

### Run on Android

```bash
cd examples/react-native
npm run android
```

---

## What's Missing?

Your `examples/react-native` folder doesn't have the native iOS and Android folders yet. React Native needs these to run on actual devices/simulators.

## Why?

React Native apps need:

- **JavaScript code** (App.tsx, index.js) ✓ You have this
- **iOS native code** (ios/ folder) ✗ Missing
- **Android native code** (android/ folder) ✗ Missing

## How to Fix?

Run the setup script:

```bash
cd examples/react-native
chmod +x setup-project.sh
./setup-project.sh
```

This creates the native folders by temporarily initializing a React Native project and copying the iOS/Android folders.

## Manual Alternative

If the script doesn't work:

```bash
cd examples/react-native

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

## After Setup

You'll have:

```
examples/react-native/
├── android/          # ✓ Now you have this
├── ios/              # ✓ Now you have this
├── App.tsx
├── index.js
└── package.json
```

Then you can run:

- `npm run ios` - Run on iOS simulator
- `npm run android` - Run on Android emulator

## CocoaPods Issues?

If you get CocoaPods errors (permission or checksum issues):

```bash
chmod +x fix-cocoapods.sh
./fix-cocoapods.sh
```

## Need More Help?

See the detailed guides:

- `COMMON_ISSUES.md` - Troubleshooting common problems
- `SETUP.md` - Detailed setup instructions
- `../../react-native/BUILD_AND_RUN.md` - Complete build and run guide
