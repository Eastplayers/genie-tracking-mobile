# Documentation Guide

Quick guide to finding documentation in this repository.

## 📚 Start Here

- **[Main README](README.md)** - Project overview and quick start
- **[Documentation Index](docs/README.md)** - Complete documentation index

## 🚀 Common Tasks

### I want to run the example projects

→ **[Examples Guide](docs/EXAMPLES_GUIDE.md)**

### I want to develop and test locally

→ **[Local Development Guide](docs/LOCAL_DEVELOPMENT.md)**

### I want to publish to CocoaPods/JitPack/npm

→ **[Platform Publishing Guide](docs/PLATFORM_PUBLISHING.md)**

### I want to configure the SDK

→ **[Configuration Guide](docs/CONFIGURATION.md)**

### I want to understand the API

→ **[API Reference](API_REFERENCE.md)**

### I want to understand security

→ **[Security Policy](SECURITY.md)**

## 📁 Documentation Structure

```
docs/                           # Main documentation folder
├── README.md                   # Documentation index (START HERE)
├── PLATFORM_PUBLISHING.md      # Publishing guide (all platforms)
├── LOCAL_DEVELOPMENT.md        # Local development (all platforms)
├── EXAMPLES_GUIDE.md           # Examples guide (all platforms)
├── CONFIGURATION.md            # Configuration guide
└── ...                         # Other guides

Platform-specific:
├── ios/                        # iOS-specific documentation
│   ├── PUBLISHING.md
│   ├── LOCAL_DEVELOPMENT.md
│   ├── PODFILE_EXAMPLES.md
│   └── QUICK_REFERENCE.md
├── android/                    # Android-specific documentation
│   ├── PUBLISHING.md
│   ├── PUBLISHING_GUIDE.md
│   ├── VERSION_MANAGEMENT.md
│   └── QUICK_REFERENCE.md
└── react-native/               # React Native-specific documentation
    ├── BUILD_AND_RUN.md
    └── ANDROID_SETUP.md

Examples:
└── examples/                   # Example project documentation
    ├── ios/README.md
    ├── android/README.md
    └── react-native/
        ├── README.md
        ├── QUICKSTART.md
        ├── SETUP.md
        └── COMMON_ISSUES.md
```

## 🎯 Documentation by Role

### For Users

1. [Main README](README.md) - Overview
2. [Examples Guide](docs/EXAMPLES_GUIDE.md) - Run examples
3. [Configuration Guide](docs/CONFIGURATION.md) - Configure SDK
4. [API Reference](API_REFERENCE.md) - Use the API

### For Developers

1. [Local Development](docs/LOCAL_DEVELOPMENT.md) - Develop locally
2. [Platform Publishing](docs/PLATFORM_PUBLISHING.md) - Publish releases
3. Platform-specific docs:
   - [iOS Local Development](ios/LOCAL_DEVELOPMENT.md)
   - [Android Version Management](android/VERSION_MANAGEMENT.md)
   - [React Native Build Guide](react-native/BUILD_AND_RUN.md)

### For Contributors

1. [Main README](README.md) - Project overview
2. [Local Development](docs/LOCAL_DEVELOPMENT.md) - Setup development environment
3. [Security Policy](SECURITY.md) - Security guidelines

## 🔍 Quick Reference

### Installation

**iOS (CocoaPods):**

```ruby
pod 'FounderOSMobileTracker', '~> 0.1.0'
```

**Android (JitPack):**

```gradle
implementation 'com.github.founderos:mobile-tracking-sdk:0.1.0'
```

**React Native:**

```bash
npm install @mobiletracker/react-native
```

### Commands

**iOS:**

```bash
# Local development
cd examples/ios
open MobileTrackerExample/MobileTrackerExample.xcodeproj

# Publishing
./ios/publish-cocoapods.sh
```

**Android:**

```bash
# Local development
cd examples/android
./gradlew installDebug

# Publishing (automatic via Git tag)
git tag v0.1.0
git push origin v0.1.0
```

**React Native:**

```bash
# Local development
cd examples/react-native
npm run ios
npm run android

# Publishing
cd react-native
npm publish
```

## 📖 Documentation Updates

### Recent Consolidation

Documentation has been consolidated into three major guides:

1. **[Platform Publishing](docs/PLATFORM_PUBLISHING.md)** - Publishing for all platforms
2. **[Local Development](docs/LOCAL_DEVELOPMENT.md)** - Local development for all platforms
3. **[Examples Guide](docs/EXAMPLES_GUIDE.md)** - Examples for all platforms

Platform-specific documentation is preserved for detailed reference.

See [Documentation Consolidation Summary](docs/DOCUMENTATION_CONSOLIDATION_SUMMARY.md) for details.

## 🆘 Support

- **Documentation Issues**: See [docs/README.md](docs/README.md)
- **Configuration Help**: See [Configuration Guide](docs/CONFIGURATION.md)
- **Security Concerns**: Email security@founder-os.ai
- **General Support**: Email support@founder-os.ai

---

**Quick Links:**
[Main README](README.md) |
[Documentation Index](docs/README.md) |
[Examples](docs/EXAMPLES_GUIDE.md) |
[Local Development](docs/LOCAL_DEVELOPMENT.md) |
[Publishing](docs/PLATFORM_PUBLISHING.md) |
[API Reference](API_REFERENCE.md) |
[Security](SECURITY.md)
