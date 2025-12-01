#!/bin/bash

# CocoaPods Publishing Script for FounderOSMobileTracker
# This script validates and publishes the podspec to CocoaPods Trunk

set -e  # Exit on any error

PODSPEC_PATH="ios/FounderOSMobileTracker.podspec"
PODSPEC_NAME="FounderOSMobileTracker"

echo "========================================="
echo "CocoaPods Publishing Script"
echo "========================================="
echo ""

# Check if podspec file exists
if [ ! -f "$PODSPEC_PATH" ]; then
    echo "❌ Error: Podspec file not found at $PODSPEC_PATH"
    exit 1
fi

# Extract version from podspec
VERSION=$(grep "s.version" "$PODSPEC_PATH" | sed -E "s/.*'([0-9]+\.[0-9]+\.[0-9]+)'.*/\1/")
echo "📦 Package: $PODSPEC_NAME"
echo "🏷️  Version: $VERSION"
echo ""

# Check if git tag exists
if ! git rev-parse "v$VERSION" >/dev/null 2>&1; then
    echo "⚠️  Warning: Git tag v$VERSION does not exist"
    echo "   Creating tag v$VERSION..."
    git tag "v$VERSION"
    echo "   Pushing tag to remote..."
    git push origin "v$VERSION"
    echo "✅ Tag created and pushed"
    echo ""
fi

# Validate podspec locally
echo "🔍 Step 1: Validating podspec locally..."
echo "   Running: pod spec lint $PODSPEC_PATH --allow-warnings"
echo ""

if pod spec lint "$PODSPEC_PATH" --allow-warnings; then
    echo "✅ Local validation passed"
    echo ""
else
    echo "❌ Local validation failed"
    echo "   Please fix the errors above before publishing"
    exit 1
fi

# Check if user is registered with CocoaPods Trunk
echo "🔍 Step 2: Checking CocoaPods Trunk registration..."
if ! pod trunk me >/dev/null 2>&1; then
    echo "❌ You are not registered with CocoaPods Trunk"
    echo ""
    echo "To register, run:"
    echo "   pod trunk register your.email@example.com 'Your Name'"
    echo ""
    echo "Then check your email and click the confirmation link."
    echo "After confirming, run this script again."
    exit 1
fi

echo "✅ CocoaPods Trunk registration confirmed"
echo ""

# Ask for confirmation before publishing
echo "⚠️  Ready to publish $PODSPEC_NAME v$VERSION to CocoaPods Trunk"
echo ""
read -p "Do you want to continue? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "❌ Publishing cancelled"
    exit 0
fi

# Push to CocoaPods Trunk
echo "🚀 Step 3: Publishing to CocoaPods Trunk..."
echo "   Running: pod trunk push $PODSPEC_PATH --allow-warnings"
echo ""

if pod trunk push "$PODSPEC_PATH" --allow-warnings; then
    echo ""
    echo "========================================="
    echo "✅ Successfully published!"
    echo "========================================="
    echo ""
    echo "📦 Package: $PODSPEC_NAME"
    echo "🏷️  Version: $VERSION"
    echo "🔗 Homepage: https://founder-os.ai"
    echo ""
    echo "Developers can now install with:"
    echo "   pod '$PODSPEC_NAME', '~> $VERSION'"
    echo ""
    echo "It may take a few minutes for the pod to appear in searches."
    echo "Run 'pod repo update' to refresh the local specs repository."
    echo ""
else
    echo ""
    echo "❌ Publishing failed"
    echo "   Check the errors above for details"
    exit 1
fi
