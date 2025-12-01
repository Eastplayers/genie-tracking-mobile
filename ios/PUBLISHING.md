# iOS Library Publishing Guide

This guide covers how to publish the FounderOSMobileTracker iOS library to CocoaPods and other distribution channels.

## Table of Contents

- [CocoaPods Publishing](#cocoapods-publishing)
- [Swift Package Manager](#swift-package-manager)
- [Local Development](#local-development)
- [Version Management](#version-management)
- [Monorepo Structure](#monorepo-structure)
- [Troubleshooting](#troubleshooting)

---

## CocoaPods Publishing

CocoaPods is the **recommended** distribution method for FounderOSMobileTracker because it supports both React Native and native iOS projects.

### Prerequisites

1. **Install CocoaPods** (if not already installed):

   ```bash
   sudo gem install cocoapods
   ```

2. **Register with CocoaPods Trunk** (one-time setup):

   ```bash
   pod trunk register your.email@example.com 'Your Name'
   ```

   - Check your email and click the confirmation link
   - Verify registration: `pod trunk me`
   - You should see your name and email

### Publishing Process

#### Step 1: Update Version

Edit `ios/FounderOSMobileTracker.podspec` and update the version:

```ruby
s.version = '0.1.1'  # Increment version
```

#### Step 2: Commit Changes

```bash
git add ios/FounderOSMobileTracker.podspec
git commit -m "Bump version to 0.1.1"
git push origin main
```

#### Step 3: Validate Podspec

Validate the podspec locally before publishing:

```bash
pod spec lint ios/FounderOSMobileTracker.podspec --allow-warnings
```

**Note**: The `--allow-warnings` flag is used because the monorepo structure may generate warnings that don't affect functionality.

#### Step 4: Create Git Tag

CocoaPods requires a Git tag matching the version:

```bash
git tag v0.1.1
git push origin v0.1.1
```

#### Step 5: Publish to CocoaPods Trunk

Use the automated publishing script:

```bash
chmod +x ios/publish-cocoapods.sh
./ios/publish-cocoapods.sh
```

Or manually:

```bash
pod trunk push ios/FounderOSMobileTracker.podspec --allow-warnings
```

#### Step 6: Verify Publication

After publishing (may take a few minutes):

```bash
pod repo update
pod search FounderOSMobileTracker
```

You should see your library listed with the new version.

### Testing Before Publishing

Always test the podspec locally before publishing:

#### Test in React Native Project

1. Navigate to your React Native example project:

   ```bash
   cd examples/react-native/ios
   ```

2. Update the Podfile to use local path:

   ```ruby
   pod 'FounderOSMobileTracker', :path => '../../../ios'
   ```

3. Install and test:
   ```bash
   pod install
   cd ..
   npx react-native run-ios
   ```

#### Test in Native iOS Project

1. Navigate to your native iOS example project:

   ```bash
   cd examples/ios/MobileTrackerExample
   ```

2. Create or update Podfile:

   ```ruby
   platform :ios, '13.0'

   target 'MobileTrackerExample' do
     use_frameworks!
     pod 'FounderOSMobileTracker', :path => '../../../ios'
   end
   ```

3. Install and test:

   ```bash
   pod install
   open MobileTrackerExample.xcworkspace
   ```

4. Build and run in Xcode

---

## Swift Package Manager

Swift Package Manager (SPM) is available as an alternative for **native iOS apps only** (not React Native).

### Publishing Process

SPM uses Git tags for versioning. No registration required!

#### Step 1: Update Package.swift (if needed)

The `ios/Package.swift` file is already configured. Verify it's correct:

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
        .target(name: "MobileTracker", path: "MobileTracker"),
        .testTarget(name: "MobileTrackerTests", dependencies: ["MobileTracker"])
    ]
)
```

#### Step 2: Create and Push Git Tag

```bash
git tag v0.1.1
git push origin v0.1.1
```

That's it! The package is now available via SPM.

### Consumer Usage (SPM)

In Xcode:

1. File → Add Packages...
2. Enter: `https://github.com/Eastplayers/genie-tracking-mobile`
3. Select version: `0.1.1`

Or in Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/Eastplayers/genie-tracking-mobile", from: "0.1.1")
]
```

**Important**: SPM uses the target name from Package.swift:

```swift
import MobileTracker  // Not FounderOSMobileTracker
```

---

## Local Development

For detailed information on local CocoaPods development and testing, see:

📖 **[LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md)** - Complete guide to local development workflow

### Quick Start

Both example projects are already configured for local development:

**React Native**: `examples/react-native/ios/Podfile`

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

**Native iOS**: `examples/ios/MobileTrackerExample/Podfile`

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

### Test Local Integration

Run the automated test script:

```bash
./ios/test-local-integration.sh
```

This will:

- ✅ Validate the podspec
- ✅ Test pod installation in React Native project
- ✅ Test pod installation in native iOS project
- ✅ Verify local path references are working

### Making Changes

1. Edit source files in `ios/MobileTracker/`
2. Rebuild in Xcode (⌘B) or reinstall pods
3. Changes are reflected immediately

For complete documentation, see [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md).

---

## Version Management

### Semantic Versioning

We follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (e.g., 1.0.0 → 2.0.0)
- **MINOR**: New features, backward compatible (e.g., 1.0.0 → 1.1.0)
- **PATCH**: Bug fixes, backward compatible (e.g., 1.0.0 → 1.0.1)

### Version Update Checklist

Before releasing a new version:

- [ ] Update version in `ios/FounderOSMobileTracker.podspec`
- [ ] Update version in documentation (if mentioned)
- [ ] Run all tests: `swift test` (from ios/ directory)
- [ ] Validate podspec: `pod spec lint ios/FounderOSMobileTracker.podspec`
- [ ] Test in React Native example project
- [ ] Test in native iOS example project
- [ ] Commit all changes
- [ ] Create Git tag: `git tag v0.1.x`
- [ ] Push tag: `git push origin v0.1.x`
- [ ] Publish to CocoaPods: `./ios/publish-cocoapods.sh`
- [ ] Verify publication: `pod search FounderOSMobileTracker`
- [ ] Update CHANGELOG.md with release notes

### Version Consistency

Ensure versions match across:

- `ios/FounderOSMobileTracker.podspec` → `s.version`
- Git tags → `v0.1.x` format
- Documentation → Installation instructions

---

## Monorepo Structure

This library is part of a monorepo. Understanding the structure is important for publishing.

### Directory Structure

```
genie-tracking-mobile/
├── ios/                                    # iOS library root
│   ├── FounderOSMobileTracker.podspec     # CocoaPods spec (references ios/ subpath)
│   ├── Package.swift                       # SPM manifest
│   ├── MobileTracker/                      # Source code
│   │   ├── MobileTracker.swift
│   │   ├── Configuration.swift
│   │   └── ...
│   └── Tests/
│       └── MobileTrackerTests/
├── android/                                # Android library
├── react-native/                           # React Native bridge
└── examples/
    ├── ios/                                # Native iOS example
    └── react-native/                       # React Native example
```

### Podspec Configuration for Monorepo

The podspec is configured to work with the monorepo structure:

```ruby
# Source files are relative to the podspec location (ios/)
s.source_files = 'MobileTracker/**/*.{swift,h,m}'

# License file is in the repo root (one level up from ios/)
s.license = { :type => 'MIT', :file => '../LICENSE' }

# Source points to the full repository
s.source = {
  :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git',
  :tag => "v#{s.version}"
}
```

**Important**: The `source_files` path is relative to the podspec location. Since the podspec is in `ios/`, the path `MobileTracker/**/*.{swift,h,m}` correctly points to `ios/MobileTracker/**/*.{swift,h,m}` in the repository.

### Consumer Integration

When consumers install via CocoaPods, they reference the full repository:

```ruby
pod 'FounderOSMobileTracker', '~> 0.1.0'
```

CocoaPods automatically:

1. Clones the full repository
2. Checks out the specified tag
3. Uses only the files specified in `s.source_files`
4. Ignores android/, react-native/, and other directories

---

## Troubleshooting

### Common Issues

#### 1. Podspec Validation Fails

**Error**: `The spec did not pass validation`

**Solutions**:

- Run with verbose output: `pod spec lint ios/FounderOSMobileTracker.podspec --verbose`
- Check that Git tag exists: `git tag -l`
- Verify source files path is correct
- Ensure version in podspec matches Git tag

#### 2. Git Tag Not Found

**Error**: `Unable to find a specification for 'FounderOSMobileTracker' at version 'v0.1.0'`

**Solutions**:

```bash
# Create the tag
git tag v0.1.0

# Push to remote
git push origin v0.1.0

# Verify tag exists
git ls-remote --tags origin
```

#### 3. Not Registered with CocoaPods Trunk

**Error**: `You need to register a session first`

**Solutions**:

```bash
# Register with your email
pod trunk register your.email@example.com 'Your Name'

# Check your email and click confirmation link

# Verify registration
pod trunk me
```

#### 4. Version Already Exists

**Error**: `Unable to accept duplicate entry for: FounderOSMobileTracker (0.1.0)`

**Solutions**:

- CocoaPods versions are immutable
- Increment the version number in podspec
- Create a new Git tag with the new version
- Publish the new version

#### 5. Monorepo Path Issues

**Error**: `Unable to find source files matching: MobileTracker/**/*.{swift,h,m}`

**Solutions**:

- Verify the podspec is in the `ios/` directory
- Check that `s.source_files` path is correct relative to podspec location
- The path should be: `'MobileTracker/**/*.{swift,h,m}'` (relative to ios/ directory, NOT including ios/ prefix)
- When CocoaPods fetches from Git, it uses the full repo but interprets paths relative to the podspec location

#### 6. React Native Pod Install Fails

**Error**: `[!] Unable to find a specification for 'FounderOSMobileTracker'`

**Solutions**:

```bash
# Update CocoaPods repo
pod repo update

# Clear CocoaPods cache
pod cache clean --all

# Remove Podfile.lock and Pods directory
rm -rf Podfile.lock Pods/

# Reinstall
pod install
```

#### 7. Swift Version Mismatch

**Error**: `Module compiled with Swift X.X cannot be imported by Swift Y.Y`

**Solutions**:

- Verify Swift version in podspec: `s.swift_version = '5.5'`
- Check Xcode version supports Swift 5.5+
- Update Xcode if necessary

### Getting Help

If you encounter issues not covered here:

1. **Check CocoaPods Guides**: https://guides.cocoapods.org/
2. **Search CocoaPods Issues**: https://github.com/CocoaPods/CocoaPods/issues
3. **Contact founder-os.ai**: contact@founder-os.ai

---

## Quick Reference

### Publishing Checklist

```bash
# 1. Update version in podspec
vim ios/FounderOSMobileTracker.podspec

# 2. Commit changes
git add ios/FounderOSMobileTracker.podspec
git commit -m "Bump version to 0.1.x"
git push

# 3. Validate locally
pod spec lint ios/FounderOSMobileTracker.podspec --allow-warnings

# 4. Create and push tag
git tag v0.1.x
git push origin v0.1.x

# 5. Publish
./ios/publish-cocoapods.sh
```

### Testing Checklist

```bash
# Test in React Native
cd examples/react-native/ios
pod install
cd ..
npx react-native run-ios

# Test in native iOS
cd examples/ios/MobileTrackerExample
pod install
open MobileTrackerExample.xcworkspace
# Build and run in Xcode
```

### Useful Commands

```bash
# Check CocoaPods registration
pod trunk me

# Search for published pod
pod search FounderOSMobileTracker

# Update local specs repo
pod repo update

# Validate podspec
pod spec lint ios/FounderOSMobileTracker.podspec --verbose

# List Git tags
git tag -l

# Delete local tag
git tag -d v0.1.0

# Delete remote tag
git push origin :refs/tags/v0.1.0
```

---

## Additional Resources

- [CocoaPods Guides](https://guides.cocoapods.org/)
- [CocoaPods Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk.html)
- [Semantic Versioning](https://semver.org/)
- [Swift Package Manager](https://swift.org/package-manager/)
- [founder-os.ai](https://founder-os.ai)
