# Package Name Update for founder-os.ai

## Summary

Updated the Android library package name to incorporate the `founder-os.ai` domain.

## Changes Made

### 1. Maven Coordinates

- **Old GroupId**: `com.mobiletracker`
- **New GroupId**: `ai.founderos`
- **ArtifactId**: `mobile-tracking-sdk` (unchanged)
- **Version**: `0.1.0` (unchanged)

### 2. Package Structure

- **Old Package**: `com.mobiletracker`
- **New Package**: `ai.founderos.mobiletracker`

### 3. Files Updated

#### Configuration Files

- `android/gradle.properties` - Updated GROUP property
- `android/build.gradle` - Updated namespace

#### Source Files

All Kotlin source files moved from:

- `android/src/main/java/com/mobiletracker/`

To:

- `android/src/main/java/ai/founderos/mobiletracker/`

#### Test Files

All test files moved from:

- `android/src/test/java/com/mobiletracker/`

To:

- `android/src/test/java/ai/founderos/mobiletracker/`

#### Example Project

- `examples/android/build.gradle` - Updated namespace and applicationId
- `examples/android/src/main/java/` - Moved MainActivity to new package structure

### 4. Package Declarations

All package declarations and imports updated from:

```kotlin
package com.mobiletracker
import com.mobiletracker.*
```

To:

```kotlin
package ai.founderos.mobiletracker
import ai.founderos.mobiletracker.*
```

## Maven Dependency

Consumers will now use:

```gradle
dependencies {
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
}
```

## JitPack URL

For JitPack publishing, the library will be available at:

```
https://jitpack.io/#ai.founderos/mobile-tracking-sdk
```

## Verification

✅ Build successful: `./gradlew assembleRelease`
✅ POM generation successful with correct groupId
✅ Example project builds successfully
✅ Publishing tasks available and functional

## Notes

- The reverse domain notation for `founder-os.ai` is `ai.founderos`
- All existing functionality remains unchanged
- Only package names and Maven coordinates have been updated
