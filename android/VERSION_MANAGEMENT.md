# Version Management Guide

## Overview

This document describes the version management system for the Mobile Tracking SDK Android library. The library follows [Semantic Versioning 2.0.0](https://semver.org/) to ensure predictable and meaningful version numbers.

## Version Format

All versions MUST follow the Semantic Versioning format:

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

### Components

- **MAJOR**: Incremented for incompatible API changes
- **MINOR**: Incremented for backwards-compatible functionality additions
- **PATCH**: Incremented for backwards-compatible bug fixes
- **PRERELEASE** (optional): Denotes a pre-release version (e.g., alpha, beta, rc.1)
- **BUILD** (optional): Denotes build metadata (e.g., commit hash, build number)

### Valid Examples

```
1.0.0                    # Standard release
1.0.0-alpha              # Alpha pre-release
1.0.0-beta.1             # Beta pre-release with iteration
1.0.0-rc.2               # Release candidate
1.0.0+20130313144700     # Release with build metadata
1.0.0-beta.1+exp.sha.5114f85  # Pre-release with build metadata
```

### Invalid Examples

```
1.0                      # Missing PATCH version
v1.0.0                   # Should not include 'v' prefix
1.0.0.0                  # Too many version components
1.0.0-SNAPSHOT           # Use lowercase for pre-release identifiers
```

## Configuration

The version is configured in `android/gradle.properties`:

```properties
VERSION_NAME=0.1.0
GROUP=ai.founderos
ARTIFACT_ID=mobile-tracking-sdk
```

## Version Validation

The build system automatically validates the version format before publishing. To manually validate:

```bash
cd android
./gradlew validateVersion
```

### Validation Rules

1. Version MUST be defined in `gradle.properties`
2. Version MUST follow semantic versioning format
3. Version MUST contain exactly three numeric components (MAJOR.MINOR.PATCH)
4. Pre-release identifiers MUST be alphanumeric with hyphens and dots
5. Build metadata MUST be alphanumeric with hyphens and dots

## Semantic Versioning Guidelines

### When to Increment MAJOR Version

Increment the MAJOR version when making **incompatible API changes**:

- Removing public classes, methods, or properties
- Changing method signatures (parameters, return types)
- Changing behavior in ways that break existing code
- Removing or renaming configuration options
- Changing minimum SDK requirements

**Example**: `1.5.3` → `2.0.0`

```kotlin
// Version 1.x.x
fun trackEvent(name: String, properties: Map<String, Any>)

// Version 2.0.0 - Breaking change: added required parameter
fun trackEvent(name: String, properties: Map<String, Any>, timestamp: Long)
```

### When to Increment MINOR Version

Increment the MINOR version when adding **backwards-compatible functionality**:

- Adding new public classes, methods, or properties
- Adding new optional parameters with defaults
- Deprecating functionality (but not removing it)
- Adding new configuration options
- Improving performance without changing behavior

**Example**: `1.5.3` → `1.6.0`

```kotlin
// Version 1.5.x
class MobileTracker {
    fun trackEvent(name: String)
}

// Version 1.6.0 - New method added
class MobileTracker {
    fun trackEvent(name: String)
    fun trackScreen(screenName: String)  // New method
}
```

### When to Increment PATCH Version

Increment the PATCH version for **backwards-compatible bug fixes**:

- Fixing incorrect behavior
- Fixing crashes or exceptions
- Fixing memory leaks
- Improving error messages
- Updating documentation
- Internal refactoring without API changes

**Example**: `1.5.3` → `1.5.4`

```kotlin
// Version 1.5.3 - Bug: events not sent when offline
fun sendEvents() {
    if (isOnline()) {
        // Send events
    }
    // Bug: events lost when offline
}

// Version 1.5.4 - Fixed: events queued when offline
fun sendEvents() {
    if (isOnline()) {
        // Send events
    } else {
        queueForLater()  // Bug fix
    }
}
```

### Pre-release Versions

Use pre-release versions for testing before official releases:

- **alpha**: Early development, unstable, may have significant bugs
- **beta**: Feature complete, but may have bugs
- **rc** (release candidate): Stable, final testing before release

**Progression Example**:

```
1.0.0-alpha.1
1.0.0-alpha.2
1.0.0-beta.1
1.0.0-beta.2
1.0.0-rc.1
1.0.0
```

### Build Metadata

Use build metadata for CI/CD tracking (does not affect version precedence):

```
1.0.0+20130313144700
1.0.0+build.123
1.0.0+sha.5114f85
```

## Version Update Workflow

### 1. Determine Version Increment

Review changes since last release:

```bash
git log v0.1.0..HEAD --oneline
```

Ask yourself:

- Did I break backwards compatibility? → MAJOR
- Did I add new features? → MINOR
- Did I only fix bugs? → PATCH

### 2. Update Version

Edit `android/gradle.properties`:

```properties
VERSION_NAME=0.2.0
```

### 3. Validate Version

```bash
cd android
./gradlew validateVersion
```

### 4. Test Publishing Locally

```bash
./gradlew publishToMavenLocal
```

### 5. Commit Version Change

```bash
git add android/gradle.properties
git commit -m "Bump version to 0.2.0"
```

### 6. Create Git Tag

```bash
git tag -a v0.2.0 -m "Release version 0.2.0"
git push origin v0.2.0
```

### 7. Publish

For JitPack, the tag push triggers automatic building.

For Maven Central:

```bash
./gradlew publishReleasePublicationToSonatypeRepository
```

## Version Precedence

Semantic versioning defines precedence rules:

```
1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-beta < 1.0.0-rc.1 < 1.0.0
```

Build metadata does NOT affect precedence:

```
1.0.0+build.1 == 1.0.0+build.2  # Same precedence
```

## Common Scenarios

### Scenario 1: First Release

Start with `1.0.0` for the first stable release:

```properties
VERSION_NAME=1.0.0
```

If not yet stable, use `0.x.x`:

```properties
VERSION_NAME=0.1.0
```

### Scenario 2: Bug Fix Release

Current: `1.2.3`
Fixed a crash → `1.2.4`

```properties
VERSION_NAME=1.2.4
```

### Scenario 3: New Feature

Current: `1.2.4`
Added new tracking method → `1.3.0`

```properties
VERSION_NAME=1.3.0
```

### Scenario 4: Breaking Change

Current: `1.3.0`
Changed API signature → `2.0.0`

```properties
VERSION_NAME=2.0.0
```

### Scenario 5: Pre-release Testing

Current: `1.3.0`
Testing new features → `1.4.0-beta.1`

```properties
VERSION_NAME=1.4.0-beta.1
```

After testing passes → `1.4.0`

```properties
VERSION_NAME=1.4.0
```

## Troubleshooting

### Error: "VERSION_NAME is not defined"

**Solution**: Add `VERSION_NAME` to `android/gradle.properties`:

```properties
VERSION_NAME=0.1.0
```

### Error: "does not follow semantic versioning format"

**Solution**: Ensure version matches `MAJOR.MINOR.PATCH` format:

```properties
# Wrong
VERSION_NAME=1.0
VERSION_NAME=v1.0.0

# Correct
VERSION_NAME=1.0.0
```

### Error: Publishing duplicate version

**Solution**: Increment version number:

```properties
# If current published version is 0.1.0
VERSION_NAME=0.1.1  # or 0.2.0, or 1.0.0
```

## References

- [Semantic Versioning 2.0.0](https://semver.org/)
- [Gradle Version Catalogs](https://docs.gradle.org/current/userguide/platforms.html)
- [Maven Versioning](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#Dependency_Version_Requirement_Specification)

## Checklist for Version Updates

Before releasing a new version:

- [ ] Determine correct version increment (MAJOR/MINOR/PATCH)
- [ ] Update `VERSION_NAME` in `android/gradle.properties`
- [ ] Run `./gradlew validateVersion` to verify format
- [ ] Test locally with `./gradlew publishToMavenLocal`
- [ ] Update CHANGELOG.md with changes
- [ ] Commit version change
- [ ] Create and push Git tag
- [ ] Verify JitPack build succeeds
- [ ] Update README with new version number
- [ ] Announce release if significant
