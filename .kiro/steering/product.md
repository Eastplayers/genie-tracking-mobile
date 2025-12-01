# Product Overview

## Mobile Tracking SDK

A cross-platform analytics and event tracking SDK for iOS, Android, and React Native applications.

### Core Purpose

Provides simple, reliable event tracking with automatic context enrichment, user identification, session management, and screen tracking capabilities for mobile applications.

### Key Features

- Native iOS SDK (Swift) and Android SDK (Kotlin)
- React Native bridge for cross-platform apps
- Backend session management with automatic creation
- Automatic context enrichment (platform, OS version, timestamps)
- User identification and profile management
- Automatic screen/page view tracking
- Event queueing with automatic delivery
- Dual storage (primary + backup) for data persistence
- Optional geolocation tracking
- Thread-safe operations

### Architecture

"Core SDK + Bridges" approach:

- Native SDKs (iOS & Android) implement all tracking logic
- React Native Bridge provides thin wrapper for JavaScript access
- Events queued in memory and sent via HTTP POST to backend
- Automatic context enrichment across all platforms

### Distribution

- **iOS**: CocoaPods (recommended) and Swift Package Manager
- **Android**: JitPack (recommended) and Maven Central
- **React Native**: npm package with native module auto-linking

### Web Reference

This SDK mirrors the web implementation from `examples/originalWebScript/core/tracker.ts`, maintaining API compatibility and behavior consistency across platforms.
