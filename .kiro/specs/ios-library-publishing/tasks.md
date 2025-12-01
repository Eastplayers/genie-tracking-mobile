# Implementation Plan

- [x] 1. Update branding and configuration for founder-os.ai

  - Rename ios/MobileTracker.podspec to ios/FounderOSMobileTracker.podspec
  - Update ios/FounderOSMobileTracker.podspec with founder-os.ai branding:
    - Set name: `'FounderOSMobileTracker'`
    - Set summary: `'Mobile Tracking SDK by founder-os.ai'`
    - Set homepage: `'https://founder-os.ai'`
    - Set author: `{ 'founder-os.ai' => 'contact@founder-os.ai' }`
    - Set source: `{ :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git', :tag => "v#{s.version}" }`
    - Set source_files: `'ios/MobileTracker/**/*.{swift,h,m}'` (monorepo subpath)
  - Update ios/Package.swift metadata (if needed for SPM)
  - Update react-native/MobileTrackerBridge.podspec:
    - Update source URL to `https://github.com/Eastplayers/genie-tracking-mobile.git`
    - Update dependency to `s.dependency "FounderOSMobileTracker"`
  - Ensure version numbers are consistent across all configuration files
  - _Requirements: 1.1, 2.1_

- [ ]\* 1.1 Write property test for Package.swift validation

  - **Property 2: Package Source Completeness**
  - **Validates: Requirements 1.5**

- [ ]\* 1.2 Write unit tests for configuration validation

  - Test Package.swift parsing and structure validation
  - Test podspec parsing and required fields validation
  - Test version format validation (semantic versioning)
  - _Requirements: 1.1, 2.1_

- [x] 2. Implement CocoaPods publishing workflow (Priority for React Native)

  - Validate podspec with monorepo structure: `pod spec lint ios/FounderOSMobileTracker.podspec`
  - Create ios/publish-cocoapods.sh script to validate and push podspec
  - Document CocoaPods Trunk registration process in ios/PUBLISHING.md
  - Create script to push to CocoaPods Trunk: `pod trunk push ios/FounderOSMobileTracker.podspec`
  - Test pod installation in React Native example project (verify monorepo subpath works)
  - Test pod installation in native iOS example project
  - Update README.md with CocoaPods integration instructions:
    - Show: `pod 'FounderOSMobileTracker', '~> 0.1.0'`
    - Show import: `import FounderOSMobileTracker`
  - Document monorepo structure for consumers
  - _Requirements: 2.1, 2.2, 2.3, 2.5, 7.2_

- [ ]\* 2.1 Write unit test for podspec validation

  - Test podspec structure and required metadata
  - Verify podspec name is 'FounderOSMobileTracker'
  - Verify podspec passes `pod spec lint ios/FounderOSMobileTracker.podspec`
  - Verify homepage is 'https://founder-os.ai'
  - Verify source URL is 'https://github.com/Eastplayers/genie-tracking-mobile.git'
  - _Requirements: 2.1, 2.2_

- [ ]\* 2.2 Write integration test for CocoaPods installation

  - Create test React Native consumer project with Podfile using `pod 'FounderOSMobileTracker'`
  - Create test native iOS consumer project with Podfile using `pod 'FounderOSMobileTracker'`
  - Run pod install on both projects
  - Verify workspace creation and library integration
  - Test import statement: `import FounderOSMobileTracker`
  - Build and test both consumer projects
  - _Requirements: 2.5_

- [x] 3. Implement local CocoaPods testing workflow

  - Document local path referencing for CocoaPods development
  - Create example Podfile configurations for local testing
  - Test local pod integration in React Native project
  - Test local pod integration in native iOS project
  - Verify changes are reflected without publishing
  - _Requirements: 4.1, 4.2, 4.3_

- [ ]\* 3.1 Write integration test for local development workflow

  - Test CocoaPods local path reference
  - Verify changes are reflected without publishing
  - Test in both React Native and native iOS contexts
  - _Requirements: 4.1, 4.2, 4.3_

- [ ] 4. Implement Swift Package Manager publishing workflow (Optional - for native iOS only)

  - Create script to validate Package.swift configuration
  - Create script to create and push Git tags with version validation
  - Update README.md with SPM integration instructions:
    - Repository URL: `https://github.com/Eastplayers/genie-tracking-mobile`
    - Import statement: `import MobileTracker` (SPM uses target name, not pod name)
    - Note: SPM not supported for React Native
  - Test SPM resolution with a native iOS test consumer project
  - _Requirements: 1.1, 1.2, 1.3, 7.1_

- [ ]\* 4.1 Write property test for Git tag SPM resolution

  - **Property 1: Git Tag SPM Resolution**
  - **Validates: Requirements 1.2**

- [ ]\* 4.2 Write integration test for SPM publishing

  - Create test native iOS consumer project (not React Native)
  - Add package dependency by URL
  - Verify package resolves and builds successfully
  - Test importing and using library APIs
  - _Requirements: 1.2, 1.3, 1.5_

- [ ] 5. Implement XCFramework build system (Optional - for binary distribution)

  - Create build-xcframework.sh script to build for all architectures
  - Implement iOS device (arm64) build configuration
  - Implement iOS simulator (arm64, x86_64) build configuration
  - Implement XCFramework creation from architecture slices
  - Add checksum calculation for binary distribution
  - Support distribution via CocoaPods as binary pod
  - _Requirements: 3.1, 3.2, 3.5_

- [ ]\* 5.1 Write property test for XCFramework architecture completeness

  - **Property 3: XCFramework Architecture Completeness**
  - **Validates: Requirements 3.1**

- [ ]\* 5.2 Write property test for XCFramework structure

  - **Property 4: XCFramework Single Package Structure**
  - **Validates: Requirements 3.2**

- [ ]\* 5.3 Write property test for API preservation

  - **Property 5: XCFramework API Preservation**
  - **Validates: Requirements 3.5**

- [ ]\* 5.4 Write unit tests for XCFramework validation

  - Test XCFramework directory structure
  - Verify Info.plist files are present
  - Validate framework binaries exist
  - Check architecture slices using lipo/file commands
  - _Requirements: 3.1, 3.2_

- [ ] 6. Implement GitHub Releases distribution (Optional)

  - Create script to build and zip XCFramework
  - Create script to create GitHub Release with XCFramework asset
  - Implement release notes generation from Git history
  - Add version tag validation
  - Update README.md with manual XCFramework integration instructions
  - _Requirements: 5.1, 5.2, 5.4, 5.5, 7.3_

- [ ]\* 6.1 Write property test for GitHub Release asset attachment

  - **Property 6: GitHub Release Asset Attachment**
  - **Validates: Requirements 5.1**

- [ ]\* 6.2 Write property test for release metadata completeness

  - **Property 7: GitHub Release Metadata Completeness**
  - **Validates: Requirements 5.2**

- [ ]\* 6.3 Write property test for version tag correspondence

  - **Property 9: Version Tag Correspondence**
  - **Validates: Requirements 5.5**

- [ ]\* 6.4 Write property test for XCFramework download completeness

  - **Property 8: XCFramework Download Completeness**
  - **Validates: Requirements 5.4**

- [ ] 7. Implement binary CocoaPods distribution support (Optional)

  - Update podspec to support binary framework distribution
  - Create script to generate binary podspec with XCFramework
  - Document switching between source and binary distribution
  - Test binary pod installation in React Native project
  - Test binary pod installation in native iOS project
  - _Requirements: 1.4, 3.3, 5.3_

- [ ]\* 7.1 Write integration test for binary CocoaPods distribution

  - Build and package XCFramework
  - Create binary podspec configuration
  - Test pod install with binary framework
  - Verify binary framework is usable in consumer projects
  - _Requirements: 1.4, 3.3_

- [ ] 8. Create comprehensive documentation for founder-os.ai

  - Create ios/PUBLISHING.md with step-by-step CocoaPods publishing guide
  - Document CocoaPods Trunk registration process
  - Document version update checklist
  - Document troubleshooting for common CocoaPods issues
  - Update README.md with CocoaPods integration instructions (primary)
  - Update README.md with SPM integration instructions (optional, native iOS only)
  - Document React Native integration requirements
  - Document minimum requirements (iOS 13.0, Xcode 12.0, Swift 5.5)
  - Add founder-os.ai branding and contact information
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 9. Checkpoint - Ensure all tests pass

  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Create publishing automation scripts

  - Create publish-cocoapods.sh for automated CocoaPods publishing (priority)
  - Create publish-spm.sh for automated SPM publishing (optional)
  - Create publish-release.sh for automated GitHub Release creation (optional)
  - Create publish-all.sh to orchestrate all publishing methods
  - Add pre-publish validation checks (podspec lint, version consistency)
  - Add founder-os.ai branding validation
  - _Requirements: 1.2, 2.3, 5.1, 5.2_

- [ ]\* 10.1 Write integration test for publishing scripts

  - Test CocoaPods publishing script in isolation
  - Verify version validation works correctly
  - Test error handling for common failure scenarios
  - Verify founder-os.ai URLs are correct
  - _Requirements: 1.2, 2.3, 5.1_

- [ ] 11. Final validation and release preparation

  - Run all unit and integration tests
  - Validate all configuration files have founder-os.ai branding
  - Test CocoaPods publishing end-to-end (priority)
  - Test React Native integration with published pod
  - Test native iOS integration with published pod
  - Optionally test SPM publishing for native iOS apps
  - Create initial release (v0.1.0) via CocoaPods
  - Verify React Native and native iOS consumers can integrate
  - _Requirements: All_

- [ ] 12. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
