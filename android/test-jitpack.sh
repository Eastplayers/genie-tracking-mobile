#!/bin/bash
# Test script for JitPack publishing workflow
# This script simulates the JitPack build process locally

set -e

echo "🔍 Testing JitPack Publishing Workflow"
echo "======================================"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Get current version from gradle.properties
VERSION=$(grep "VERSION_NAME=" android/gradle.properties | cut -d'=' -f2)
echo "📦 Current version: $VERSION"
echo ""

# Check if tag already exists
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
    echo "⚠️  Warning: Tag v$VERSION already exists"
    echo "   To recreate the tag, run:"
    echo "   git tag -d v$VERSION"
    echo "   git push origin :refs/tags/v$VERSION"
    echo ""
else
    echo "✅ Tag v$VERSION does not exist yet"
    echo ""
fi

# Verify build configuration
echo "🔧 Verifying build configuration..."
if ! grep -q "^group = GROUP" android/build.gradle; then
    echo "❌ Error: 'group = GROUP' not found in android/build.gradle"
    exit 1
fi

if ! grep -q "^version = VERSION_NAME" android/build.gradle; then
    echo "❌ Error: 'version = VERSION_NAME' not found in android/build.gradle"
    exit 1
fi

echo "✅ Build configuration is correct"
echo ""

# Test local build (simulates JitPack build)
echo "🏗️  Testing local build (simulating JitPack)..."
cd android
./gradlew clean build publishToMavenLocal -x test
cd ..
echo "✅ Build successful"
echo ""

# Verify artifacts
echo "📋 Verifying published artifacts..."
GROUP=$(grep "GROUP=" android/gradle.properties | cut -d'=' -f2)
ARTIFACT=$(grep "ARTIFACT_ID=" android/gradle.properties | cut -d'=' -f2)
GROUP_PATH=$(echo $GROUP | tr '.' '/')

MAVEN_PATH="$HOME/.m2/repository/$GROUP_PATH/$ARTIFACT/$VERSION"

if [ ! -d "$MAVEN_PATH" ]; then
    echo "❌ Error: Artifacts not found at $MAVEN_PATH"
    exit 1
fi

echo "✅ Artifacts found at: $MAVEN_PATH"
echo ""
echo "📦 Published artifacts:"
ls -lh "$MAVEN_PATH" | grep -E "\.(aar|pom|jar)$" | awk '{print "   " $9 " (" $5 ")"}'
echo ""

# Instructions for actual JitPack publishing
echo "📝 To publish to JitPack:"
echo "======================================"
echo ""
echo "1. Commit all changes:"
echo "   git add ."
echo "   git commit -m \"Release version $VERSION\""
echo ""
echo "2. Create and push the tag:"
echo "   git tag -a v$VERSION -m \"Release version $VERSION\""
echo "   git push origin main"
echo "   git push origin v$VERSION"
echo ""
echo "3. Check JitPack build status:"
echo "   https://jitpack.io/#$GROUP/$ARTIFACT/v$VERSION"
echo ""
echo "4. Once built, consumers can use:"
echo "   repositories {"
echo "       maven { url 'https://jitpack.io' }"
echo "   }"
echo "   dependencies {"
echo "       implementation '$GROUP:$ARTIFACT:$VERSION'"
echo "   }"
echo ""
echo "✅ JitPack workflow test completed successfully!"
