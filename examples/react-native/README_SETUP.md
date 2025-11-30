# 🚀 React Native Example - Setup Required

## ⚠️ Current Status

Your React Native example is **missing native folders**:

```
examples/react-native/
├── ❌ android/          # Missing - needed for Android
├── ❌ ios/              # Missing - needed for iOS
├── ✅ App.tsx
├── ✅ index.js
└── ✅ package.json
```

## 🔧 Quick Fix

Run this one command:

```bash
cd examples/react-native
chmod +x setup-project.sh && ./setup-project.sh
```

This will:

1. ✅ Create iOS and Android native folders
2. ✅ Install dependencies
3. ✅ Link the local SDK
4. ✅ Setup CocoaPods (iOS)

## 📱 Then Run

**iOS:**

```bash
npm run ios
```

**Android:**

```bash
npm run android
```

## 📚 More Info

- **Quick Start**: See `QUICKSTART.md`
- **Detailed Setup**: See `SETUP.md`
- **Full Guide**: See `../../react-native/BUILD_AND_RUN.md`
- **Commands**: See `../../REACT_NATIVE_COMMANDS.md`

## 🤔 Why is this needed?

React Native apps need native code to run on iOS/Android. The `react-native init` command creates these folders, but they're not in git because they're platform-specific and auto-generated.

## 🛠️ Manual Setup

If the script doesn't work:

```bash
# Create temp project
npx react-native init TempProject --version 0.72.0

# Copy native folders
cp -r TempProject/ios ./
cp -r TempProject/android ./

# Clean up
rm -rf TempProject

# Install
npm install
```

## ✅ After Setup

You'll have:

```
examples/react-native/
├── ✅ android/          # Ready for Android
├── ✅ ios/              # Ready for iOS
├── ✅ App.tsx
├── ✅ index.js
└── ✅ package.json
```

Now you can run the app! 🎉
