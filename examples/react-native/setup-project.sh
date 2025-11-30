#!/bin/bash
set -e

echo "🚀 Setting up React Native Example Project"
echo "==========================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from examples/react-native directory"
    exit 1
fi

# Save current files
echo "📦 Backing up existing files..."
mkdir -p .temp-backup
cp App.tsx .temp-backup/
cp index.js .temp-backup/
cp package.json .temp-backup/
cp tsconfig.json .temp-backup/
cp babel.config.js .temp-backup/
cp metro.config.js .temp-backup/
cp app.json .temp-backup/
cp README.md .temp-backup/

# Initialize React Native project
echo "🔧 Initializing React Native project structure..."
npx react-native init MobileTrackerExample --version 0.72.0 --skip-install

# Move generated folders to current directory
echo "📁 Moving native folders..."
if [ -d "MobileTrackerExample/ios" ]; then
    mv MobileTrackerExample/ios ./
fi

if [ -d "MobileTrackerExample/android" ]; then
    mv MobileTrackerExample/android ./
fi

# Restore our custom files
echo "♻️  Restoring custom files..."
cp .temp-backup/App.tsx ./
cp .temp-backup/index.js ./
cp .temp-backup/package.json ./
cp .temp-backup/tsconfig.json ./
cp .temp-backup/babel.config.js ./
cp .temp-backup/metro.config.js ./
cp .temp-backup/app.json ./
cp .temp-backup/README.md ./

# Clean up
echo "🧹 Cleaning up..."
rm -rf MobileTrackerExample
rm -rf .temp-backup

# Install dependencies
echo "📥 Installing dependencies..."
npm install

# Link the local SDK
echo "🔗 Linking local SDK..."
npm link @mobiletracker/react-native || echo "⚠️  SDK not linked yet. Run 'npm link' from react-native/ directory first"

# iOS setup
if [ -d "ios" ]; then
    echo "🍎 Setting up iOS..."
    
    # Fix .netrc permissions if needed (CocoaPods requirement)
    if [ -f ~/.netrc ]; then
        chmod 600 ~/.netrc 2>/dev/null || true
    fi
    
    cd ios
    
    # Try pod install, if it fails with checksum error, clear cache and retry
    if ! pod install 2>&1; then
        echo "⚠️  Pod install failed, clearing cache and retrying..."
        rm -rf ~/Library/Caches/CocoaPods
        pod cache clean --all 2>/dev/null || true
        pod repo update
        pod install || echo "⚠️  CocoaPods install failed. Make sure CocoaPods is installed: sudo gem install cocoapods"
    fi
    
    cd ..
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Make sure you've built the SDK: cd ../../react-native && npm run build"
echo "2. Link the SDK: cd ../../react-native && npm link"
echo "3. Then from this directory: npm link @mobiletracker/react-native"
echo "4. Run iOS: npm run ios"
echo "5. Run Android: npm run android"
