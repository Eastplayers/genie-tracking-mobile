# Project Structure

## Monorepo Organization

This is a monorepo containing iOS, Android, and React Native implementations in a single repository.

```
mobile-tracking-sdk/
├── ios/                    # iOS native SDK
├── android/                # Android native SDK
├── react-native/           # React Native bridge
├── examples/               # Example applications
├── docs/                   # Documentation
└── .kiro/                  # Kiro configuration
```

## Platform Directories

### iOS (`ios/`)

```
ios/
├── MobileTracker/              # Source code
│   ├── MobileTracker.swift     # Main SDK class
│   ├── ApiClient.swift         # HTTP client
│   ├── Configuration.swift     # Config models
│   ├── EventQueue.swift        # Event queueing
│   ├── HTTPClient.swift        # Network layer
│   ├── LocationManager.swift   # Location tracking
│   ├── StorageManager.swift    # Dual storage
│   ├── UserContext.swift       # User state
│   └── Models/                 # Data models
├── Tests/
│   ├── MobileTrackerTests/          # Unit tests (XCTest)
│   └── MobileTrackerPropertyTests/  # Property-based tests
├── FounderOSMobileTracker.podspec   # CocoaPods spec
├── Package.swift                    # SPM manifest
└── *.md                             # Platform docs
```

### Android (`android/`)

```
android/
├── src/
│   ├── main/java/ai/founderos/mobiletracker/
│   │   ├── MobileTracker.kt        # Main SDK class
│   │   ├── ApiClient.kt            # HTTP client
│   │   ├── Configuration.kt        # Config models
│   │   ├── EventQueue.kt           # Event queueing
│   │   ├── HTTPClient.kt           # Network layer
│   │   ├── LocationManager.kt      # Location tracking
│   │   ├── StorageManager.kt       # Dual storage
│   │   ├── UserContext.kt          # User state
│   │   └── models/                 # Data models
│   ├── test/java/                  # Unit tests (JUnit)
│   └── propertyTest/java/          # Property-based tests
├── build.gradle                    # Build configuration
├── gradle.properties               # Version & config
└── *.md                            # Platform docs
```

### React Native (`react-native/`)

```
react-native/
├── src/
│   └── index.ts                # TypeScript API
├── ios/
│   ├── MobileTrackerBridge.h   # Objective-C header
│   └── MobileTrackerBridge.m   # iOS bridge implementation
├── android/
│   └── src/main/java/          # Android bridge implementation
├── __tests__/
│   ├── unit/                   # Unit tests
│   └── properties/             # Property-based tests
├── lib/                        # Compiled output
├── package.json
├── tsconfig.json
└── MobileTrackerBridge.podspec # CocoaPods spec for bridge
```

## Examples Directory

```
examples/
├── ios/                        # Native iOS example app
│   └── MobileTrackerExample/
├── android/                    # Native Android example app
│   └── src/main/java/
└── react-native/               # React Native example app
    ├── App.tsx
    ├── ios/
    └── android/
```

Each example includes:

- `.env.example` - Environment configuration template
- `README.md` - Setup instructions
- `README_ENV.md` - Environment variable documentation

## Documentation Directory

```
docs/
├── README.md                           # Documentation index
├── CONFIGURATION.md                    # Configuration guide
├── EXAMPLES_GUIDE.md                   # Running examples
├── LOCAL_DEVELOPMENT.md                # Local dev guide
├── PLATFORM_PUBLISHING.md              # Publishing guide
└── ENVIRONMENT_SETUP.md                # Environment setup
```

## Root Files

- `README.md` - Main project documentation
- `API_REFERENCE.md` - Complete API documentation
- `SECURITY.md` - Security best practices
- `LICENSE` - MIT License
- `package.json` - Root package configuration
- `jitpack.yml` - JitPack build configuration
- `.gitignore` - Git ignore rules
- `setup-git-hooks.sh` - Git hooks setup script

## Code Organization Patterns

### Native SDKs (iOS & Android)

Both follow the same structure mirroring the web implementation:

1. **Main SDK Class** (`MobileTracker.swift` / `MobileTracker.kt`)

   - Singleton pattern
   - Public API methods: `initialize()`, `track()`, `identify()`, `set()`, `setMetadata()`, `reset()`
   - Event queueing and flushing
   - Initialization state management

2. **ApiClient** - Backend communication

   - Session creation
   - Event tracking
   - Profile updates
   - Metadata management

3. **StorageManager** - Dual storage implementation

   - Primary storage (UserDefaults/SharedPreferences)
   - Backup storage (file-based)
   - Key prefix: `__GT_{brandId}_`

4. **Models** - Data structures
   - Configuration
   - Events
   - User profiles
   - Device info

### React Native Bridge

Thin wrapper pattern:

- TypeScript API in `src/index.ts`
- Native bridges delegate to platform SDKs
- No business logic in bridge layer

## Naming Conventions

### iOS

- Swift naming: PascalCase for types, camelCase for methods/properties
- Files match class names: `MobileTracker.swift`
- Test files: `*Tests.swift`

### Android

- Kotlin naming: PascalCase for classes, camelCase for methods/properties
- Package: `ai.founderos.mobiletracker`
- Files match class names: `MobileTracker.kt`
- Test files: `*Test.kt`

### React Native

- TypeScript: PascalCase for interfaces, camelCase for functions
- Files: kebab-case or camelCase
- Test files: `*.test.ts`

## Configuration Files

### iOS

- `FounderOSMobileTracker.podspec` - CocoaPods specification
- `Package.swift` - Swift Package Manager manifest
- `.swiftpm/` - SPM build artifacts (gitignored)

### Android

- `build.gradle` - Build configuration with Maven publishing
- `gradle.properties` - Version and artifact configuration
- `settings.gradle` - Project settings
- `local.properties` - Local SDK paths (gitignored)

### React Native

- `package.json` - npm package configuration
- `tsconfig.json` - TypeScript compiler options
- `MobileTrackerBridge.podspec` - Bridge CocoaPods spec

## Web Reference Mapping

Code references the original web implementation:

- Comments include: `// Web Reference: tracker.ts lines X-Y`
- Maintains same method signatures and behavior
- Located in: `examples/originalWebScript/core/tracker.ts`

## Local Development Setup

All examples configured for local development:

- iOS: Uses `:path` in Podfile pointing to `../../../ios`
- Android: Uses `project(':mobiletracker')` in settings.gradle
- React Native: Uses `npm link` for local package

## Build Artifacts (Gitignored)

- `ios/.build/`, `ios/.swiftpm/` - Swift build artifacts
- `android/build/`, `android/.gradle/` - Gradle build artifacts
- `react-native/lib/`, `react-native/node_modules/` - npm artifacts
- `examples/*/build/`, `examples/*/Pods/` - Example build artifacts
