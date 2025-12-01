# Mobile Tracking SDK Documentation

Complete documentation for the Mobile Tracking SDK.

## 📚 Documentation Index

### Getting Started

- **[Main README](../README.md)** - Overview, installation, and quick start
- **[Configuration Guide](CONFIGURATION.md)** - Complete configuration reference for all platforms
- **[Examples Guide](EXAMPLES_GUIDE.md)** - Complete guide to running example projects

### Security

- **[Security Policy](../SECURITY.md)** - Security best practices and guidelines
- **[Security Audit Summary](SECURITY_AUDIT_SUMMARY.md)** - Security audit results

### API Reference

- **[API Reference](../API_REFERENCE.md)** - Complete API documentation

### Development

- **[Local Development](LOCAL_DEVELOPMENT.md)** - Developing and testing locally across all platforms
- **[Platform Publishing](PLATFORM_PUBLISHING.md)** - Publishing guide for iOS, Android, and React Native

### Configuration Details

- **[Environment Setup](ENVIRONMENT_SETUP.md)** - Detailed environment variable setup
- **[Default API URL](API_URL_DEFAULT.md)** - Information about the default API endpoint

### Change History

- **[Changes Summary](CHANGES_SUMMARY.md)** - Recent changes and updates
- **[Examples Environment Extraction](EXAMPLES_ENV_EXTRACTION.md)** - How credentials were extracted from examples
- **[Development History](../DEVELOPMENT_HISTORY.md)** - Historical development notes

### Platform-Specific Documentation

#### iOS

- **[iOS Publishing](../ios/PUBLISHING.md)** - CocoaPods and SPM publishing
- **[iOS Local Development](../ios/LOCAL_DEVELOPMENT.md)** - Local CocoaPods development
- **[iOS Podfile Examples](../ios/PODFILE_EXAMPLES.md)** - Podfile configurations
- **[iOS Quick Reference](../ios/QUICK_REFERENCE.md)** - Quick commands and tips

#### Android

- **[Android Publishing](../android/PUBLISHING.md)** - JitPack publishing guide
- **[Android Publishing Guide](../android/PUBLISHING_GUIDE.md)** - Detailed publishing steps
- **[Android Version Management](../android/VERSION_MANAGEMENT.md)** - Semantic versioning guide
- **[Android Quick Reference](../android/QUICK_REFERENCE.md)** - Quick commands and alignment info

#### React Native

- **[React Native Commands](../REACT_NATIVE_COMMANDS.md)** - Command reference
- **[React Native Build Guide](../react-native/BUILD_AND_RUN.md)** - Building and running locally
- **[React Native Android Setup](../react-native/ANDROID_SETUP.md)** - Android-specific setup

## 🚀 Quick Links

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

### Configuration

**Required:**

- `BRAND_ID` - Your brand identifier
- `X_API_KEY` - API key for authentication

**Optional:**

- `API_URL` - Custom API endpoint (defaults to `https://tracking.api.founder-os.ai/api`)

See [Configuration Guide](CONFIGURATION.md) for details.

### Usage Example

```swift
// iOS
let config = TrackerConfig(debug: true, xApiKey: "your_api_key")
try await MobileTracker.shared.initialize(brandId: "your_brand_id", config: config)
```

```kotlin
// Android
val config = TrackerConfig(debug = true, xApiKey = "your_api_key")
MobileTracker.getInstance().initialize(context, "your_brand_id", config)
```

```typescript
// React Native
await MobileTracker.init({ apiKey: 'your_brand_id', x_api_key: 'your_api_key' })
```

## 📖 Documentation by Topic

### Configuration

- [Configuration Guide](CONFIGURATION.md) - **Start here for setup**
- [Environment Setup](ENVIRONMENT_SETUP.md) - Detailed environment variable configuration
- [Default API URL](API_URL_DEFAULT.md) - About the default endpoint

### Security

- [Security Policy](../SECURITY.md) - **Read this before deploying**
- [Security Audit Summary](SECURITY_AUDIT_SUMMARY.md) - Audit results

### Development

- [API Reference](../API_REFERENCE.md) - Complete API documentation
- [Changes Summary](CHANGES_SUMMARY.md) - Recent updates
- [Development History](../DEVELOPMENT_HISTORY.md) - Historical notes

### Examples

- **[Examples Guide](EXAMPLES_GUIDE.md)** - Complete guide to all example projects
- [Examples Environment Extraction](EXAMPLES_ENV_EXTRACTION.md) - How example projects are configured
- [iOS Example](../examples/ios/README.md) - Native iOS example
- [Android Example](../examples/android/README.md) - Native Android example
- [React Native Example](../examples/react-native/README.md) - React Native example
- [React Native Quickstart](../examples/react-native/QUICKSTART.md) - Quick start guide
- [React Native Common Issues](../examples/react-native/COMMON_ISSUES.md) - Troubleshooting

## 🔍 Find What You Need

### I want to...

**...install the SDK**
→ See [Main README - Installation](../README.md#installation)

**...configure environment variables**
→ See [Configuration Guide](CONFIGURATION.md)

**...understand security best practices**
→ See [Security Policy](../SECURITY.md)

**...use the API**
→ See [API Reference](../API_REFERENCE.md)

**...run the example projects**
→ See [Examples Guide](EXAMPLES_GUIDE.md)

**...develop and test locally**
→ See [Local Development](LOCAL_DEVELOPMENT.md)

**...publish to CocoaPods/JitPack/npm**
→ See [Platform Publishing](PLATFORM_PUBLISHING.md)

**...use a custom API endpoint**
→ See [Default API URL](API_URL_DEFAULT.md)

**...troubleshoot configuration issues**
→ See [Configuration Guide - Troubleshooting](CONFIGURATION.md#troubleshooting)

## 📁 Documentation Structure

```
docs/
├── README.md                          # This file - documentation index
├── CONFIGURATION.md                   # Complete configuration guide
├── EXAMPLES_GUIDE.md                  # Complete examples guide
├── LOCAL_DEVELOPMENT.md               # Local development guide
├── PLATFORM_PUBLISHING.md             # Publishing guide for all platforms
├── API_URL_DEFAULT.md                 # Default API URL information
├── CHANGES_SUMMARY.md                 # Recent changes
├── ENVIRONMENT_SETUP.md               # Environment variable setup
├── EXAMPLES_ENV_EXTRACTION.md         # Example project configuration
└── SECURITY_AUDIT_SUMMARY.md          # Security audit results

Root level:
├── README.md                          # Main project README
├── SECURITY.md                        # Security policy
├── API_REFERENCE.md                   # API documentation
├── DEVELOPMENT_HISTORY.md             # Development notes
└── REACT_NATIVE_COMMANDS.md           # React Native commands

Platform-specific:
├── ios/                               # iOS documentation
│   ├── PUBLISHING.md                  # iOS publishing guide
│   ├── LOCAL_DEVELOPMENT.md           # iOS local development
│   ├── PODFILE_EXAMPLES.md            # Podfile examples
│   └── QUICK_REFERENCE.md             # iOS quick reference
├── android/                           # Android documentation
│   ├── PUBLISHING.md                  # Android publishing
│   ├── PUBLISHING_GUIDE.md            # Detailed publishing
│   ├── VERSION_MANAGEMENT.md          # Version management
│   └── QUICK_REFERENCE.md             # Android quick reference
└── react-native/                      # React Native documentation
    ├── BUILD_AND_RUN.md               # Build and run guide
    └── ANDROID_SETUP.md               # Android setup
```

## 🆘 Support

- **Configuration Issues:** See [Configuration Guide - Troubleshooting](CONFIGURATION.md#troubleshooting)
- **Security Concerns:** Email security@founder-os.ai
- **General Support:** Email support@founder-os.ai
- **Bug Reports:** Open an issue on GitHub

## 📝 Contributing

When adding documentation:

1. Place platform-specific docs in respective folders (`ios/`, `android/`, `react-native/`)
2. Place general docs in `docs/`
3. Update this index
4. Keep docs concise and actionable

## 🔄 Recent Updates

See [Changes Summary](CHANGES_SUMMARY.md) for the latest updates including:

- Default API URL implementation
- Environment variable configuration
- Security improvements
- Example project updates

---

**Last Updated:** December 2024
