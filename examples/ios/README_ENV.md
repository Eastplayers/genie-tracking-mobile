# Environment Configuration for iOS Example

This guide explains how to configure environment variables for the iOS example app.

## Setup

### Option 1: Using Xcode Scheme (Recommended for Development)

1. Copy the example environment file:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your actual values

3. In Xcode, edit your scheme:
   - Product → Scheme → Edit Scheme...
   - Select "Run" on the left
   - Go to "Arguments" tab
   - Under "Environment Variables", add:
     - `BRAND_ID` = your brand ID
     - `API_URL` = your API URL
     - `X_API_KEY` = your API key (optional)
     - `DEBUG` = true

### Option 2: Using Info.plist (For Production Builds)

1. Open `Info.plist` in Xcode

2. Add new entries:

   ```xml
   <key>BRAND_ID</key>
   <string>$(BRAND_ID)</string>
   <key>API_URL</key>
   <string>$(API_URL)</string>
   <key>X_API_KEY</key>
   <string>$(X_API_KEY)</string>
   ```

3. In your Xcode project settings:
   - Select your target
   - Go to "Build Settings"
   - Add User-Defined Settings:
     - `BRAND_ID` = your brand ID
     - `API_URL` = your API URL
     - `X_API_KEY` = your API key

### Option 3: Using xcconfig Files (Best for Teams)

1. Create `Config.xcconfig`:

   ```
   BRAND_ID = your_brand_id
   API_URL = https:/​/api.your-platform.com
   X_API_KEY = your_api_key
   ```

2. Add to `.gitignore`:

   ```
   Config.xcconfig
   ```

3. In Xcode project settings:
   - Select your project
   - Go to "Info" tab
   - Under "Configurations", set Config.xcconfig for Debug/Release

## Usage in Code

The `Config.swift` helper automatically loads values:

```swift
import FounderOSMobileTracker

// Initialize with environment configuration
Task {
    do {
        // Validate configuration first
        try Config.validate()

        // Create tracker config
        let config = TrackerConfig(
            debug: Config.debug,
            apiUrl: Config.apiUrl,
            xApiKey: Config.xApiKey
        )

        // Initialize tracker
        try await MobileTracker.shared.initialize(
            brandId: Config.brandId,
            config: config
        )

        print("✅ Tracker initialized successfully")
    } catch {
        print("❌ Configuration error: \(error)")
    }
}
```

## Security Notes

- ⚠️ Never commit `.env` or `Config.xcconfig` files
- ⚠️ Never hardcode credentials in source code
- ✅ Use different values for development and production
- ✅ Rotate API keys regularly

## Troubleshooting

**Issue**: Configuration values are empty

- Check that environment variables are set in your Xcode scheme
- Verify Info.plist entries are correct
- Make sure `.env` file exists and has values

**Issue**: "Configuration Error: BRAND_ID is required"

- Set BRAND_ID in your Xcode scheme or Info.plist
- Check that the value is not empty

**Issue**: Values work in Xcode but not in release builds

- Use Info.plist or xcconfig for release builds
- Environment variables from Xcode schemes only work in development
