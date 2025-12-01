# JitPack Build Trigger

## Quick Start

Trigger a JitPack build for your Android library.

### Usage

```bash
# Use version from gradle.properties (recommended)
./trigger-jitpack.sh

# Specify version manually
./trigger-jitpack.sh 0.1.0

# With 'v' prefix
./trigger-jitpack.sh v0.1.0
```

## What It Does

1. **Reads Version**: Gets version from `gradle.properties` or uses provided parameter
2. **Triggers Build**: Sends request to JitPack API to build the specified version
3. **Shows Status**: Displays build status and provides usage instructions

## Prerequisites

Before triggering a build:

1. **Create Git Tag**:

   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

2. **Ensure jitpack.yml is configured** (already done in this repo)

3. **Repository must be public** or you need JitPack authentication

## Output

The script will show:

- ✅ Success: Build triggered, provides usage instructions
- ❌ Failure: Common issues and how to fix them

### Success Example

```
========================================
Triggering JitPack Build
========================================
Repository: Eastplayers/genie-tracking-mobile
Version: v0.1.0
JitPack URL: https://jitpack.io/api/builds/com.github.Eastplayers/genie-tracking-mobile/v0.1.0

Sending request to JitPack...

========================================
Response
========================================
HTTP Status: 200
Response Body:
{
  "status": "ok"
}

✓ Build triggered successfully!

View build status at:
  https://jitpack.io/#Eastplayers/genie-tracking-mobile/v0.1.0

Once built, use in your project:
  implementation 'com.github.Eastplayers:genie-tracking-mobile:v0.1.0'
```

## Troubleshooting

### Tag doesn't exist

```bash
# Create and push the tag first
git tag v0.1.0
git push origin v0.1.0

# Then trigger build
./trigger-jitpack.sh
```

### Build fails

1. Check build logs at: `https://jitpack.io/#Eastplayers/genie-tracking-mobile`
2. Verify `jitpack.yml` configuration
3. Test local build: `./gradlew clean publishToMavenLocal`

### Private repository

JitPack requires public repositories or authentication tokens for private repos.

## Manual Alternative

You can also trigger builds by visiting:

```
https://jitpack.io/#Eastplayers/genie-tracking-mobile
```

Then click "Get it" next to your version.

## Related Files

- `jitpack.yml` - JitPack configuration (at repo root)
- `gradle.properties` - Contains VERSION_NAME
- `PUBLISHING_GUIDE.md` - Complete publishing documentation
