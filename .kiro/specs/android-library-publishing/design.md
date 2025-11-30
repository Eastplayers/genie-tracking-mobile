# Design Document: Android Library Publishing

## Overview

This design document outlines the implementation strategy for publishing the MobileTracker Android library to various Maven repositories. The solution provides multiple publishing options to accommodate different use cases: JitPack for quick GitHub-based publishing, Maven Central for professional public distribution, and local Maven for testing.

The design leverages Gradle's `maven-publish` plugin to generate and publish library artifacts (AAR, POM, sources, and documentation) to the target repositories.

## Architecture

### Publishing Pipeline

```
Source Code (Kotlin)
    ↓
Gradle Build
    ↓
Generate Artifacts:
  - AAR (compiled library)
  - POM (dependency metadata)
  - Sources JAR
  - Javadoc JAR
    ↓
Sign Artifacts (Maven Central only)
    ↓
Publish to Repository:
  - JitPack (GitHub tags)
  - Maven Central (Sonatype OSSRH)
  - Local Maven (~/.m2/repository)
    ↓
Consumers add dependency
```

### Repository Options

1. **JitPack** (Recommended for quick start)

   - Builds directly from GitHub
   - No account setup required
   - Automatic versioning from Git tags
   - Available within minutes

2. **Maven Central** (Recommended for production)

   - Industry standard repository
   - Requires Sonatype account
   - Requires GPG signing
   - More setup but better discoverability

3. **Local Maven** (Recommended for testing)
   - Publishes to local filesystem
   - No external dependencies
   - Immediate availability
   - Perfect for integration testing

## Components and Interfaces

### 1. Gradle Publishing Configuration

**File**: `android/build.gradle`

**Responsibilities**:

- Configure `maven-publish` plugin
- Define publication artifacts
- Specify repository targets
- Configure signing (for Maven Central)

**Key Components**:

```groovy
plugins {
    id 'maven-publish'
    id 'signing' // For Maven Central only
}

publishing {
    publications {
        release(MavenPublication) {
            // Artifact configuration
        }
    }
    repositories {
        // Repository definitions
    }
}
```

### 2. POM Metadata Configuration

**Responsibilities**:

- Define library metadata (name, description, URL)
- Specify license information
- List developers and contributors
- Declare SCM (source control) information

**Required Fields**:

- `groupId`: com.mobiletracker
- `artifactId`: mobile-tracking-sdk
- `version`: Semantic version (e.g., 0.1.0)
- `name`: Human-readable name
- `description`: Library description
- `url`: Project homepage
- `licenses`: License information
- `developers`: Developer information
- `scm`: Source control URLs

### 3. Gradle Properties Configuration

**File**: `gradle.properties` or `local.properties`

**Responsibilities**:

- Store sensitive credentials
- Configure signing keys
- Define version numbers
- Set repository URLs

**Properties**:

```properties
# Library version
VERSION_NAME=0.1.0
GROUP=com.mobiletracker
ARTIFACT_ID=mobile-tracking-sdk

# Maven Central (if used)
SONATYPE_USERNAME=your-username
SONATYPE_PASSWORD=your-password
signing.keyId=your-key-id
signing.password=your-key-password
signing.secretKeyRingFile=/path/to/secring.gpg
```

### 4. JitPack Configuration

**File**: `jitpack.yml` (optional, in repository root)

**Responsibilities**:

- Specify JDK version
- Configure build commands
- Set environment variables

**Example**:

```yaml
jdk:
  - openjdk17
before_install:
  - sdk install java 17.0.1-open
```

## Data Models

### Publication Artifact

```kotlin
data class PublicationArtifact(
    val groupId: String,           // e.g., "com.mobiletracker"
    val artifactId: String,        // e.g., "mobile-tracking-sdk"
    val version: String,           // e.g., "0.1.0"
    val packaging: String,         // "aar"
    val aarFile: File,            // Compiled AAR
    val pomFile: File,            // Generated POM
    val sourcesJar: File?,        // Sources JAR (optional)
    val javadocJar: File?         // Javadoc JAR (optional)
)
```

### Repository Configuration

```kotlin
data class RepositoryConfig(
    val type: RepositoryType,      // JITPACK, MAVEN_CENTRAL, LOCAL
    val url: String,               // Repository URL
    val credentials: Credentials?, // Username/password if needed
    val requiresSigning: Boolean   // true for Maven Central
)

enum class RepositoryType {
    JITPACK,
    MAVEN_CENTRAL,
    LOCAL_MAVEN,
    CUSTOM
}
```

### Maven Coordinates

```kotlin
data class MavenCoordinates(
    val groupId: String,
    val artifactId: String,
    val version: String
) {
    fun toDependencyNotation(): String {
        return "$groupId:$artifactId:$version"
    }
}
```

##

## Correctness Properties

_A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees._

### Property 1: AAR Generation Completeness

_For any_ successful build execution, the generated AAR file should contain all compiled classes, resources, and manifest entries from the library module.
**Validates: Requirements 1.1**

### Property 2: POM Dependency Accuracy

_For any_ published artifact, the generated POM file should list all runtime dependencies declared in build.gradle with correct versions and scopes.
**Validates: Requirements 1.2**

### Property 3: Artifact Availability

_For any_ successfully published library version, a consumer project should be able to resolve and download the artifact using the published Maven coordinates.
**Validates: Requirements 1.4**

### Property 4: Version Consistency

_For any_ published artifact, the version number in the POM, AAR filename, and dependency declaration should all match exactly.
**Validates: Requirements 1.5**

### Property 5: JitPack Tag Correspondence

_For any_ Git tag created in the repository, JitPack should build and make available a library version matching that tag name.
**Validates: Requirements 3.2**

### Property 6: Local Maven Immediate Availability

_For any_ library published to local Maven, other local projects should be able to resolve the dependency immediately without network access.
**Validates: Requirements 4.2**

## Error Handling

### Build Failures

**Scenario**: Gradle build fails during artifact generation

**Handling**:

- Validate all required dependencies are available
- Check Kotlin and Android Gradle Plugin versions are compatible
- Ensure minimum SDK and compile SDK are correctly configured
- Provide clear error messages indicating the failure point

### Publishing Failures

**Scenario**: Upload to repository fails

**Handling**:

- **Authentication Errors**: Verify credentials in gradle.properties
- **Network Errors**: Retry with exponential backoff
- **Validation Errors**: Check POM metadata completeness
- **Signing Errors**: Verify GPG key configuration and password

**Error Messages**:

```
Publishing failed: Invalid credentials for Maven Central
→ Check SONATYPE_USERNAME and SONATYPE_PASSWORD in gradle.properties

Publishing failed: Missing required POM metadata
→ Ensure name, description, url, licenses, and developers are configured

Publishing failed: GPG signing error
→ Verify signing.keyId, signing.password, and signing.secretKeyRingFile
```

### Version Conflicts

**Scenario**: Attempting to publish a version that already exists

**Handling**:

- Maven Central: Reject duplicate versions (immutable)
- JitPack: Rebuild on tag update (mutable)
- Local Maven: Overwrite existing version with warning

**Resolution**:

- Increment version number for new releases
- Use snapshot versions for development (e.g., 0.1.0-SNAPSHOT)
- Delete and recreate Git tags for JitPack if needed

### Dependency Resolution Failures

**Scenario**: Consumer project cannot resolve the published library

**Handling**:

- Verify repository is added to consumer's build.gradle
- Check Maven coordinates match exactly (groupId:artifactId:version)
- Ensure repository URL is accessible
- For JitPack, verify the build succeeded (check jitpack.io/com/github/...)
- Clear Gradle cache if stale: `./gradlew --refresh-dependencies`

## Testing Strategy

### Unit Testing

Unit tests will verify the configuration and metadata generation:

1. **POM Generation Tests**

   - Verify POM contains correct groupId, artifactId, version
   - Verify all dependencies are listed with correct scopes
   - Verify required metadata fields are present

2. **Version Validation Tests**

   - Test semantic version format validation
   - Test version consistency across artifacts

3. **Credential Validation Tests**
   - Test credential loading from properties files
   - Test handling of missing credentials

### Integration Testing

Integration tests will verify end-to-end publishing workflows:

1. **Local Maven Publishing Test**

   - Publish library to local Maven repository
   - Create test consumer project
   - Verify consumer can resolve and use the library
   - Verify all classes and resources are accessible

2. **JitPack Build Test**

   - Create Git tag
   - Trigger JitPack build
   - Verify build succeeds
   - Verify artifact is downloadable

3. **Artifact Completeness Test**
   - Publish library
   - Extract AAR file
   - Verify all expected classes are present
   - Verify resources and manifest are included

### Manual Testing Checklist

Before releasing to production:

- [ ] Build succeeds without warnings
- [ ] All unit tests pass
- [ ] AAR file opens and contains expected contents
- [ ] POM file contains all required metadata
- [ ] Sources JAR contains source files
- [ ] Javadoc JAR contains documentation
- [ ] Local Maven publishing works
- [ ] Test project can import and use the library
- [ ] ProGuard rules work correctly (if applicable)
- [ ] README includes correct dependency declaration
- [ ] Version number is updated appropriately

## Implementation Details

### Option 1: JitPack Publishing (Easiest)

**Setup Steps**:

1. Ensure `build.gradle` has proper configuration:

```groovy
group = 'com.github.yourusername'
version = '0.1.0'
```

2. Commit and push code to GitHub

3. Create and push a Git tag:

```bash
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin v0.1.0
```

4. JitPack automatically builds the library

**Consumer Usage**:

```groovy
repositories {
    maven { url 'https://jitpack.io' }
}

dependencies {
    implementation 'com.github.yourusername:mobile-tracking-sdk:0.1.0'
}
```

**Advantages**:

- No account setup required
- Automatic builds from Git tags
- Fast setup (< 5 minutes)
- Free for public repositories

**Disadvantages**:

- Less discoverable than Maven Central
- Requires JitPack repository in consumer projects
- Build times depend on JitPack infrastructure

### Option 2: Maven Central Publishing (Most Professional)

**Setup Steps**:

1. Create Sonatype OSSRH account at issues.sonatype.org

2. Create a JIRA ticket to claim your groupId

3. Generate GPG keys:

```bash
gpg --gen-key
gpg --keyring secring.gpg --export-secret-keys > ~/.gnupg/secring.gpg
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

4. Configure `gradle.properties`:

```properties
SONATYPE_USERNAME=your-username
SONATYPE_PASSWORD=your-password
signing.keyId=your-key-id
signing.password=your-key-password
signing.secretKeyRingFile=/Users/you/.gnupg/secring.gpg
```

5. Add publishing configuration to `build.gradle` (see implementation tasks)

6. Publish:

```bash
./gradlew publishReleasePublicationToSonatypeRepository
./gradlew closeAndReleaseRepository
```

**Consumer Usage**:

```groovy
dependencies {
    implementation 'com.mobiletracker:mobile-tracking-sdk:0.1.0'
}
```

**Advantages**:

- Industry standard repository
- Automatic inclusion in Android Studio/Gradle
- Better discoverability
- Professional credibility

**Disadvantages**:

- Complex initial setup (1-2 days)
- Requires GPG key management
- Manual approval process for first release
- More strict validation requirements

### Option 3: Local Maven Publishing (For Testing)

**Setup Steps**:

1. Add publishing configuration to `build.gradle` (see implementation tasks)

2. Publish to local Maven:

```bash
./gradlew publishToMavenLocal
```

**Consumer Usage**:

```groovy
repositories {
    mavenLocal()
}

dependencies {
    implementation 'com.mobiletracker:mobile-tracking-sdk:0.1.0'
}
```

**Advantages**:

- Immediate availability
- No external dependencies
- Perfect for testing
- No credentials required

**Disadvantages**:

- Only available on local machine
- Not suitable for distribution
- Must republish after each change

## Recommended Approach

For the MobileTracker library, we recommend a **phased approach**:

### Phase 1: Local Maven (Immediate)

- Set up local Maven publishing
- Test integration with example projects
- Validate artifact completeness
- Estimated time: 1-2 hours

### Phase 2: JitPack (Short-term)

- Configure for JitPack compatibility
- Create initial release tags
- Update documentation with JitPack instructions
- Estimated time: 2-3 hours

### Phase 3: Maven Central (Long-term)

- Complete Sonatype OSSRH setup
- Configure GPG signing
- Publish to Maven Central
- Update documentation with Maven Central instructions
- Estimated time: 1-2 days (including approval wait time)

This approach allows immediate testing (Phase 1), quick public availability (Phase 2), and professional distribution (Phase 3) without blocking progress.

## Documentation Requirements

### README Updates

The README.md should include dependency declarations for each publishing method:

**JitPack**:

````markdown
### Android (Gradle)

Add the JitPack repository:

```gradle
repositories {
    maven { url 'https://jitpack.io' }
}
```
````

Add the dependency:

```gradle
dependencies {
    implementation 'com.github.yourusername:mobile-tracking-sdk:0.1.0'
}
```

````

**Maven Central**:
```markdown
### Android (Gradle)

Add the dependency:

```gradle
dependencies {
    implementation 'com.mobiletracker:mobile-tracking-sdk:0.1.0'
}
````

```

### Publishing Guide

Create a `PUBLISHING.md` document with:
- Step-by-step publishing instructions for each method
- Troubleshooting common issues
- Version numbering guidelines
- Release checklist

### Consumer Integration Guide

Update documentation to include:
- Minimum requirements (SDK version, Gradle version)
- ProGuard/R8 rules if needed
- Common integration issues and solutions
- Migration guides for version updates
```
