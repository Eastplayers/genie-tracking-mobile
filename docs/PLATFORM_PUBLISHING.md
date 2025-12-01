# Platform Publishing Guide

Complete guide for publishing the Mobile Tracking SDK across all platforms.

## Table of Contents

- [iOS Publishing](#ios-publishing)
- [Android Publishing](#android-publishing)
- [React Native Bridge](#react-native-bridge)
- [Version Management](#version-management)
- [Testing Before Publishing](#testing-before-publishing)

---

## iOS Publishing

### CocoaPods Publishing

**Prerequisites:**

- CocoaPods account registered
- Trunk access configured: `pod trunk register email@example.com`
- Valid podspec file

**Quick Publish:**

```bash
./ios/publish-cocoapods.sh
```

**Manual Steps:**

1. Update version in `ios/FounderOSMobileTracker.podspec`:

   ```ruby
   s.version = '0.1.1'
   ```

2. Validate podspec:

   ```bash
   pod spec lint ios/FounderOSMobileTracker.podspec --allow-warnings
   ```

3. Create and push Git tag:

   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```

4. Publish to CocoaPods:
   ```bash
   pod trunk push ios/FounderOSMobileTracker.podspec --allow-warnings
   ```

### Swift Package Manager

SPM uses Git tags automatically - no separate publishing step needed.

**Steps:**

1. Create and push tag:

   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```

2. Users can add via Xcode:
   - File → Add Packages
   - Enter repository URL
   - Select version

**Package.swift Configuration:**

```swift
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MobileTracker",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "MobileTracker", targets: ["MobileTracker"])
    ],
    targets: [
        .target(name: "MobileTracker", path: "MobileTracker")
    ]
)
```

### Local Testing

Test changes locally before publishing:

```bash
# Run integration tests
./ios/test-local-integration.sh

# Test in example projects
cd examples/ios/MobileTrackerExample
pod install
open MobileTrackerExample.xcworkspace
```

See [LOCAL_DEVELOPMENT.md](../ios/LOCAL_DEVELOPMENT.md) for detailed local testing guide.

---

## Android Publishing

### JitPack Publishing

JitPack automatically builds from Git tags - no manual publishing needed.

**Steps:**

1. Update version in `android/gradle.properties`:

   ```properties
   VERSION_NAME=0.1.1
   ```

2. Validate version format:

   ```bash
   cd android
   ./gradlew validateVersion
   ```

3. Commit and tag:

   ```bash
   git add android/gradle.properties
   git commit -m "Bump Android version to 0.1.1"
   git tag v0.1.1
   git push origin v0.1.1
   ```

4. JitPack builds automatically when tag is pushed

5. Verify build on JitPack:
   - Visit: https://jitpack.io/#Eastplayers/genie-tracking-mobile
   - Check build status for v0.1.1

### Testing JitPack Build

```bash
# Test that JitPack can build the library
./android/test-jitpack.sh v0.1.1
```

### Local Testing

Test locally before publishing:

```bash
# Publish to local Maven repository
cd android
./gradlew publishToMavenLocal

# Test in example project
cd ../examples/android
# Update build.gradle to use local Maven
./gradlew build
```

### Version Validation

The build system validates semantic versioning:

```bash
cd android
./gradlew validateVersion
```

Valid formats:

- `1.0.0` - Standard release
- `1.0.0-alpha` - Pre-release
- `1.0.0-beta.1` - Beta with iteration
- `1.0.0-rc.1` - Release candidate

See [VERSION_MANAGEMENT.md](../android/VERSION_MANAGEMENT.md) for detailed versioning guide.

---

## React Native Bridge

The React Native bridge depends on native iOS and Android SDKs.

### Publishing to npm

**Prerequisites:**

- npm account
- Logged in: `npm login`

**Steps:**

1. Update version in `react-native/package.json`:

   ```json
   {
     "version": "0.1.1"
   }
   ```

2. Build TypeScript:

   ```bash
   cd react-native
   npm run build
   ```

3. Test locally:

   ```bash
   npm link
   cd ../examples/react-native
   npm link @mobiletracker/react-native
   ```

4. Publish to npm:
   ```bash
   cd react-native
   npm publish
   ```

### Dependencies

The React Native bridge requires:

- iOS SDK published to CocoaPods
- Android SDK published to JitPack/Maven

Update native dependencies in:

- `react-native/MobileTrackerBridge.podspec` (iOS)
- `react-native/android/build.gradle` (Android)

---

## Version Management

### Semantic Versioning

All platforms follow [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features (backwards compatible)
- **PATCH** (1.0.0 → 1.0.1): Bug fixes (backwards compatible)

### Synchronized Versions

Keep all platforms synchronized:

```bash
# Update all platforms to 0.1.1
vim ios/FounderOSMobileTracker.podspec    # s.version = '0.1.1'
vim android/gradle.properties              # VERSION_NAME=0.1.1
vim react-native/package.json              # "version": "0.1.1"
```

### Version Files

| Platform        | File                                 | Field          |
| --------------- | ------------------------------------ | -------------- |
| iOS (CocoaPods) | `ios/FounderOSMobileTracker.podspec` | `s.version`    |
| iOS (SPM)       | Git tag only                         | `v0.1.1`       |
| Android         | `android/gradle.properties`          | `VERSION_NAME` |
| React Native    | `react-native/package.json`          | `version`      |

---

## Testing Before Publishing

### Pre-Publish Checklist

- [ ] All tests pass
- [ ] Version updated in all platform files
- [ ] CHANGELOG updated (if exists)
- [ ] Local testing completed
- [ ] Example projects work with new version
- [ ] Documentation updated
- [ ] Git tag created

### Platform-Specific Tests

**iOS:**

```bash
cd ios
swift test
./test-local-integration.sh
```

**Android:**

```bash
cd android
./gradlew test
./gradlew validateVersion
./test-jitpack.sh v0.1.1
```

**React Native:**

```bash
cd react-native
npm test
npm run build
```

### Integration Tests

Test in example projects:

```bash
# iOS example
cd examples/ios/MobileTrackerExample
pod install
open MobileTrackerExample.xcworkspace
# Build and run

# Android example
cd examples/android
./gradlew build
./gradlew installDebug

# React Native example
cd examples/react-native
npm install
npm run ios
npm run android
```

---

## Publishing Workflow

### Complete Release Process

1. **Prepare Release**

   ```bash
   # Update versions
   vim ios/FounderOSMobileTracker.podspec
   vim android/gradle.properties
   vim react-native/package.json

   # Run tests
   cd ios && swift test && cd ..
   cd android && ./gradlew test && cd ..
   cd react-native && npm test && cd ..
   ```

2. **Commit Version Changes**

   ```bash
   git add ios/FounderOSMobileTracker.podspec
   git add android/gradle.properties
   git add react-native/package.json
   git commit -m "Bump version to 0.1.1"
   git push
   ```

3. **Create and Push Tag**

   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```

4. **Publish iOS**

   ```bash
   ./ios/publish-cocoapods.sh
   # SPM is automatic via Git tag
   ```

5. **Publish Android**

   ```bash
   # JitPack builds automatically from tag
   # Verify at https://jitpack.io/#Eastplayers/genie-tracking-mobile
   ./android/test-jitpack.sh v0.1.1
   ```

6. **Publish React Native**

   ```bash
   cd react-native
   npm run build
   npm publish
   ```

7. **Verify**
   - Check CocoaPods: `pod search FounderOSMobileTracker`
   - Check JitPack: Visit JitPack.io
   - Check npm: `npm view @mobiletracker/react-native`

---

## Troubleshooting

### iOS Publishing Issues

**Error: "Unable to find a specification"**

```bash
pod repo update
pod trunk push ios/FounderOSMobileTracker.podspec --allow-warnings
```

**Error: "Podspec validation failed"**

```bash
pod spec lint ios/FounderOSMobileTracker.podspec --verbose --allow-warnings
```

### Android Publishing Issues

**Error: "Version format invalid"**

```bash
cd android
./gradlew validateVersion
# Fix VERSION_NAME in gradle.properties
```

**Error: "JitPack build failed"**

- Check build logs at https://jitpack.io
- Verify tag exists: `git tag -l`
- Ensure gradle.properties has correct VERSION_NAME

### React Native Publishing Issues

**Error: "Build failed"**

```bash
cd react-native
rm -rf lib node_modules
npm install
npm run build
```

**Error: "npm publish failed"**

```bash
npm login
npm whoami  # Verify logged in
npm publish
```

---

## Quick Reference

### Publish All Platforms

```bash
# 1. Update versions
VERSION="0.1.1"
sed -i '' "s/s.version = .*/s.version = '$VERSION'/" ios/FounderOSMobileTracker.podspec
sed -i '' "s/VERSION_NAME=.*/VERSION_NAME=$VERSION/" android/gradle.properties
cd react-native && npm version $VERSION --no-git-tag-version && cd ..

# 2. Commit and tag
git add ios/FounderOSMobileTracker.podspec android/gradle.properties react-native/package.json
git commit -m "Bump version to $VERSION"
git push
git tag v$VERSION
git push origin v$VERSION

# 3. Publish
./ios/publish-cocoapods.sh
cd react-native && npm run build && npm publish && cd ..

# 4. Verify
./android/test-jitpack.sh v$VERSION
```

### Check Published Versions

```bash
# iOS (CocoaPods)
pod search FounderOSMobileTracker

# Android (JitPack)
# Visit: https://jitpack.io/#Eastplayers/genie-tracking-mobile

# React Native (npm)
npm view @mobiletracker/react-native
```

---

## Additional Resources

- [iOS Local Development](../ios/LOCAL_DEVELOPMENT.md)
- [iOS Publishing Details](../ios/PUBLISHING.md)
- [Android Version Management](../android/VERSION_MANAGEMENT.md)
- [Android Publishing Guide](../android/PUBLISHING_GUIDE.md)
- [React Native Build Guide](../react-native/BUILD_AND_RUN.md)

## Support

- **Website**: https://founder-os.ai
- **Email**: contact@founder-os.ai
- **Repository**: https://github.com/Eastplayers/genie-tracking-mobile
