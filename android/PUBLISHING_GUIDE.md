# Android Library Publishing Guide

Complete guide for publishing the Mobile Tracking SDK Android library.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Version Management](#version-management)
3. [Publishing Methods](#publishing-methods)
4. [Testing Published Library](#testing-published-library)
5. [Package Information](#package-information)
6. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Change Version

Edit `android/gradle.properties`:

```properties
VERSION_NAME=0.2.0
```

### Validate Version

```bash
cd android
./gradlew validateVersion
```

### Publish Locally

```bash
./gradlew publishToMavenLocal
```

### Test with Example App

```bash
cd ../examples/android
# Edit gradle.properties: USE_LOCAL_SDK=false
./gradlew clean assembleDebug
```

---

## Version Management

### Version Format

All versions follow [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

**Examples:**

- `1.0.0` - Standard release
- `1.0.0-alpha` - Alpha pre-release
- `1.0.0-beta.1` - Beta with iteration
- `1.0.0+build.123` - With build metadata

### When to Increment

**MAJOR** - Breaking changes:

- Removing public APIs
- Changing method signatures
- Changing minimum SDK requirements

**MINOR** - New features (backward compatible):

- Adding new public APIs
- Adding optional parameters
- Deprecating (not removing) functionality

**PATCH** - Bug fixes (backward compatible):

- Fixing crashes
- Fixing incorrect behavior
- Internal refactoring

### Version Update Workflow

1. **Determine version increment** (MAJOR/MINOR/PATCH)
2. **Update** `android/gradle.properties`:
   ```properties
   VERSION_NAME=0.2.0
   ```
3. **Validate**:
   ```bash
   ./gradlew validateVersion
   ```
4. **Test locally**:
   ```bash
   ./gradlew publishToMavenLocal
   ```
5. **Commit**:
   ```bash
   git add android/gradle.properties
   git commit -m "Bump version to 0.2.0"
   ```
6. **Create tag**:
   ```bash
   git tag -a v0.2.0 -m "Release version 0.2.0"
   git push origin v0.2.0
   ```

For detailed versioning guidelines, see [VERSION_MANAGEMENT.md](./VERSION_MANAGEMENT.md).

---

## Publishing Methods

### 1. Local Maven (Testing)

**Use for:** Testing before public release

**Steps:**

```bash
cd android
./gradlew publishToMavenLocal
```

**Artifacts location:** `~/.m2/repository/ai/founderos/mobile-tracking-sdk/`

**Consumer usage:**

```gradle
repositories {
    mavenLocal()
}

dependencies {
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
}
```

### 2. JitPack (Quick Public Release)

**Use for:** Fast GitHub-based publishing

**Steps:**

1. Ensure version is set in `gradle.properties`
2. Commit and push to GitHub
3. Create and push tag:
   ```bash
   git tag -a v0.1.0 -m "Release 0.1.0"
   git push origin v0.1.0
   ```
4. JitPack builds automatically

**Consumer usage:**

```gradle
repositories {
    maven { url 'https://jitpack.io' }
}

dependencies {
    implementation 'com.github.founderos:mobile-tracking-sdk:0.1.0'
}
```

**Advantages:**

- No account setup
- Automatic builds from tags
- Fast (< 5 minutes)
- Free for public repos

### 3. Maven Central (Professional)

**Use for:** Production releases

**Prerequisites:**

1. Sonatype OSSRH account
2. GPG keys for signing
3. Verified groupId

**Steps:**

1. Configure credentials in `gradle.properties`:

   ```properties
   SONATYPE_USERNAME=your-username
   SONATYPE_PASSWORD=your-password
   signing.keyId=your-key-id
   signing.password=your-key-password
   signing.secretKeyRingFile=/path/to/secring.gpg
   ```

2. Publish:
   ```bash
   ./gradlew publishReleasePublicationToSonatypeRepository
   ./gradlew closeAndReleaseRepository
   ```

**Consumer usage:**

```gradle
dependencies {
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
}
```

**Advantages:**

- Industry standard
- Better discoverability
- Professional credibility

---

## Testing Published Library

### Example App Dependency Modes

The `examples/android` project supports two modes:

#### Local Project Mode (Development)

```properties
# examples/android/gradle.properties
USE_LOCAL_SDK=true
```

- Uses `implementation project(':android')`
- Changes reflected immediately
- No republishing needed

#### Maven Dependency Mode (Testing)

```properties
# examples/android/gradle.properties
USE_LOCAL_SDK=false
```

- Uses `implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'`
- Tests published artifact
- Requires publishing first

### Testing Workflow

1. **Publish to local Maven:**

   ```bash
   cd android
   ./gradlew publishToMavenLocal
   ```

2. **Switch example to Maven mode:**

   ```bash
   cd ../examples/android
   # Edit gradle.properties: USE_LOCAL_SDK=false
   ```

3. **Build and test:**

   ```bash
   ./gradlew clean assembleDebug
   ./gradlew installDebug
   ```

4. **Verify:**
   - Run the app
   - Test all SDK features
   - Check for ClassNotFoundException

### Verification Checklist

- [ ] Build succeeds without errors
- [ ] AAR contains all expected classes
- [ ] POM contains correct dependencies
- [ ] Sources JAR included
- [ ] Javadoc JAR included
- [ ] Example app can import SDK
- [ ] All SDK methods work correctly
- [ ] No runtime errors

---

## Package Information

### Maven Coordinates

```
Group ID:    ai.founderos
Artifact ID: mobile-tracking-sdk
Version:     0.1.0
```

### Package Structure

```
ai.founderos.mobiletracker
├── MobileTracker
├── ApiClient
├── Configuration
├── StorageManager
├── models/
│   ├── DeviceInfo
│   ├── Event
│   ├── EventContext
│   ├── LocationData
│   ├── TrackerConfig
│   └── UpdateProfileData
└── ...
```

### Published Artifacts

- `mobile-tracking-sdk-0.1.0.aar` - Compiled library
- `mobile-tracking-sdk-0.1.0.pom` - Dependency metadata
- `mobile-tracking-sdk-0.1.0-sources.jar` - Source code
- `mobile-tracking-sdk-0.1.0-javadoc.jar` - Documentation

---

## Troubleshooting

### Version Validation Errors

**Error:** "VERSION_NAME is not defined"

**Solution:** Add to `android/gradle.properties`:

```properties
VERSION_NAME=0.1.0
```

**Error:** "does not follow semantic versioning format"

**Solution:** Use format `MAJOR.MINOR.PATCH`:

```properties
VERSION_NAME=1.0.0  # Not: 1.0 or v1.0.0
```

### Publishing Errors

**Error:** "Could not find ai.founderos:mobile-tracking-sdk:0.1.0"

**Solution:** Publish to local Maven first:

```bash
cd android
./gradlew publishToMavenLocal
```

**Error:** "Project with path ':android' could not be found"

**Solution:** Check `USE_LOCAL_SDK` setting in `examples/android/gradle.properties`

### Build Errors

**Error:** "Duplicate class found"

**Solution:** Clean and rebuild:

```bash
./gradlew clean
./gradlew --refresh-dependencies
./gradlew assembleDebug
```

**Error:** "Failed to resolve dependency"

**Solution:** Verify repository configuration:

```gradle
repositories {
    mavenLocal()  // For local testing
    maven { url 'https://jitpack.io' }  // For JitPack
    mavenCentral()  // For Maven Central
}
```

---

## Quick Reference

### Common Commands

```bash
# Validate version
./gradlew validateVersion

# Publish to local Maven
./gradlew publishToMavenLocal

# Clean build
./gradlew clean

# Build release AAR
./gradlew assembleRelease

# Run tests
./gradlew test

# Check dependencies
./gradlew dependencies
```

### File Locations

- Version: `android/gradle.properties`
- Build config: `android/build.gradle`
- Published artifacts: `~/.m2/repository/ai/founderos/mobile-tracking-sdk/`
- Example app config: `examples/android/gradle.properties`

### Important Links

- [Semantic Versioning](https://semver.org/)
- [JitPack](https://jitpack.io/)
- [Maven Central](https://central.sonatype.org/)
- [Gradle Publishing Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)

---

## Release Checklist

Before releasing a new version:

- [ ] Update VERSION_NAME in gradle.properties
- [ ] Run `./gradlew validateVersion`
- [ ] Run all tests: `./gradlew test`
- [ ] Test locally: `./gradlew publishToMavenLocal`
- [ ] Test with example app (Maven mode)
- [ ] Update CHANGELOG.md
- [ ] Commit version change
- [ ] Create and push Git tag
- [ ] Verify JitPack build (if using)
- [ ] Update README with new version
- [ ] Announce release (if significant)

---

For more detailed information:

- Version management: [VERSION_MANAGEMENT.md](./VERSION_MANAGEMENT.md)
- Quick reference: [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
