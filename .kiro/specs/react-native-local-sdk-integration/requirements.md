# Requirements Document

## Introduction

This feature establishes proper local development integration between the React Native bridge module and the native Android and iOS Mobile Tracker SDKs. Currently, the React Native bridge has incomplete or missing references to the local native SDKs, making local development and testing difficult. This feature will configure the React Native bridge to properly depend on and reference the local Android library (via Gradle project dependencies) and iOS library (via local CocoaPods path), enabling seamless local development and testing workflows.

## Glossary

- **React Native Bridge**: The JavaScript/TypeScript module that provides React Native bindings to the native Mobile Tracker SDKs
- **Native SDK**: The platform-specific Mobile Tracker implementation (Android or iOS)
- **Local Development**: Development workflow where the React Native bridge references the native SDKs from the local filesystem rather than published artifacts
- **Gradle Project Dependency**: An Android build system mechanism for referencing another local Gradle module
- **CocoaPods Path Dependency**: An iOS dependency manager mechanism for referencing a local pod via filesystem path
- **MobileTrackerBridge**: The React Native bridge module package name

## Requirements

### Requirement 1

**User Story:** As a developer, I want the React Native bridge to properly reference the local Android SDK, so that I can develop and test Android functionality without publishing to remote repositories.

#### Acceptance Criteria

1. WHEN the React Native bridge Android module is built THEN the build system SHALL include the local Android SDK from local Maven repository
2. WHEN changes are made to the Android SDK THEN the developer SHALL publish to local Maven and the React Native bridge SHALL reflect those changes after rebuilding
3. WHEN the React Native example app is built for Android THEN the build system SHALL successfully resolve the Android SDK from mavenLocal repository
4. WHERE local development is configured THEN the Android build.gradle SHALL use mavenLocal repository with the SDK artifact

### Requirement 2

**User Story:** As a developer, I want the React Native bridge to properly reference the local iOS SDK, so that I can develop and test iOS functionality without publishing artifacts.

#### Acceptance Criteria

1. WHEN the React Native bridge iOS module is configured THEN the podspec SHALL reference the local iOS SDK via path dependency
2. WHEN changes are made to the iOS SDK THEN the React Native bridge SHALL reflect those changes without requiring artifact publication
3. WHEN the React Native example app is built for iOS THEN CocoaPods SHALL successfully resolve the iOS SDK through the bridge podspec
4. WHERE local development is configured THEN the MobileTrackerBridge.podspec SHALL declare FounderOSMobileTracker as a local path dependency

### Requirement 3

**User Story:** As a developer, I want to easily switch between local and published SDK dependencies, so that I can test both local changes and production configurations.

#### Acceptance Criteria

1. WHEN the Android build configuration is set for local development THEN the system SHALL use mavenLocal repository for the Android SDK
2. WHEN the Android build configuration is set for production THEN the system SHALL use JitPack Maven repository for the Android SDK
3. WHEN the iOS podspec is configured for local development THEN the system SHALL use path dependencies for the iOS SDK
4. WHEN the iOS podspec is configured for production THEN the system SHALL use published CocoaPods specifications for the iOS SDK
5. WHERE configuration switching is needed THEN the system SHALL provide a simple mechanism to toggle between local and published dependencies through repository configuration

### Requirement 4

**User Story:** As a developer, I want clear documentation on the local development setup, so that I can understand how the React Native bridge integrates with native SDKs and switch between configurations.

#### Acceptance Criteria

1. WHEN a developer reviews the React Native bridge documentation THEN the system SHALL provide clear instructions for local development setup
2. WHEN documentation describes dependencies THEN the system SHALL explain both local development and production configurations
3. WHEN a developer needs to switch between local and published dependencies THEN the documentation SHALL provide step-by-step guidance with specific file changes required
