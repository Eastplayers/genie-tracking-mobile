# Configuration Guide

Complete guide for configuring the Mobile Tracking SDK across all platforms.

## Table of Contents

- [Quick Start](#quick-start)
- [Default API URL](#default-api-url)
- [Environment Variables](#environment-variables)
- [Platform-Specific Setup](#platform-specific-setup)
- [Example Projects](#example-projects)

## Quick Start

### Required Configuration

The SDK requires only two values:

1. **BRAND_ID** - Your brand identifier (required)
2. **X_API_KEY** - API key for authentication (required)

### Optional Configuration

- **API_URL** - Custom API endpoint (optional, defaults to `https://tracking.api.founder-os.ai/api`)
- **DEBUG** - Enable debug logging (optional, defaults to `false`)

## Default API URL

The SDK uses a default API URL, so you don't need to configure it unless you're using a custom backend.

**Default:** `https://tracking.api.founder-os.ai/api`

### Usage Examples

**Minimal Configuration (Recommended):**

```swift
// iOS
let config = TrackerConfig(
    debug: true,
    xApiKey: "your_api_key"
)

try await MobileTracker.shared.initialize(
    brandId: "your_brand_id",
    config: config
)
```

```kotlin
// Android
val config = TrackerConfig(
    debug = true,
    xApiKey = "your_api_key"
)

MobileTracker.getInstance().initialize(
    context = applicationContext,
    brandId = "your_brand_id",
    config = config
)
```

```typescript
// React Native
await MobileTracker.init({
  apiKey: 'your_brand_id',
  x_api_key: 'your_api_key',
})
```

**With Custom API URL:**

Only specify if you're using a custom backend:

```swift
// iOS
let config = TrackerConfig(
    debug: true,
    apiUrl: "https://custom-api.example.com",
    xApiKey: "your_api_key"
)
```

## Environment Variables

### Setup by Platform

#### iOS

**Option 1: Xcode Scheme (Development)**

1. In Xcode: Product → Scheme → Edit Scheme...
2. Select "Run" → "Arguments" tab
3. Add environment variables:
   - `BRAND_ID` = your brand ID
   - `X_API_KEY` = your API key
   - `API_URL` = (optional) custom URL
   - `DEBUG` = true

**Option 2: Info.plist (Production)**

Add to your Info.plist:

```xml
<key>BRAND_ID</key>
<string>$(BRAND_ID)</string>
<key>X_API_KEY</key>
<string>$(X_API_KEY)</string>
```

Then set in Build Settings → User-Defined Settings.

**Option 3: xcconfig Files (Teams)**

Create `Config.xcconfig`:

```
BRAND_ID = your_brand_id
X_API_KEY = your_api_key
API_URL = https://custom-api.example.com
```

Add to `.gitignore` and configure in project settings.

#### Android

**Option 1: local.env File (Recommended)**

1. Create `local.env` in your project root:

```properties
BRAND_ID=your_brand_id
X_API_KEY=your_api_key
API_URL=
DEBUG=true
```

2. Values are automatically injected into `BuildConfig` during build

**Option 2: gradle.properties**

Add to `gradle.properties` or `gradle.properties.local`:

```properties
BRAND_ID=your_brand_id
X_API_KEY=your_api_key
```

**Option 3: System Environment Variables**

```bash
export BRAND_ID=your_brand_id
export X_API_KEY=your_api_key
./gradlew build
```

#### React Native

**Option 1: react-native-config (Recommended)**

1. Install:

```bash
npm install react-native-config
cd ios && pod install && cd ..
```

2. Create `.env`:

```
BRAND_ID=your_brand_id
X_API_KEY=your_api_key
API_URL=
DEBUG=true
```

3. Use in code:

```typescript
import Config from 'react-native-config'

await MobileTracker.init({
  apiKey: Config.BRAND_ID,
  x_api_key: Config.X_API_KEY,
  endpoint: Config.API_URL,
})
```

**Option 2: react-native-dotenv**

1. Install:

```bash
npm install react-native-dotenv
```

2. Update `babel.config.js`:

```javascript
module.exports = {
  plugins: [
    [
      'module:react-native-dotenv',
      {
        moduleName: '@env',
        path: '.env',
      },
    ],
  ],
}
```

3. Use in code:

```typescript
import { BRAND_ID, X_API_KEY } from '@env'
```

### Environment File Templates

#### `.env.example`

```bash
# Required
BRAND_ID=your_brand_id_here
X_API_KEY=your_api_key_here

# Optional (leave empty to use default)
API_URL=

# Optional
DEBUG=true
```

Copy this to `.env` and fill in your values.

## Platform-Specific Setup

### iOS Example

See [examples/ios/README_ENV.md](../examples/ios/README_ENV.md) for detailed iOS setup.

### Android Example

See [examples/android/README_ENV.md](../examples/android/README_ENV.md) for detailed Android setup.

### React Native Example

See [examples/react-native/README_ENV.md](../examples/react-native/README_ENV.md) for detailed React Native setup.

## Example Projects

All example projects use environment variables. To run them:

### iOS

```bash
cd examples/ios
cp .env.example .env
# Edit .env with your values
# Configure in Xcode scheme
open MobileTrackerExample.xcodeproj
```

### Android

```bash
cd examples/android
cp .env.example local.env
# Edit local.env with your values
./gradlew installDebug
```

### React Native

```bash
cd examples/react-native
npm install react-native-config
cp .env.example .env
# Edit .env with your values
npm run android  # or npm run ios
```

## Security Best Practices

### DO:

- ✅ Use environment variables for all credentials
- ✅ Keep `.env` files in `.gitignore`
- ✅ Use different values for dev/staging/production
- ✅ Rotate API keys regularly
- ✅ Use `.env.example` as a template (safe to commit)

### DON'T:

- ❌ Hardcode credentials in source code
- ❌ Commit `.env` files to version control
- ❌ Share credentials in public channels
- ❌ Use production keys in development
- ❌ Store credentials in plain text outside of secure systems

## Troubleshooting

### "Configuration values are empty"

**iOS:**

- Check Xcode scheme environment variables
- Verify Info.plist entries
- Ensure `.env` file exists

**Android:**

- Check `local.env` file exists
- Rebuild project: `./gradlew clean build`
- Verify file format (KEY=value, no spaces)

**React Native:**

- Ensure `.env` file exists
- Rebuild native code (not just reload)
- Clear Metro cache: `npm start -- --reset-cache`

### "BRAND_ID is required" error

- Create `.env` from `.env.example`
- Fill in actual values
- Rebuild the project

### Changes not reflected

**iOS:**

- Edit Xcode scheme
- Clean and rebuild

**Android:**

- `./gradlew clean build`

**React Native:**

- Stop Metro bundler
- Rebuild native code: `npm run android` / `npm run ios`

## CI/CD Configuration

### GitHub Actions

```yaml
env:
  BRAND_ID: ${{ secrets.BRAND_ID }}
  X_API_KEY: ${{ secrets.X_API_KEY }}
  API_URL: ${{ secrets.API_URL }}
```

### GitLab CI

```yaml
variables:
  BRAND_ID: $BRAND_ID
  X_API_KEY: $X_API_KEY
  API_URL: $API_URL
```

## Support

For additional help:

- Security: See [SECURITY.md](../SECURITY.md)
- API Reference: See [API_REFERENCE.md](../API_REFERENCE.md)
- Contact: support@founder-os.ai
