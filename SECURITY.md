# Security Policy

## Sensitive Data Handling

This repository is public and contains no sensitive credentials or API keys. All sensitive configuration should be managed through environment variables or local configuration files that are gitignored.

### What Should NEVER Be Committed

- API keys or tokens
- Passwords or credentials
- Private keys or certificates
- Personal access tokens
- OAuth secrets
- Database connection strings with credentials
- Local file paths (like Android SDK paths)
- Any personally identifiable information (PII)

### Protected Files (Already in .gitignore)

- `.env` and `.env.*` files
- `android/local.properties` - Contains local Android SDK path
- `android/gradle.properties.local` - For local publishing credentials
- `ios/local.properties` - For local iOS configuration

### How to Use Sensitive Data

#### For SDK Users (Integration)

When integrating this SDK, pass sensitive data at runtime:

**iOS:**

```swift
let config = TrackerConfig(
    debug: false,
    apiUrl: ProcessInfo.processInfo.environment["API_URL"],
    xApiKey: ProcessInfo.processInfo.environment["X_API_KEY"]
)

try await MobileTracker.shared.initialize(
    brandId: ProcessInfo.processInfo.environment["BRAND_ID"] ?? "",
    config: config
)
```

**Android:**

```kotlin
val config = TrackerConfig(
    debug = false,
    apiUrl = System.getenv("API_URL"),
    xApiKey = System.getenv("X_API_KEY")
)

MobileTracker.getInstance().initialize(
    context = applicationContext,
    brandId = System.getenv("BRAND_ID") ?: "",
    config = config
)
```

#### For Contributors (Development)

1. Copy `.env.example` to `.env`
2. Fill in your local values
3. Never commit `.env` to git

For Android publishing credentials, add them to `android/gradle.properties.local` (gitignored) or use environment variables.

### Reporting Security Issues

If you discover a security vulnerability, please email security@founder-os.ai instead of using the public issue tracker.

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Security Best Practices for SDK Users

1. **Never hardcode credentials** - Always use environment variables or secure configuration management
2. **Rotate API keys regularly** - Implement key rotation policies
3. **Use HTTPS only** - The SDK enforces HTTPS for all API calls
4. **Validate input data** - Sanitize any user data before tracking
5. **Review permissions** - Only request necessary permissions in your app
6. **Keep SDK updated** - Update to the latest version for security patches

## Dependency Security

We regularly audit our dependencies for known vulnerabilities. To check dependencies:

**iOS:**

```bash
cd ios && swift package show-dependencies
```

**Android:**

```bash
cd android && ./gradlew dependencies
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
