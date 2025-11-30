#!/bin/bash

echo "🔍 Testing MobileTracker Network Connectivity"
echo "=============================================="
echo ""

# Build the app
echo "📦 Building app..."
./gradlew assembleDebug

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"
echo ""

# Check if device/emulator is connected
echo "📱 Checking for connected devices..."
adb devices -l

echo ""
echo "🚀 Installing app..."
adb install -r build/outputs/apk/debug/android-debug.apk

if [ $? -ne 0 ]; then
    echo "❌ Installation failed"
    exit 1
fi

echo "✅ App installed"
echo ""

echo "🎯 Starting app..."
adb shell am start -n com.mobiletracker.example/.MainActivity

echo ""
echo "📊 Watching logs (press Ctrl+C to stop)..."
echo "   Looking for MobileTracker, ApiClient, and network activity..."
echo ""

# Clear logcat and start watching
adb logcat -c
adb logcat | grep -E "(MobileTracker|ApiClient|System.out)"
