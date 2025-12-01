# Environment Configuration for Android Example

This guide explains how to configure environment variables for the Android example app.

## Setup

### Option 1: Using local.env File (Recommended)

1. Copy the example environment file:

   ```bash
   cd examples/android
   cp .env.example local.env
   ```

2. Edit `local.env` with your actual values:

   ```properties
   BRAND_ID=your_brand_id_here
   API_URL=https://api.your-tracking-platform.com
   X_API_KEY=your_api_key_here
   DEBUG=true
   ```

3. The values will be automatically injected into `BuildConfig` during build

4. **Important**: `local.env` is gitignored and will never be committed

### Option 2: Using gradle.properties

1. Edit `gradle.properties` (or create `gradle.properties.local`):

   ```properties
   BRAND_ID=your_brand_id
   API_URL=https://api.your-platform.com
   X_API_KEY=your_api_key
   DEBUG=true
   ```

2. Values will be read from gradle properties during build

### Option 3: Using System Environment Variables

1. Set environment variables in your shell:

   ```bash
   export BRAND_ID=your_brand_id
   export API_URL=https://api.your-platform.com
   export X_API_KEY=your_api_key
   export DEBUG=true
   ```

2. Build the app - values will be read from environment

### Option 4: Using Android Studio Run Configuration

1. In Android Studio, go to Run → Edit Configurations...
2. Select your app configuration
3. Under "Environment variables", add:
   ```
   BRAND_ID=your_brand_id;API_URL=https://api.your-platform.com;X_API_KEY=your_api_key
   ```

## Usage in Code

The `Config` object automatically loads values from `BuildConfig`:

```kotlin
import ai.founderos.mobiletracker.MobileTracker
import ai.founderos.mobiletracker.TrackerConfig
import ai.founderos.mobiletracker.example.Config

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Validate configuration first
        try {
            Config.validate()
        } catch (e: IllegalArgumentException) {
            Log.e("App", "Configuration error: ${e.message}")
            return
        }

        // Initialize tracker with environment configuration
        GlobalScope.launch {
            val config = TrackerConfig(
                debug = Config.debug,
                apiUrl = Config.apiUrl,
                xApiKey = Config.xApiKey
            )

            MobileTracker.getInstance().initialize(
                context = applicationContext,
                brandId = Config.brandId,
                config = config
            )

            Log.d("App", "✅ Tracker initialized successfully")
        }
    }
}
```

## How It Works

1. **Build Time**: Gradle reads values from `local.env`, gradle.properties, or environment variables
2. **Code Generation**: Values are injected into `BuildConfig` class
3. **Runtime**: Your app accesses values via `BuildConfig.BRAND_ID`, etc.
4. **Helper**: The `Config` object provides a clean API to access these values

## Priority Order

Values are loaded in this order (first found wins):

1. `local.env` file (highest priority)
2. System environment variables
3. `gradle.properties` or `gradle.properties.local`
4. Empty string (default)

## Security Notes

- ⚠️ Never commit `local.env` or `gradle.properties.local` files
- ⚠️ Never hardcode credentials in source code
- ✅ Use different values for development and production
- ✅ Rotate API keys regularly
- ✅ Use ProGuard/R8 to obfuscate BuildConfig in release builds

## Troubleshooting

**Issue**: BuildConfig fields are empty

- Check that `local.env` exists and has values
- Verify the file format (KEY=value, no spaces around =)
- Rebuild the project (Build → Rebuild Project)

**Issue**: "BRAND_ID is required" error

- Create `local.env` from `.env.example`
- Fill in actual values
- Sync and rebuild the project

**Issue**: Changes to local.env not reflected

- Clean and rebuild: `./gradlew clean build`
- In Android Studio: Build → Clean Project, then Build → Rebuild Project

**Issue**: Values work locally but not in CI/CD

- Set environment variables in your CI/CD pipeline
- Or use gradle properties in CI configuration
- Never commit `local.env` to version control

## Example local.env File

```properties
# Example configuration - DO NOT COMMIT THIS FILE
BRAND_ID=12345
API_URL=https://api.tracking-platform.com
X_API_KEY=sk_test_abc123xyz789
DEBUG=true
```
