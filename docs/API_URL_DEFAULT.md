# Default API URL Configuration

## Summary

The Mobile Tracking SDK now uses a **default API URL** so users only need to provide their Brand ID and API Key. The API URL is optional and defaults to the production endpoint.

## Default Value

```
https://tracking.api.founder-os.ai/api
```

## Required Configuration

Users must provide:

1. **BRAND_ID** - Your brand identifier (required)
2. **X_API_KEY** - API key for authentication (required)

## Optional Configuration

- **API_URL** - Custom API endpoint (optional, uses default if not provided)

## Usage Examples

### Minimal Configuration (Recommended)

**iOS:**

```swift
let config = TrackerConfig(
    debug: true,
    xApiKey: "your_api_key"
)

try await MobileTracker.shared.initialize(
    brandId: "your_brand_id",
    config: config
)
```

**Android:**

```kotlin
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

**React Native:**

```typescript
await MobileTracker.init({
  apiKey: 'your_brand_id',
  config: {
    debug: true,
    xApiKey: 'your_api_key',
  },
})
```

### Custom API URL (Advanced)

Only specify `apiUrl` if you're using a custom backend:

**iOS:**

```swift
let config = TrackerConfig(
    debug: true,
    apiUrl: "https://custom-api.example.com",
    xApiKey: "your_api_key"
)
```

**Android:**

```kotlin
val config = TrackerConfig(
    debug = true,
    apiUrl = "https://custom-api.example.com",
    xApiKey = "your_api_key"
)
```

## Environment Variables

### .env File Example

```bash
# Required
BRAND_ID=your_brand_id_here
X_API_KEY=your_api_key_here

# Optional (leave empty to use default)
API_URL=

# Optional
DEBUG=true
```

### Using Default API URL

To use the default API URL, simply:

- Leave `API_URL` empty in your `.env` file
- Don't set `apiUrl` in your `TrackerConfig`
- Pass `nil` or `null` for `apiUrl`

The SDK will automatically use `https://tracking.api.founder-os.ai/api`

## Implementation Details

### iOS

- **TrackerConfig.swift**: Added `defaultApiUrl` constant and `effectiveApiUrl` computed property
- **ApiClient.swift**: Uses `config.effectiveApiUrl` instead of `config.apiUrl`
- Returns default URL when `apiUrl` is `nil` or empty

### Android

- **TrackerConfig.kt**: Added `DEFAULT_API_URL` constant and `getEffectiveApiUrl()` method
- **ApiClient.kt**: Uses `config.getEffectiveApiUrl()` instead of `config.apiUrl`
- Returns default URL when `apiUrl` is `null` or empty

### React Native

- Inherits behavior from native iOS and Android implementations
- No changes needed to bridge code

## Migration Guide

### For Existing Users

If you're already using the SDK with a custom API URL, **no changes are required**. Your existing configuration will continue to work.

### For New Users

You can now initialize the SDK with just Brand ID and API Key:

**Before (still works):**

```swift
let config = TrackerConfig(
    debug: true,
    apiUrl: "https://tracking.api.founder-os.ai/api",
    xApiKey: "your_api_key"
)
```

**After (simpler):**

```swift
let config = TrackerConfig(
    debug: true,
    xApiKey: "your_api_key"
)
```

## Benefits

1. **Simpler Setup**: Users don't need to know or configure the API URL
2. **Fewer Errors**: Reduces configuration mistakes
3. **Better UX**: Minimal required configuration
4. **Flexibility**: Advanced users can still override with custom URL
5. **Backward Compatible**: Existing code continues to work

## Testing

The default URL is used in all example projects:

- `examples/ios/` - iOS example with default URL
- `examples/android/` - Android example with default URL
- `examples/react-native/` - React Native example with default URL

## Documentation Updates

Updated files:

- `.env.example` - Shows API_URL as optional
- `examples/*/. env.example` - Updated with comments
- `examples/*/Config.*` - Updated validation logic
- `ENVIRONMENT_SETUP.md` - Updated configuration guide
- `README.md` - Updated usage examples

## Support

For questions or issues:

- Check [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) for configuration help
- See [SECURITY.md](SECURITY.md) for security best practices
- Contact: support@founder-os.ai
