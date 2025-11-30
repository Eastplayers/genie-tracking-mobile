# React Native Example - Setup Guide

The React Native example project needs to be initialized with native iOS and Android folders.

## Option 1: Automatic Setup (Recommended)

Run the setup script:

```bash
cd examples/react-native
chmod +x setup-project.sh
./setup-project.sh
```

This will:

- Initialize React Native project structure
- Create iOS and Android native folders
- Preserve your custom App.tsx and configuration
- Install dependencies
- Link the local SDK

## Option 2: Manual Setup

### Step 1: Initialize React Native Project

From the `examples/react-native` directory:

```bash
# Create a temporary React Native project
npx react-native init TempProject --version 0.72.0

# Copy the native folders
cp -r TempProject/ios ./
cp -r TempProject/android ./

# Clean up
rm -rf TempProject
```

### Step 2: Update iOS Configuration

Edit `ios/Podfile` and add after the `use_react_native!` line:

```ruby
# Add local MobileTracker SDK
pod 'MobileTracker', :path => '../../../ios'
```

### Step 3: Update Android Configuration

Edit `android/settings.gradle` and add:

```gradle
include ':mobiletracker'
project(':mobiletracker').projectDir = new File(rootProject.projectDir, '../../../android')
```

Edit `android/app/build.gradle` and add to dependencies:

```gradle
dependencies {
    implementation project(':mobiletracker')
    // ... other dependencies
}
```

### Step 4: Install Dependencies

```bash
npm install
```

### Step 5: Link Local SDK

```bash
# First, build and link the SDK
cd ../../react-native
npm install
npm run build
npm link

# Then link it in the example
cd ../examples/react-native
npm link @mobiletracker/react-native
```

### Step 6: Install iOS Pods

```bash
cd ios
pod install
cd ..
```

## Option 3: Use React Native CLI Directly

If you want to start completely fresh:

```bash
# Go to examples directory
cd examples

# Remove the existing react-native folder
rm -rf react-native

# Create a new React Native project
npx react-native init MobileTrackerExample --version 0.72.0

# Rename it
mv MobileTrackerExample react-native

# Copy your custom files back
# (App.tsx, package.json modifications, etc.)
```

## Verify Setup

After setup, you should have:

```
examples/react-native/
├── android/          # Android native code
├── ios/              # iOS native code
├── node_modules/     # Dependencies
├── App.tsx           # Your app code
├── index.js          # Entry point
├── package.json      # Dependencies
└── ...
```

## Run the App

### iOS

```bash
npm run ios
```

### Android

```bash
npm run android
```

## Troubleshooting

### "ios folder not found"

- Run the setup script or manually initialize the project

### "Module not found: @mobiletracker/react-native"

- Make sure you've built the SDK: `cd ../../react-native && npm run build`
- Link it: `cd ../../react-native && npm link`
- Link in example: `npm link @mobiletracker/react-native`

### iOS build fails

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### CocoaPods permission error

If you see: `Permission bits for '/Users/xxx/.netrc' should be 0600, but are 644`

```bash
chmod 600 ~/.netrc
```

### Android build fails

```bash
cd android
./gradlew clean
cd ..
```
