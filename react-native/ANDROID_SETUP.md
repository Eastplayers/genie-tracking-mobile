# Android Setup for React Native Bridge

The React Native bridge depends on the native Android SDK. There are two ways to set this up:

## Option 1: Local Development (Monorepo)

For local development in this monorepo structure, you need to include the Android SDK module in your app's `settings.gradle`:

```groovy
// In your app's android/settings.gradle
include ':android'
project(':android').projectDir = new File(rootProject.projectDir, '../node_modules/@mobiletracker/react-native/../../android')
```

And add the Kotlin serialization plugin to your app's root `build.gradle`:

```groovy
buildscript {
    dependencies {
        // ... other dependencies
        classpath("org.jetbrains.kotlin:kotlin-serialization:1.9.20")
    }
}
```

## Option 2: Published Package (Recommended for Production)

For production use, the Android SDK should be published as a Maven artifact. Then update `react-native/android/build.gradle` to use:

```groovy
dependencies {
    implementation 'com.mobiletracker:android-sdk:0.1.0'
}
```

## Current Limitation

The current setup requires manual configuration because:

1. The Android SDK uses Kotlin serialization which requires build configuration
2. React Native's Gradle setup has specific requirements that conflict with including external modules
3. The monorepo structure makes it challenging to reference sibling modules

This will be resolved when the Android SDK is published as a proper Maven artifact.
