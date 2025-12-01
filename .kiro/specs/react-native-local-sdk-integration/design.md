# Design Document: React Native Local SDK Integration

## Overview

This design establishes a dual-mode dependency configuration for the React Native bridge that supports both local development (referencing local Android/iOS SDKs) and production deployment (referencing published artifacts). The solution uses conditional dependency resolution in Gradle for Android and configurable podspec dependencies for iOS, with clear documentation to guide developers through configuration switching.

## Architecture

### Component Structure

```
react-native/
├── android/
│   ├── build.gradle          # Android bridge with conditional dependencies
│   └── src/main/java/        # Bridge implementation
├── ios/
│   ├── MobileTrackerBridge.h/m  # iOS bridge implementation
│   └── README.md             # iOS setup instructions
├── MobileTrackerBridge.podspec  # iOS dependency configuration
├── package.json
└── README.md                 # Main documentation

android/                      # Local Android SDK
ios/                         # Local iOS SDK
```

### Dependency Resolution Strategy

**Android:**

- Use local Maven repository (`mavenLocal()`) for local development
- Developer publishes Android SDK to local Maven using `./gradlew publishToMavenLocal`
- Comment/uncomment repository configuration to switch between mavenLocal and JitPack
- Avoids project dependency issues while maintaining local development workflow

**iOS:**

- Use local path in podspec for development: `s.dependency "FounderOSMobileTracker", :path => "../ios"`
- Switch to version-based dependency for production: `s.dependency "FounderOSMobileTracker", "~> 1.0"`
- Provide clear comments in podspec for switching

## Components and Interfaces

### Android Build Configuration

**File:** `react-native/android/build.gradle`

The build.gradle will include both repository and dependency configurations with clear comments:

```gradle
repositories {
    google()
    mavenCentral()

    // LOCAL DEVELOPMENT: Uncomment for local Maven repository
    mavenLocal()

    // PRODUCTION: Uncomment for JitPack
    // maven { url 'https://jitpack.io' }
}

dependencies {
    // React Native
    implementation 'com.facebook.react:react-native:+'

    // Mobile Tracker Android SDK
    // Use the same artifact ID for both local and production
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'

    // For local development:
    // 1. Publish Android SDK to local Maven: cd ../../android && ./gradlew publishToMavenLocal
    // 2. Ensure mavenLocal() is enabled in repositories above
    // 3. Rebuild this module

    // For production:
    // 1. Comment out mavenLocal() in repositories
    // 2. Uncomment JitPack repository
    // 3. Update artifact to: 'com.github.Eastplayers:genie-tracking-mobile:1.0.0'
}
```

### iOS Podspec Configuration

**File:** `react-native/MobileTrackerBridge.podspec`

The podspec will include conditional dependency configuration:

```ruby
Pod::Spec.new do |s|
  # ... other configuration ...

  s.dependency "React-Core"

  # LOCAL DEVELOPMENT: Use local path
  # Uncomment for local development:
  # s.dependency "FounderOSMobileTracker", :path => "../ios"

  # PRODUCTION: Use published pod
  # Uncomment for production:
  s.dependency "FounderOSMobileTracker", "~> 1.0"
end
```

### Example App Configuration

**Android:** No changes needed to `examples/react-native/android/settings.gradle`

The example app will automatically use the React Native bridge's dependency configuration. When the bridge is configured for local Maven, the example app will also use local Maven.

**iOS:** `examples/react-native/ios/Podfile`

Already correctly configured with local path dependency pointing to `../../../ios`.

## Data Models

No new data models required. This is purely a build configuration change.

## Correctness Properties

_A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees._

This feature involves build system configuration and documentation rather than runtime behavior. All acceptance criteria relate to:

- Build configuration file contents (build.gradle, podspec)
- Build system behavior (Gradle, CocoaPods)
- Documentation quality and completeness
- Development workflow verification

These are validated through manual verification and build testing rather than automated property-based tests. The testing strategy section outlines the manual verification procedures.

## Error Handling

### Build Errors

**Android:**

- If local Maven artifact not found → Clear error message directing to run `./gradlew publishToMavenLocal` in android/ directory
- If both mavenLocal and JitPack repositories are enabled → Gradle will use mavenLocal first (which is acceptable for local development)

**iOS:**

- If local path dependency is enabled but path doesn't exist → CocoaPods will fail with clear path error
- If both local and production dependencies are enabled → CocoaPods will use the last declared dependency

### Configuration Errors

- Documentation will include troubleshooting section for common configuration mistakes
- README will provide validation steps to confirm correct setup

## Testing Strategy

### Manual Verification Tests

Since this is build configuration, testing will be primarily manual:

1. **Local Android Development Test:**

   - Publish Android SDK to local Maven: `cd android && ./gradlew publishToMavenLocal`
   - Configure React Native bridge for mavenLocal
   - Build React Native bridge Android module
   - Build example app
   - Verify native methods are accessible
   - Make a change to Android SDK
   - Republish to local Maven
   - Rebuild and verify change is reflected

2. **Local iOS Development Test:**

   - Configure for local dependencies
   - Run pod install
   - Build example app
   - Verify native methods are accessible
   - Make a change to iOS SDK
   - Rebuild and verify change is reflected

3. **Production Configuration Test:**

   - Switch to production dependencies
   - Build both platforms
   - Verify published artifacts are used
   - Verify functionality remains intact

4. **Configuration Switching Test:**
   - Start with local configuration
   - Build and verify
   - Switch to production configuration
   - Clean and rebuild
   - Verify functionality
   - Switch back to local
   - Verify functionality

### Documentation Validation

- Follow documentation steps on a clean checkout
- Verify all commands work as documented
- Confirm switching instructions are clear and complete

## Implementation Notes

### Android Local Maven Workflow

For local development, developers must:

1. Make changes to the Android SDK in `android/` directory
2. Publish to local Maven: `cd android && ./gradlew publishToMavenLocal`
3. Rebuild the React Native bridge to pick up changes

This approach avoids project dependency issues while maintaining a local development workflow.

### iOS Path Resolution

The iOS podspec uses a relative path (`../ios`) from the React Native bridge directory to the iOS SDK directory. This works because CocoaPods resolves paths relative to the podspec location.

### Gradle Clean Builds

When switching between local and production Android dependencies, developers should:

1. Update repository configuration in `react-native/android/build.gradle`
2. Run `./gradlew clean` to clear cached artifacts
3. Rebuild the module

### CocoaPods Cache

When switching iOS dependencies, developers should:

1. Update the podspec
2. Run `pod install` in the example app
3. Clean build folder in Xcode if needed

## Documentation Structure

### Main README (`react-native/README.md`)

- Overview of the React Native bridge
- Quick start guide
- Dependency configuration section with both modes
- Switching guide
- Troubleshooting

### Android README (`react-native/android/README.md`)

- Android-specific setup
- Local development configuration
- Production configuration
- Common issues

### iOS README (`react-native/ios/README.md`)

- iOS-specific setup
- Local development configuration
- Production configuration
- Common issues
