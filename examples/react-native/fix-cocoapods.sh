#!/bin/bash
set -e

echo "🔧 Fixing CocoaPods Issues"
echo "=========================="

# Fix .netrc permissions
if [ -f ~/.netrc ]; then
    echo "📝 Fixing .netrc permissions..."
    chmod 600 ~/.netrc
    echo "✅ .netrc permissions fixed"
fi

# Clear CocoaPods cache
echo "🧹 Clearing CocoaPods cache..."
rm -rf ~/Library/Caches/CocoaPods
pod cache clean --all 2>/dev/null || true
echo "✅ Cache cleared"

# Update pod repo
echo "🔄 Updating pod repo..."
pod repo update
echo "✅ Repo updated"

# Clean and reinstall pods
if [ -d "ios" ]; then
    echo "📦 Reinstalling pods..."
    cd ios
    rm -rf Pods Podfile.lock
    pod install
    cd ..
    echo "✅ Pods installed successfully"
else
    echo "⚠️  ios folder not found. Run setup-project.sh first."
    exit 1
fi

echo ""
echo "✅ All CocoaPods issues fixed!"
echo ""
echo "Now you can run:"
echo "  npm run ios"
