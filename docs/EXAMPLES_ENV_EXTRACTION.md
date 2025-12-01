# Example Projects - Environment Variable Extraction

## Summary

All hardcoded credentials have been extracted from example projects and moved to environment variables.

## Changes Made

### 1. Android Example (`examples/android/`)

**File Updated:**

- `src/main/java/ai/founderos/mobiletracker/example/MainActivity.kt`

**Before:**

```kotlin
val brandId = "7366"
val apiKey = "03dbd95123137cc76b075f50107d8d2d"
val apiUrl = "https://tracking.api.qc.founder-os.ai/api"

MobileTracker.getInstance().initialize(
    context = applicationContext,
    brandId = brandId,
    config = TrackerConfig(
        debug = true,
        apiUrl = apiUrl,
        xApiKey = apiKey
    )
)
```

**After:**

```kotlin
// Configuration is loaded from local.env file via BuildConfig
Config.validate()

MobileTracker.getInstance().initialize(
    context = applicationContext,
    brandId = Config.brandId,
    config = TrackerConfig(
        debug = Config.debug,
        apiUrl = Config.apiUrl,
        xApiKey = Config.xApiKey
    )
)
```

**Environment File Created:**

- `examples/android/local.env` - Contains actual credentials

### 2. iOS Example (`examples/ios/`)

**Files Updated:**

- `ExampleApp.swift`
- `MobileTrackerExample/MobileTrackerExample/ExampleApp.swift`

**Before:**

```swift
let brandId = "7366"
let apiKey = "03dbd95123137cc76b075f50107d8d2d"
let apiUrl = "https://tracking.api.qc.founder-os.ai/api"

try await MobileTracker.shared.initialize(
    brandId: brandId,
    config: TrackerConfig(
        debug: true,
        apiUrl: apiUrl,
        xApiKey: apiKey
    )
)
```

**After:**

```swift
// Configuration is loaded from environment variables via Config helper
try Config.validate()

try await MobileTracker.shared.initialize(
    brandId: Config.brandId,
    config: TrackerConfig(
        debug: Config.debug,
        apiUrl: Config.apiUrl,
        xApiKey: Config.xApiKey
    )
)
```

**Environment File Created:**

- `examples/ios/.env` - Contains actual credentials

### 3. React Native Example (`examples/react-native/`)

**File Updated:**

- `App.tsx`

**Before:**

```typescript
const brandId = '7366'
const apiKey = '03dbd95123137cc76b075f50107d8d2d'
const apiUrl = 'https://tracking.api.qc.founder-os.ai/api'

await MobileTracker.init({
  apiKey: brandId,
  endpoint: apiUrl,
  debug: true,
  x_api_key: apiKey,
})
```

**After:**

```typescript
// Configuration is loaded from .env file via react-native-config
const brandId = process.env.BRAND_ID || ''
const apiKey = process.env.X_API_KEY || ''
const apiUrl = process.env.API_URL

if (!brandId || !apiKey) {
  throw new Error('BRAND_ID and X_API_KEY are required. Check your .env file.')
}

await MobileTracker.init({
  apiKey: brandId,
  endpoint: apiUrl,
  debug: true,
  x_api_key: apiKey,
})
```

**Environment File Created:**

- `examples/react-native/.env` - Contains actual credentials

## Environment Files Created

All three example projects now have `.env` files with the extracted credentials:

### `examples/android/local.env`

```properties
BRAND_ID=7366
X_API_KEY=03dbd95123137cc76b075f50107d8d2d
API_URL=https://tracking.api.qc.founder-os.ai/api
DEBUG=true
```

### `examples/ios/.env`

```properties
BRAND_ID=7366
X_API_KEY=03dbd95123137cc76b075f50107d8d2d
API_URL=https://tracking.api.qc.founder-os.ai/api
DEBUG=true
```

### `examples/react-native/.env`

```properties
BRAND_ID=7366
X_API_KEY=03dbd95123137cc76b075f50107d8d2d
API_URL=https://tracking.api.qc.founder-os.ai/api
DEBUG=true
```

## Security Notes

⚠️ **IMPORTANT**: These `.env` files contain real credentials and should be treated as sensitive:

1. **DO NOT commit** these files to version control
2. They are already in `.gitignore`
3. Use `.env.example` files as templates for other developers
4. Rotate these credentials if they've been exposed

## How to Use

### Android

```bash
cd examples/android
# Edit local.env with your credentials
./gradlew build
./gradlew installDebug
```

### iOS

```bash
cd examples/ios
# Edit .env with your credentials
# Configure environment variables in Xcode scheme
# Or use Info.plist / xcconfig
open MobileTrackerExample.xcodeproj
```

### React Native

```bash
cd examples/react-native
npm install react-native-config
# Edit .env with your credentials
npm run android  # or npm run ios
```

## Benefits

✅ **No hardcoded credentials** in source code
✅ **Easy to change** credentials without modifying code
✅ **Secure** - .env files are gitignored
✅ **Consistent** across all platforms
✅ **Documented** with clear examples

## Next Steps

1. Review the extracted credentials
2. Rotate credentials if needed
3. Test each example project
4. Update documentation if needed

## Files Modified

- `examples/android/src/main/java/ai/founderos/mobiletracker/example/MainActivity.kt`
- `examples/ios/ExampleApp.swift`
- `examples/ios/MobileTrackerExample/MobileTrackerExample/ExampleApp.swift`
- `examples/react-native/App.tsx`

## Files Created

- `examples/android/local.env`
- `examples/ios/.env`
- `examples/react-native/.env`
- `EXAMPLES_ENV_EXTRACTION.md` (this file)

---

**Status:** ✅ Complete - All hardcoded credentials extracted to environment variables
