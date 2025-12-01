# Environment Variable Setup Guide

This guide explains how to configure environment variables across all example projects in this repository.

## Overview

Each example project (iOS, Android, React Native) needs configuration values like:

- `BRAND_ID` - Your brand identifier
- `API_URL` - The tracking API endpoint
- `X_API_KEY` - Optional API key for authentication
- `DEBUG` - Enable debug logging

**Important**: These values should NEVER be hardcoded or committed to version control.

## Quick Start by Platform

### iOS Example

```bash
cd examples/ios
cp .env.example .env
# Edit .env with your values
```

Then configure in Xcode (see [examples/ios/README_ENV.md](examples/ios/README_ENV.md))

### Android Example

```bash
cd examples/android
cp .env.example local.env
# Edit local.env with your values
./gradlew build
```

Values are automatically injected into BuildConfig (see [examples/android/README_ENV.md](examples/android/README_ENV.md))

### React Native Example

```bash
cd examples/react-native
npm install react-native-config
cp .env.example .env
# Edit .env with your values
npm run android  # or npm run ios
```

See [examples/react-native/README_ENV.md](examples/react-native/README_ENV.md) for detailed setup.

## Configuration Files

Each example project has:

1. **`.env.example`** - Template file (safe to commit)

   - Shows what variables are needed
   - Contains placeholder values
   - Copy this to create your local config

2. **`.env` or `local.env`** - Your actual config (NEVER commit)

   - Contains your real values
   - Automatically gitignored
   - Used during development

3. **`README_ENV.md`** - Platform-specific guide
   - Detailed setup instructions
   - Multiple configuration options
   - Troubleshooting tips

## File Locations

```
examples/
├── ios/
│   ├── .env.example          # Template
│   ├── .env                  # Your config (gitignored)
│   ├── Config.swift          # Helper to load values
│   └── README_ENV.md         # iOS-specific guide
│
├── android/
│   ├── .env.example          # Template
│   ├── local.env             # Your config (gitignored)
│   ├── Config.kt             # Helper to load values
│   └── README_ENV.md         # Android-specific guide
│
└── react-native/
    ├── .env.example          # Template
    ├── .env                  # Your config (gitignored)
    ├── config.ts             # Helper to load values
    └── README_ENV.md         # React Native-specific guide
```

## How It Works

### iOS

1. Set environment variables in Xcode scheme or Info.plist
2. `Config.swift` reads from `ProcessInfo.processInfo.environment`
3. Values available at runtime

### Android

1. Gradle reads `local.env` file at build time
2. Values injected into `BuildConfig` class
3. Access via `BuildConfig.BRAND_ID`, etc.

### React Native

1. Use `react-native-config` to load `.env` file
2. Values available via `Config.BRAND_ID`
3. Requires native rebuild when changed

## Security Best Practices

### ✅ DO:

- Copy `.env.example` to `.env` for local development
- Use different values for dev/staging/production
- Rotate API keys regularly
- Use secure configuration management in CI/CD
- Review `.gitignore` to ensure configs are excluded

### ❌ DON'T:

- Commit `.env` or `local.env` files
- Hardcode credentials in source code
- Share credentials in public channels
- Use production keys in development
- Commit `Config.xcconfig` or `config.local.*` files

## Protected Files

These files are automatically gitignored:

```
.env
.env.local
.env.*.local
examples/**/.env
examples/**/local.env
examples/**/config.local.ts
examples/**/config.local.swift
examples/**/Config.xcconfig
android/local.properties
android/gradle.properties.local
```

## Example Configuration

Here's what your `.env` file should look like:

```bash
# Example configuration - DO NOT COMMIT
BRAND_ID=12345
API_URL=https://api.tracking-platform.com
X_API_KEY=sk_test_abc123xyz789
DEBUG=true
```

## CI/CD Configuration

### GitHub Actions

```yaml
env:
  BRAND_ID: ${{ secrets.BRAND_ID }}
  API_URL: ${{ secrets.API_URL }}
  X_API_KEY: ${{ secrets.X_API_KEY }}
```

### GitLab CI

```yaml
variables:
  BRAND_ID: $BRAND_ID
  API_URL: $API_URL
  X_API_KEY: $X_API_KEY
```

### Bitbucket Pipelines

```yaml
pipelines:
  default:
    - step:
        script:
          - export BRAND_ID=$BRAND_ID
          - export API_URL=$API_URL
```

## Troubleshooting

### "Configuration values are empty"

1. Check that `.env` or `local.env` exists
2. Verify file format (KEY=value, no spaces)
3. Rebuild the project completely
4. Check platform-specific README for details

### "Changes not reflected"

- **iOS**: Edit Xcode scheme, rebuild app
- **Android**: Clean and rebuild (`./gradlew clean build`)
- **React Native**: Stop Metro, rebuild native code

### "Works locally but not in CI"

- Set environment variables in CI/CD configuration
- Don't rely on local `.env` files in CI
- Use secrets management in your CI platform

## Getting Help

- **iOS**: See [examples/ios/README_ENV.md](examples/ios/README_ENV.md)
- **Android**: See [examples/android/README_ENV.md](examples/android/README_ENV.md)
- **React Native**: See [examples/react-native/README_ENV.md](examples/react-native/README_ENV.md)
- **Security**: See [SECURITY.md](SECURITY.md)

## Summary

1. **Copy** `.env.example` to `.env` (or `local.env` for Android)
2. **Edit** with your actual values
3. **Never commit** the file with real values
4. **Rebuild** the app to apply changes
5. **Refer** to platform-specific guides for details

---

**Remember**: Environment variables are your first line of defense against credential leaks. Always use them instead of hardcoding sensitive data!
