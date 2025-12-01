# Publishing Guide for MobileTracker Android Library

This guide provides step-by-step instructions for publishing the MobileTracker Android library to various Maven repositories.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Publishing Methods](#publishing-methods)
  - [Local Maven (Testing)](#local-maven-testing)
  - [JitPack (Quick Public Release)](#jitpack-quick-public-release)
  - [Maven Central (Professional Distribution)](#maven-central-professional-distribution)
- [Troubleshooting](#troubleshooting)
- [Release Checklist](#release-checklist)
- [Version Management](#version-management)

## Overview

The MobileTracker library can be published to three different types of repositories:

| Repository        | Use Case                    | Setup Time | Complexity |
| ----------------- | --------------------------- | ---------- | ---------- |
| **Local Maven**   | Testing and development     | 5 minutes  | Low        |
| **JitPack**       | Quick public distribution   | 15 minutes | Low        |
| **Maven Central** | Professional production use | 1-2 days   | High       |

## Prerequisites

### Required Tools

- JDK 17 or higher
- Android SDK with API level 24+
- Gradle 8.0+
- Git (for JitPack and version control)

### Required Files

Ensure these files are properly configured:

- `android/build.gradle` - Contains publishing configuration
- `android/gradle.properties` - Contains version and library metadata
- `jitpack.yml` - JitPack build configuration (in repository root)

## Publishing Methods

### Local Maven (Testing)

Local Maven publishing is ideal for testing the library integration before public release.

#### Step 1: Configure Version

Edit `android/gradle.properties`:

```properties
VERSION_NAME=0.1.0-SNAPSHOT
GROUP=ai.founderos
POM_ARTIFACT_ID=mobile-tracking-sdk
```

#### Step 2: Publish to Local Maven

From the repository root, run:

```bash
cd android
./gradlew publishToMavenLocal
```

This publishes the library to `~/.m2/repository/ai/founderos/mobile-tracking-sdk/`.

#### Step 3: Verify Publication

Check that the artifacts were created:

```bash
ls -la ~/.m2/repository/ai/founderos/mobile-tracking-sdk/0.1.0-SNAPSHOT/
```

You should see:

- `mobile-tracking-sdk-0.1.0-SNAPSHOT.aar` - The library archive
- `mobile-tracking-sdk-0.1.0-SNAPSHOT.pom` - Dependency metadata
- `mobile-tracking-sdk-0.1.0-SNAPSHOT-sources.jar` - Source code
- `mobile-tracking-sdk-0.1.0-SNAPSHOT-javadoc.jar` - Documentation

#### Step 4: Test in Consumer Project

In your test project's `build.gradle`:

```gradle
repositories {
    mavenLocal()
}

dependencies {
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0-SNAPSHOT'
}
```

Sync Gradle and verify the library is resolved.

#### Advantages

- ✅ Immediate availability
- ✅ No external dependencies
- ✅ Perfect for testing
- ✅ No credentials required

#### Disadvantages

- ❌ Only available on local machine
- ❌ Not suitable for distribution
- ❌ Must republish after each change

---

### JitPack (Quick Public Release)

JitPack builds and publishes your library directly from GitHub tags.

#### Step 1: Prepare Repository

Ensure your code is pushed to GitHub:

```bash
git add .
git commit -m "Prepare for release"
git push origin main
```

#### Step 2: Update Version

Edit `android/gradle.properties` and remove `-SNAPSHOT`:

```properties
VERSION_NAME=0.1.0
```

Commit this change:

```bash
git add android/gradle.properties
git commit -m "Release version 0.1.0"
git push origin main
```

#### Step 3: Create Git Tag

Create and push a version tag:

```bash
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin v0.1.0
```

#### Step 4: Trigger JitPack Build

JitPack automatically detects the new tag and starts building. You can monitor the build at:

```
https://jitpack.io/com/github/YOUR_USERNAME/YOUR_REPO/v0.1.0/build.log
```

Replace `YOUR_USERNAME` and `YOUR_REPO` with your GitHub details.

#### Step 5: Verify Publication

Once the build completes (usually 2-5 minutes), verify at:

```
https://jitpack.io/#YOUR_USERNAME/YOUR_REPO
```

#### Step 6: Update Documentation

Add JitPack instructions to your README:

````markdown
### Installation

Add the JitPack repository to your root `build.gradle`:

```gradle
allprojects {
    repositories {
        maven { url 'https://jitpack.io' }
    }
}
```
````

Add the dependency:

```gradle
dependencies {
    implementation 'com.github.YOUR_USERNAME:YOUR_REPO:0.1.0'
}
```

````

#### Consumer Usage

Users can now add your library:

```gradle
repositories {
    maven { url 'https://jitpack.io' }
}

dependencies {
    implementation 'com.github.YOUR_USERNAME:YOUR_REPO:0.1.0'
}
````

#### Advantages

- ✅ No account setup required
- ✅ Automatic builds from Git tags
- ✅ Fast setup (< 15 minutes)
- ✅ Free for public repositories
- ✅ Supports commit hashes and branches

#### Disadvantages

- ❌ Less discoverable than Maven Central
- ❌ Requires JitPack repository in consumer projects
- ❌ Build times depend on JitPack infrastructure
- ❌ Not suitable for private repositories (paid)

---

### Maven Central (Professional Distribution)

Maven Central is the industry-standard repository for Java and Android libraries.

#### Prerequisites

- Sonatype OSSRH account
- GPG key for signing
- Verified domain or GitHub organization

#### Step 1: Create Sonatype Account

1. Go to https://issues.sonatype.org/
2. Create a JIRA account
3. Create a new issue to claim your groupId:

   - Project: Community Support - Open Source Project Repository Hosting (OSSRH)
   - Issue Type: New Project
   - Group Id: `ai.founderos` (or your domain)
   - Project URL: Your GitHub repository
   - SCM URL: Your GitHub repository .git URL

4. Wait for approval (usually 1-2 business days)

#### Step 2: Generate GPG Keys

Generate a GPG key pair:

```bash
gpg --gen-key
```

Follow the prompts:

- Real name: Your name
- Email: Your email
- Passphrase: Choose a strong passphrase

List your keys to get the key ID:

```bash
gpg --list-keys
```

Export your secret key:

```bash
gpg --keyring secring.gpg --export-secret-keys > ~/.gnupg/secring.gpg
```

Publish your public key to a key server:

```bash
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

#### Step 3: Configure Credentials

Create or edit `~/.gradle/gradle.properties` (NOT the project's gradle.properties):

```properties
# Sonatype credentials
SONATYPE_USERNAME=your-jira-username
SONATYPE_PASSWORD=your-jira-password

# GPG signing
signing.keyId=YOUR_KEY_ID
signing.password=your-gpg-passphrase
signing.secretKeyRingFile=/Users/yourname/.gnupg/secring.gpg
```

**Security Note**: Never commit these credentials to version control!

#### Step 4: Configure Build for Maven Central

The `android/build.gradle` should already have Maven Central configuration. Verify it includes:

```gradle
plugins {
    id 'maven-publish'
    id 'signing'
}

signing {
    sign publishing.publications
}

publishing {
    repositories {
        maven {
            name = "sonatype"
            url = "https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/"
            credentials {
                username = project.findProperty("SONATYPE_USERNAME") ?: ""
                password = project.findProperty("SONATYPE_PASSWORD") ?: ""
            }
        }
    }
}
```

#### Step 5: Prepare Release Version

Edit `android/gradle.properties`:

```properties
VERSION_NAME=0.1.0
```

Ensure no `-SNAPSHOT` suffix for releases.

#### Step 6: Publish to Maven Central

From the `android` directory:

```bash
./gradlew publishReleasePublicationToSonatypeRepository
```

This will:

1. Build the AAR
2. Generate POM, sources, and javadoc JARs
3. Sign all artifacts with GPG
4. Upload to Sonatype OSSRH staging repository

#### Step 7: Release from Staging

1. Log in to https://s01.oss.sonatype.org/
2. Click "Staging Repositories" in the left sidebar
3. Find your repository (usually named `aifounderos-XXXX`)
4. Select it and click "Close"
5. Wait for validation to complete (2-5 minutes)
6. If validation passes, click "Release"
7. The artifacts will sync to Maven Central within 10-30 minutes

#### Step 8: Verify Publication

After 30 minutes, verify at:

```
https://repo1.maven.org/maven2/ai/founderos/mobile-tracking-sdk/
```

#### Step 9: Update Documentation

Update your README with Maven Central instructions:

````markdown
### Installation

Add the dependency to your `build.gradle`:

```gradle
dependencies {
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
}
```
````

````

#### Consumer Usage

Users can now add your library without any special repository configuration:

```gradle
dependencies {
    implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
}
````

#### Advantages

- ✅ Industry standard repository
- ✅ Automatic inclusion in Android Studio/Gradle
- ✅ Better discoverability
- ✅ Professional credibility
- ✅ Immutable releases (security)

#### Disadvantages

- ❌ Complex initial setup (1-2 days)
- ❌ Requires GPG key management
- ❌ Manual approval process for first release
- ❌ More strict validation requirements
- ❌ Cannot delete or modify published versions

---

## Troubleshooting

### Build Failures

#### Problem: "Could not find method maven-publish"

**Cause**: The `maven-publish` plugin is not applied.

**Solution**: Ensure `android/build.gradle` contains:

```gradle
plugins {
    id 'maven-publish'
}
```

#### Problem: "Task 'publishToMavenLocal' not found"

**Cause**: Publishing configuration is missing or incorrect.

**Solution**: Verify the `publishing` block exists in `android/build.gradle` and includes a `publications` section.

#### Problem: Build fails with "Unsupported class file major version"

**Cause**: JDK version mismatch.

**Solution**: Ensure you're using JDK 17:

```bash
java -version
```

If needed, update `jitpack.yml`:

```yaml
jdk:
  - openjdk17
```

### Publishing Failures

#### Problem: "401 Unauthorized" when publishing to Maven Central

**Cause**: Invalid or missing Sonatype credentials.

**Solution**:

1. Verify credentials in `~/.gradle/gradle.properties`
2. Ensure username and password match your JIRA account
3. Check that the credentials file has correct permissions:

```bash
chmod 600 ~/.gradle/gradle.properties
```

#### Problem: "Failed to sign artifact"

**Cause**: GPG signing configuration is incorrect.

**Solution**:

1. Verify your GPG key exists:

```bash
gpg --list-secret-keys
```

2. Check the key ID in `gradle.properties` matches
3. Verify the secret key ring file path is correct
4. Test GPG signing manually:

```bash
echo "test" | gpg --clearsign
```

#### Problem: JitPack build fails

**Cause**: Build configuration issues or missing dependencies.

**Solution**:

1. Check the build log at `https://jitpack.io/com/github/USER/REPO/TAG/build.log`
2. Common issues:

   - Missing `jitpack.yml` with correct JDK version
   - Incorrect group or version in `build.gradle`
   - Missing Android SDK components

3. Test locally first:

```bash
./gradlew clean build publishToMavenLocal
```

#### Problem: "Repository not found" in JitPack

**Cause**: Repository is private or tag doesn't exist.

**Solution**:

1. Ensure repository is public on GitHub
2. Verify the tag exists:

```bash
git tag -l
```

3. Ensure the tag is pushed:

```bash
git push origin v0.1.0
```

### Dependency Resolution Failures

#### Problem: Consumer project cannot resolve the library

**Cause**: Repository not configured or incorrect coordinates.

**Solution**:

For JitPack:

```gradle
repositories {
    maven { url 'https://jitpack.io' }
}
```

For Local Maven:

```gradle
repositories {
    mavenLocal()
}
```

For Maven Central (no special repository needed):

```gradle
repositories {
    mavenCentral()  // Usually already present
}
```

#### Problem: "Could not find ai.founderos:mobile-tracking-sdk:0.1.0"

**Cause**: Version doesn't exist or hasn't synced yet.

**Solution**:

1. Verify the version exists in the repository
2. For Maven Central, wait 30 minutes for sync
3. For JitPack, check build status
4. Try refreshing dependencies:

```bash
./gradlew --refresh-dependencies
```

#### Problem: "Duplicate class" errors after adding library

**Cause**: Dependency conflict or library included multiple ways.

**Solution**:

1. Check for duplicate dependencies:

```bash
./gradlew :app:dependencies
```

2. Exclude conflicting dependencies:

```gradle
implementation('ai.founderos:mobile-tracking-sdk:0.1.0') {
    exclude group: 'conflicting-group', module: 'conflicting-module'
}
```

### Version Conflicts

#### Problem: "Version already exists" when publishing

**Cause**: Attempting to republish an immutable version.

**Solution**:

For Maven Central:

- Increment the version number (releases are immutable)

For JitPack:

- Delete and recreate the Git tag:

```bash
git tag -d v0.1.0
git push origin :refs/tags/v0.1.0
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin v0.1.0
```

For Local Maven:

- Local Maven allows overwriting; just republish

### ProGuard/R8 Issues

#### Problem: Library classes are stripped in release builds

**Cause**: ProGuard/R8 is removing library classes.

**Solution**: Add ProGuard rules to `android/proguard-rules.pro`:

```proguard
-keep class ai.founderos.mobiletracker.** { *; }
-keepclassmembers class ai.founderos.mobiletracker.** { *; }
```

Consumers should also add these rules to their `proguard-rules.pro`.

---

## Release Checklist

Use this checklist before publishing a new version:

### Pre-Release

- [ ] All tests pass locally

  ```bash
  ./gradlew test
  ```

- [ ] Code is committed and pushed to main branch

  ```bash
  git status
  ```

- [ ] Version number is updated in `android/gradle.properties`

  - [ ] Follows semantic versioning (MAJOR.MINOR.PATCH)
  - [ ] `-SNAPSHOT` suffix removed for releases

- [ ] CHANGELOG.md is updated with release notes

  - [ ] New features documented
  - [ ] Bug fixes listed
  - [ ] Breaking changes highlighted

- [ ] README.md is up to date

  - [ ] Installation instructions are correct
  - [ ] Version numbers match the release
  - [ ] Examples work with new version

- [ ] API documentation is current

  - [ ] New public APIs are documented
  - [ ] Deprecated APIs are marked

- [ ] Breaking changes are documented
  - [ ] Migration guide provided if needed

### Build Verification

- [ ] Clean build succeeds

  ```bash
  ./gradlew clean build
  ```

- [ ] No build warnings

  ```bash
  ./gradlew build --warning-mode all
  ```

- [ ] AAR file is generated correctly

  ```bash
  ls -la android/build/outputs/aar/
  ```

- [ ] Sources JAR contains source files

  ```bash
  unzip -l android/build/libs/*-sources.jar
  ```

- [ ] Javadoc JAR contains documentation
  ```bash
  unzip -l android/build/libs/*-javadoc.jar
  ```

### Local Testing

- [ ] Library publishes to local Maven successfully

  ```bash
  ./gradlew publishToMavenLocal
  ```

- [ ] Test project can resolve the library from mavenLocal()

- [ ] All library classes are accessible in test project

- [ ] Example app builds and runs with the library

- [ ] ProGuard/R8 works correctly in release builds
  ```bash
  ./gradlew :app:assembleRelease
  ```

### Publication

Choose your publishing method:

#### For JitPack:

- [ ] Code is pushed to GitHub
- [ ] Git tag is created with version number
  ```bash
  git tag -a v0.1.0 -m "Release version 0.1.0"
  ```
- [ ] Tag is pushed to GitHub
  ```bash
  git push origin v0.1.0
  ```
- [ ] JitPack build succeeds
  - Check: `https://jitpack.io/#YOUR_USERNAME/YOUR_REPO`
- [ ] Library is downloadable from JitPack

#### For Maven Central:

- [ ] Sonatype credentials are configured
- [ ] GPG keys are set up and published
- [ ] Artifacts are signed correctly
- [ ] Published to staging repository
  ```bash
  ./gradlew publishReleasePublicationToSonatypeRepository
  ```
- [ ] Staging repository is closed and released
- [ ] Artifacts appear on Maven Central (wait 30 minutes)
  - Check: `https://repo1.maven.org/maven2/ai/founderos/mobile-tracking-sdk/`

### Post-Release

- [ ] GitHub release is created

  - [ ] Release notes are added
  - [ ] AAR file is attached as asset

- [ ] Documentation is updated

  - [ ] README shows new version
  - [ ] CHANGELOG is committed

- [ ] Version is bumped for next development cycle

  - [ ] Update to next version with `-SNAPSHOT`
  - Example: `0.1.0` → `0.2.0-SNAPSHOT`

- [ ] Announcement is made (if applicable)

  - [ ] Blog post
  - [ ] Social media
  - [ ] Email to users

- [ ] Monitor for issues
  - [ ] Check GitHub issues
  - [ ] Monitor JitPack build status
  - [ ] Watch for dependency resolution problems

---

## Version Management

### Semantic Versioning

Follow semantic versioning (SemVer) for all releases:

```
MAJOR.MINOR.PATCH
```

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality, backwards compatible
- **PATCH**: Bug fixes, backwards compatible

Examples:

- `0.1.0` - Initial release
- `0.1.1` - Bug fix
- `0.2.0` - New feature
- `1.0.0` - First stable release
- `2.0.0` - Breaking changes

### Snapshot Versions

Use `-SNAPSHOT` suffix for development versions:

```
0.2.0-SNAPSHOT
```

Snapshot versions:

- Can be republished multiple times
- Not suitable for production use
- Useful for testing unreleased features

### Version Update Process

1. **During Development**: Use snapshot versions

   ```properties
   VERSION_NAME=0.2.0-SNAPSHOT
   ```

2. **Before Release**: Remove snapshot suffix

   ```properties
   VERSION_NAME=0.2.0
   ```

3. **After Release**: Bump to next snapshot
   ```properties
   VERSION_NAME=0.3.0-SNAPSHOT
   ```

### Version Validation

The build system validates version format. Valid formats:

- `0.1.0` - Release version
- `0.1.0-SNAPSHOT` - Snapshot version
- `1.0.0-alpha01` - Pre-release version
- `1.0.0-beta01` - Beta version
- `1.0.0-rc01` - Release candidate

Invalid formats:

- `v0.1.0` - No 'v' prefix
- `0.1` - Must have three parts
- `0.1.0.1` - Too many parts

---

## Additional Resources

### Documentation

- [Gradle Publishing Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)
- [JitPack Documentation](https://jitpack.io/docs/)
- [Maven Central Guide](https://central.sonatype.org/publish/publish-guide/)
- [Semantic Versioning](https://semver.org/)

### Tools

- [JitPack Build Status](https://jitpack.io/)
- [Sonatype OSSRH](https://s01.oss.sonatype.org/)
- [Maven Central Search](https://search.maven.org/)
- [GPG Documentation](https://gnupg.org/documentation/)

### Support

- GitHub Issues: Report problems with the library
- Stack Overflow: Tag questions with `mobile-tracking-sdk`
- Email: support@founderos.ai

---

## Quick Reference

### Common Commands

```bash
# Publish to local Maven
./gradlew publishToMavenLocal

# Build and test
./gradlew clean build test

# Create release tag
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin v0.1.0

# Publish to Maven Central
./gradlew publishReleasePublicationToSonatypeRepository

# Check dependencies
./gradlew :app:dependencies

# Refresh dependencies
./gradlew --refresh-dependencies
```

### Dependency Declarations

**JitPack**:

```gradle
implementation 'com.github.USERNAME:REPO:0.1.0'
```

**Maven Central**:

```gradle
implementation 'ai.founderos:mobile-tracking-sdk:0.1.0'
```

**Local Maven**:

```gradle
implementation 'ai.founderos:mobile-tracking-sdk:0.1.0-SNAPSHOT'
```

---

**Last Updated**: 2025-01-27
**Library Version**: 0.1.0
