# Quick Reference - iOS Library Publishing

Quick commands and configurations for common tasks.

## Local Development

### Test Local Changes

```bash
# Run integration tests
./ios/test-local-integration.sh

# Test in React Native
cd examples/react-native/ios
pod install
cd ..
npx react-native run-ios

# Test in native iOS
cd examples/ios/MobileTrackerExample
pod install
open MobileTrackerExample.xcworkspace
```

### Podfile Configuration

**Local development** (use this while developing):

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

**Published version** (use this in production):

```ruby
pod 'FounderOSMobileTracker', '~> 0.1.0'
```

## Publishing

### CocoaPods Publishing

```bash
# 1. Update version
vim ios/FounderOSMobileTracker.podspec  # Change s.version

# 2. Validate
pod spec lint ios/FounderOSMobileTracker.podspec --allow-warnings

# 3. Commit and tag
git add ios/FounderOSMobileTracker.podspec
git commit -m "Bump version to 0.1.x"
git push
git tag v0.1.x
git push origin v0.1.x

# 4. Publish
./ios/publish-cocoapods.sh
```

### Swift Package Manager

```bash
# Just create and push a tag
git tag v0.1.x
git push origin v0.1.x
```

## Verification

### Check Pod Installation

```bash
# Verify local pod is being used
cat Podfile.lock | grep -A 3 "EXTERNAL SOURCES"

# Should show:
# EXTERNAL SOURCES:
#   FounderOSMobileTracker:
#     :path: "../../../ios"
```

### Check Published Pod

```bash
# Update local specs
pod repo update

# Search for pod
pod search FounderOSMobileTracker

# Check specific version
pod spec cat FounderOSMobileTracker/0.1.0
```

## Troubleshooting

### Changes Not Reflected

```bash
# Clean and reinstall
rm -rf Pods/ Podfile.lock
pod install

# In Xcode: Product → Clean Build Folder (⌘⇧K)
```

### Pod Not Found

```bash
# Verify path is correct
ls -la ../../../ios/FounderOSMobileTracker.podspec

# Check Podfile syntax
cat Podfile | grep FounderOS
```

### Build Errors

```bash
# Validate podspec
pod spec lint ios/FounderOSMobileTracker.podspec --verbose

# Check Swift version
swift --version  # Should be 5.5+

# Run library tests
cd ios
swift test
```

## File Locations

```
ios/
├── FounderOSMobileTracker.podspec    # CocoaPods spec
├── Package.swift                      # SPM manifest
├── PUBLISHING.md                      # Full publishing guide
├── LOCAL_DEVELOPMENT.md               # Local development guide
├── QUICK_REFERENCE.md                 # This file
├── publish-cocoapods.sh               # Publishing script
├── test-local-integration.sh          # Test script
└── MobileTracker/                     # Source code
    ├── MobileTracker.swift
    ├── Configuration.swift
    └── ...

examples/
├── ios/MobileTrackerExample/          # Native iOS example
│   └── Podfile                        # Uses :path => '../../../ios'
└── react-native/ios/                  # React Native example
    └── Podfile                        # Uses :path => '../../../ios'
```

## Version Management

### Semantic Versioning

- **MAJOR**: Breaking changes (1.0.0 → 2.0.0)
- **MINOR**: New features (1.0.0 → 1.1.0)
- **PATCH**: Bug fixes (1.0.0 → 1.0.1)

### Files to Update

When bumping version:

- [ ] `ios/FounderOSMobileTracker.podspec` → `s.version`
- [ ] Git tag → `v0.1.x`
- [ ] CHANGELOG.md (if exists)

## Import Statements

### CocoaPods

```swift
import FounderOSMobileTracker
```

### Swift Package Manager

```swift
import MobileTracker  // Note: Different from CocoaPods!
```

## Useful Commands

```bash
# CocoaPods
pod --version                          # Check CocoaPods version
pod trunk me                           # Check registration
pod repo update                        # Update local specs
pod cache clean --all                  # Clear cache

# Git
git tag -l                             # List tags
git tag -d v0.1.0                      # Delete local tag
git push origin :refs/tags/v0.1.0     # Delete remote tag

# Xcode
xcodebuild -version                    # Check Xcode version
xcodebuild -showsdks                   # Show available SDKs
xcrun simctl list devices              # List simulators
```

## Documentation

- **Full Publishing Guide**: [PUBLISHING.md](PUBLISHING.md)
- **Local Development**: [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md)
- **CocoaPods Guides**: https://guides.cocoapods.org/
- **Swift Package Manager**: https://swift.org/package-manager/

## Support

- **founder-os.ai**: https://founder-os.ai
- **Email**: contact@founder-os.ai
- **Repository**: https://github.com/Eastplayers/genie-tracking-mobile
