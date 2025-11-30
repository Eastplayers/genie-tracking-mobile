# Common Issues & Quick Fixes

## CocoaPods Permission Error ✅ FIXED

**Error:**

```
[!] Couldn't determine repo type for URL: `https://cdn.cocoapods.org/`:
Permission bits for '/Users/xxx/.netrc' should be 0600, but are 644
```

**Fix:**

```bash
chmod 600 ~/.netrc
```

**Why:** CocoaPods requires your `.netrc` file to have strict permissions (readable only by you) for security reasons.

---

## iOS Folder Not Found

**Error:**

```
cd ios
cd: no such file or directory: ios
```

**Fix:**

```bash
cd examples/react-native
chmod +x setup-project.sh
./setup-project.sh
```

**Why:** React Native needs native iOS/Android folders which aren't in the repo.

---

## Module Not Found: @mobiletracker/react-native

**Error:**

```
Unable to resolve module @mobiletracker/react-native
```

**Fix:**

```bash
# 1. Build the SDK
cd react-native
npm run build
npm link

# 2. Link in example
cd ../examples/react-native
npm link @mobiletracker/react-native
```

**Why:** The local SDK needs to be built and linked before the example can use it.

---

## Metro Bundler Cache Issues

**Error:**

```
Error: Unable to resolve module...
TransformError: ...
```

**Fix:**

```bash
# Clear Metro cache
npm start -- --reset-cache

# Or manually
rm -rf $TMPDIR/metro-*
rm -rf $TMPDIR/haste-*
watchman watch-del-all
```

---

## iOS Pod Install Fails

**Error:**

```
[!] Unable to find a specification for...
```

**Fix:**

```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
```

---

## CocoaPods Checksum Error (Boost)

**Error:**

```
[!] Error installing boost
Verification checksum was incorrect, expected xxx, got yyy
```

**Fix:**

```bash
# Clear CocoaPods cache
rm -rf ~/Library/Caches/CocoaPods
pod cache clean --all
pod repo update

# Then try again
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

**Why:** The CDN has a corrupted or outdated cached version of the boost library.

---

## Android Build Fails

**Error:**

```
FAILURE: Build failed with an exception
```

**Fix:**

```bash
cd android
./gradlew clean
./gradlew cleanBuildCache
cd ..

# If still fails, clear Gradle cache
rm -rf ~/.gradle/caches/
```

---

## React Native CLI Not Found

**Error:**

```
command not found: react-native
```

**Fix:**

```bash
# Use npx instead
npx react-native run-ios
npx react-native run-android

# Or install globally
npm install -g react-native-cli
```

---

## No Android Emulator Running

**Error:**

```
error Failed to launch emulator. Reason: No emulators found
```

**Fix:**

```bash
# List available emulators
emulator -list-avds

# Start an emulator
emulator -avd <emulator_name>

# Or start from Android Studio
# Tools → AVD Manager → Click Play button
```

---

## iOS Simulator Not Found

**Error:**

```
error Could not find iPhone simulator
```

**Fix:**

```bash
# List available simulators
xcrun simctl list devices

# Run on specific simulator
npm run ios -- --simulator="iPhone 14 Pro"

# Or open Simulator app first
open -a Simulator
```

---

## Port 8081 Already in Use

**Error:**

```
error: listen EADDRINUSE: address already in use :::8081
```

**Fix:**

```bash
# Kill process on port 8081
lsof -ti:8081 | xargs kill -9

# Or use different port
npm start -- --port 8082
```

---

## Xcode Build Fails

**Error:**

```
error: Build input file cannot be found
```

**Fix:**

```bash
# Clean everything
cd ios
rm -rf Pods Podfile.lock ~/Library/Developer/Xcode/DerivedData
pod deintegrate
pod install
cd ..

# Or in Xcode: Product → Clean Build Folder (Cmd+Shift+K)
```

---

## TypeScript Errors

**Error:**

```
error TS2307: Cannot find module '@mobiletracker/react-native'
```

**Fix:**

```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Relink SDK
npm link @mobiletracker/react-native

# Restart TypeScript server in your IDE
```

---

## Android SDK Not Found

**Error:**

```
error Failed to install the app. Make sure you have the Android development environment set up
```

**Fix:**

```bash
# Set ANDROID_HOME environment variable
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Add to ~/.zshrc or ~/.bash_profile to make permanent
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
```

---

## CocoaPods Not Installed

**Error:**

```
command not found: pod
```

**Fix:**

```bash
# Install CocoaPods
sudo gem install cocoapods

# Or using Homebrew
brew install cocoapods
```

---

## Java Version Issues (Android)

**Error:**

```
Unsupported class file major version
```

**Fix:**

```bash
# Check Java version (need JDK 11+)
java -version

# Set JAVA_HOME
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# Or install correct version
brew install openjdk@11
```

---

## Quick Reset (Nuclear Option)

When nothing else works:

```bash
# Clean everything
cd examples/react-native
rm -rf node_modules package-lock.json
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/build android/app/build

# Reinstall
npm install
cd ios && pod install && cd ..

# Clear Metro cache
npm start -- --reset-cache
```

---

## Still Having Issues?

1. Check the detailed guides:

   - `SETUP.md` - Setup instructions
   - `../../react-native/BUILD_AND_RUN.md` - Build guide
   - `../../REACT_NATIVE_COMMANDS.md` - Command reference

2. Check React Native documentation:

   - https://reactnative.dev/docs/environment-setup

3. Check logs:
   - iOS: `react-native log-ios`
   - Android: `react-native log-android`
