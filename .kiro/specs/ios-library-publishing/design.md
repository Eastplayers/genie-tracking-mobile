# Design Document: iOS Library Publishing

## Overview

This design document outlines the implementation strategy for publishing the MobileTracker iOS library through multiple distribution channels. The solution provides flexible publishing options to accommodate different use cases: Swift Package Manager for modern native integration, CocoaPods for established ecosystem compatibility, XCFramework distribution for binary deployment, and local/private options for testing and internal use.

The design leverages iOS-native tooling including Swift Package Manager, CocoaPods, xcodebuild, and Git-based distribution mechanisms.

### Quick Answer: Recommended Publishing Method for React Native Support

**CocoaPods is the recommended option for founder-os.ai:**

**Why CocoaPods First:**

- ✅ Required for React Native integration (your primary use case)
- ✅ Works for both React Native and native iOS apps
- ✅ Widely adopted in iOS community
- ✅ Centralized package registry (better discoverability)
- ✅ Your podspec is already configured

**Setup Time:** 30-60 minutes (one-time setup)

- Register email with CocoaPods Trunk (5 min)
- Validate podspec (5 min)
- Push to Trunk (5 min)
- Done! Available to all iOS and React Native developers

**Note:** Swift Package Manager is available as an optional alternative for pure native iOS apps, but CocoaPods is required for React Native support.

## Architecture

### Publishing Pipeline

```
Swift Source Code
    ↓
Build & Test
    ↓
Generate Distribution Artifacts:
  - Swift Package (Package.swift)
  - CocoaPods Spec (.podspec)
  - XCFramework (binary)
    ↓
Publish to Distribution Channel:
  - Swift Package Manager (Git tag)
  - CocoaPods Trunk (pod trunk push)
  - GitHub Releases (XCFramework asset)
  - Private Git Repository
    ↓
Consumers integrate via:
  - Xcode SPM integration
  - pod install
  - Manual XCFramework linking
```

### Distribution Options Comparison

| Method                      | Setup Time    | Registration    | Payment  | React Native Support | Best For                          |
| --------------------------- | ------------- | --------------- | -------- | -------------------- | --------------------------------- |
| **CocoaPods** ⭐            | **30-60 min** | **Yes (email)** | **Free** | **✅ Required**      | **Recommended for founder-os.ai** |
| **Swift Package Manager**   | 5 min         | No              | Free     | ❌ Not supported     | Pure native iOS apps only         |
| **XCFramework (CocoaPods)** | 1 hour        | Yes (email)     | Free     | ✅ Yes               | Binary distribution               |
| **XCFramework (GitHub)**    | 30 min        | No              | Free     | ❌ Manual only       | Manual integration                |
| **Private Git**             | 10 min        | No              | Free     | ✅ Yes (CocoaPods)   | Internal teams                    |
| **Local Development**       | 2 min         | No              | Free     | ✅ Yes               | Testing only                      |

**⭐ RECOMMENDED FOR FOUNDER-OS.AI: CocoaPods**

**Why CocoaPods is the right choice:**

- **React Native requirement**: Your React Native wrapper needs CocoaPods
- **Universal compatibility**: Works for both React Native and native iOS apps
- **Better discoverability**: Centralized registry makes it easy to find
- **Industry standard**: Most iOS libraries use CocoaPods
- **Simple registration**: Just verify your email, no payment or API keys

**Setup time**: 30-60 minutes one-time, then 5 minutes per release

## Components and Interfaces

### 1. Swift Package Manager Configuration

**File**: `ios/Package.swift`

**Current State**: Already configured with:

- Library product definition
- Test targets (unit and property tests)
- SwiftCheck dependency for property-based testing

**Responsibilities**:

- Define package metadata and products
- Specify supported platforms and versions
- Declare dependencies
- Define library and test targets
- Support both source and binary distribution

**Key Configuration**:

```swift
let package = Package(
    name: "MobileTracker",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "MobileTracker", targets: ["MobileTracker"])
    ],
    targets: [
        .target(name: "MobileTracker", path: "MobileTracker"),
        .testTarget(name: "MobileTrackerTests", dependencies: ["MobileTracker"])
    ]
)
```

**Binary Distribution Support**:

```swift
targets: [
    .binaryTarget(
        name: "MobileTracker",
        url: "https://github.com/user/repo/releases/download/0.1.0/MobileTracker.xcframework.zip",
        checksum: "sha256-checksum-here"
    )
]
```

### 2. CocoaPods Configuration

**File**: `ios/MobileTracker.podspec`

**Current State**: Already configured with:

- Version 0.1.0
- iOS 13.0 deployment target
- Swift 5.5 requirement
- Source files specification
- Test spec included

**Responsibilities**:

- Define pod metadata (name, version, description)
- Specify source location and files
- Declare dependencies
- Configure deployment targets
- Define test specifications

**Key Configuration**:

```ruby
Pod::Spec.new do |s|
  s.name             = 'FounderOSMobileTracker'
  s.version          = '0.1.0'
  s.summary          = 'Mobile Tracking SDK by founder-os.ai'
  s.homepage         = 'https://founder-os.ai'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'founder-os.ai' => 'contact@founder-os.ai' }
  s.source           = { :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git', :tag => "v#{s.version}" }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.5'
  s.source_files = 'ios/MobileTracker/**/*.{swift,h,m}'  # Monorepo subpath
end
```

**Note**: The podspec file should be renamed from `MobileTracker.podspec` to `FounderOSMobileTracker.podspec`.

### 3. XCFramework Build System

**Responsibilities**:

- Compile library for multiple architectures
- Create universal framework bundles
- Generate XCFramework from architecture slices
- Calculate checksums for distribution
- Package for distribution

**Build Process**:

```bash
# Build for iOS device (arm64)
xcodebuild archive \
  -scheme MobileTracker \
  -destination "generic/platform=iOS" \
  -archivePath "build/ios.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS simulator (arm64, x86_64)
xcodebuild archive \
  -scheme MobileTracker \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "build/ios-simulator.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
xcodebuild -create-xcframework \
  -framework build/ios.xcarchive/Products/Library/Frameworks/MobileTracker.framework \
  -framework build/ios-simulator.xcarchive/Products/Library/Frameworks/MobileTracker.framework \
  -output build/MobileTracker.xcframework
```

### 4. Version Management

**Responsibilities**:

- Maintain consistent versioning across distribution methods
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Synchronize Git tags with package versions
- Track version history

**Version Locations**:

- `Package.swift`: Implicit from Git tag
- `MobileTracker.podspec`: `s.version` property
- Git tags: `v0.1.0` format
- GitHub Releases: Match Git tags

**Version Update Process**:

1. Update version in `MobileTracker.podspec`
2. Commit changes
3. Create Git tag: `git tag v0.1.0`
4. Push tag: `git push origin v0.1.0`
5. All distribution methods reference this tag

### 5. Distribution Automation Scripts

**Responsibilities**:

- Automate XCFramework building
- Generate checksums for binary distribution
- Create GitHub Releases
- Validate configurations before publishing
- Provide consistent publishing workflow

**Scripts to Create**:

- `build-xcframework.sh`: Build XCFramework for all architectures
- `publish-spm.sh`: Tag and push for SPM distribution
- `publish-cocoapods.sh`: Validate and push to CocoaPods Trunk
- `publish-release.sh`: Create GitHub Release with XCFramework
- `test-local-integration.sh`: Test local integration before publishing

## Data Models

### Package Metadata

```swift
struct PackageMetadata {
    let name: String                    // "MobileTracker"
    let version: SemanticVersion        // "0.1.0"
    let platforms: [Platform]           // [.iOS(.v13)]
    let products: [Product]             // Library products
    let dependencies: [Dependency]      // External dependencies
    let targets: [Target]               // Library and test targets
}

struct SemanticVersion {
    let major: Int
    let minor: Int
    let patch: Int

    var stringValue: String {
        "\(major).\(minor).\(patch)"
    }
}
```

### Distribution Artifact

```swift
struct DistributionArtifact {
    let type: ArtifactType
    let version: SemanticVersion
    let location: URL
    let checksum: String?               // For binary artifacts
    let size: Int64?                    // File size in bytes
}

enum ArtifactType {
    case swiftPackage                   // Git repository
    case cocoapod                       // Podspec + source
    case xcframework                    // Binary framework
    case sourceArchive                  // Zipped source code
}
```

### Integration Configuration

```swift
struct IntegrationConfig {
    let method: IntegrationMethod
    let repositoryURL: URL
    let version: SemanticVersion
    let requiresAuthentication: Bool

    func generateInstructions() -> String {
        // Generate integration instructions for consumers
    }
}

enum IntegrationMethod {
    case swiftPackageManager
    case cocoapods
    case manualXCFramework
    case carthage                       // Future support
}
```

## Data Models

## Correctness Properties

_A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees._

### Property 1: Git Tag SPM Resolution

_For any_ valid semantic version Git tag created in the repository, Swift Package Manager should be able to resolve and fetch that version of the package.
**Validates: Requirements 1.2**

### Property 2: Package Source Completeness

_For any_ package resolution, all Swift source files defined in the target should be accessible and included in the resolved package.
**Validates: Requirements 1.5**

### Property 3: XCFramework Architecture Completeness

_For any_ XCFramework build, the resulting framework should contain architecture slices for iOS device (arm64), iOS simulator (arm64, x86_64), and any other specified platforms.
**Validates: Requirements 3.1**

### Property 4: XCFramework Single Package Structure

_For any_ XCFramework build, all architecture slices should be bundled into a single .xcframework directory structure.
**Validates: Requirements 3.2**

### Property 5: XCFramework API Preservation

_For any_ XCFramework build, all public APIs and symbols declared in the source code should be present and accessible in the compiled binary.
**Validates: Requirements 3.5**

### Property 6: GitHub Release Asset Attachment

_For any_ GitHub Release created for a version, the corresponding XCFramework file should be attached as a release asset.
**Validates: Requirements 5.1**

### Property 7: GitHub Release Metadata Completeness

_For any_ published GitHub Release, it should include version information and release notes in the release description.
**Validates: Requirements 5.2**

### Property 8: XCFramework Download Completeness

_For any_ XCFramework downloaded from a GitHub Release, it should have valid structure with all required Info.plist files and framework binaries.
**Validates: Requirements 5.4**

### Property 9: Version Tag Correspondence

_For any_ GitHub Release, the release version should exactly match the corresponding Git tag version.
**Validates: Requirements 5.5**

## Error Handling

### Build Failures

**Scenario**: XCFramework build fails during compilation

**Handling**:

- Validate Xcode version meets minimum requirements (Xcode 12+)
- Check Swift version compatibility (Swift 5.5+)
- Ensure all source files compile without errors
- Verify deployment target is correctly set
- Check for architecture-specific compilation issues

**Error Messages**:

```
XCFramework build failed: Compilation error in MobileTracker.swift
→ Fix compilation errors before building XCFramework

XCFramework build failed: Unsupported architecture
→ Ensure BUILD_LIBRARY_FOR_DISTRIBUTION=YES is set

XCFramework build failed: Missing framework in archive
→ Verify SKIP_INSTALL=NO in build settings
```

### Publishing Failures

**Scenario**: CocoaPods trunk push fails

**Handling**:

- **Authentication Errors**: Run `pod trunk register` to authenticate
- **Validation Errors**: Run `pod spec lint` to identify issues
- **Version Conflicts**: Ensure version doesn't already exist on Trunk
- **Source Access Errors**: Verify Git tag exists and is accessible

**Error Messages**:

```
CocoaPods push failed: Podspec validation error
→ Run: pod spec lint MobileTracker.podspec --verbose

CocoaPods push failed: Version 0.1.0 already exists
→ Increment version number in podspec and create new tag

CocoaPods push failed: Unable to find Git tag v0.1.0
→ Create and push tag: git tag v0.1.0 && git push origin v0.1.0
```

**Scenario**: Swift Package Manager resolution fails

**Handling**:

- **Tag Not Found**: Verify Git tag exists and is pushed to remote
- **Invalid Package.swift**: Validate syntax with `swift package dump-package`
- **Dependency Conflicts**: Check for version conflicts in dependencies
- **Network Errors**: Verify repository URL is accessible

**Error Messages**:

```
SPM resolution failed: No such tag 'v0.1.0'
→ Create tag: git tag v0.1.0 && git push origin v0.1.0

SPM resolution failed: Invalid Package.swift manifest
→ Validate: swift package dump-package

SPM resolution failed: Repository not found
→ Verify repository URL in Package.swift or consumer's dependency declaration
```

### Version Conflicts

**Scenario**: Attempting to publish a version that already exists

**Handling**:

- CocoaPods: Versions are immutable, must increment version
- SPM: Git tags are mutable but not recommended to change
- GitHub Releases: Can be deleted and recreated if needed

**Resolution**:

- Increment version number following semantic versioning
- Update version in all configuration files (podspec, etc.)
- Create new Git tag with incremented version
- For mistakes, delete tag locally and remotely, then recreate

### Integration Failures

**Scenario**: Consumer project cannot integrate the library

**Handling**:

- **SPM**: Verify repository URL is correct and accessible
- **CocoaPods**: Ensure `pod repo update` has been run
- **XCFramework**: Check that framework is properly linked and embedded
- **Version Mismatch**: Verify version specified matches published version

**Error Messages**:

```
Integration failed: Package not found
→ SPM: Verify repository URL
→ CocoaPods: Run 'pod repo update'

Integration failed: No such module 'MobileTracker'
→ Ensure framework is added to target dependencies
→ Check import statement matches module name

Integration failed: Version 0.1.0 not found
→ Verify version exists: Check Git tags or CocoaPods specs
→ Try: pod search MobileTracker
```

### Checksum Mismatches

**Scenario**: Binary XCFramework checksum doesn't match expected value

**Handling**:

- Recalculate checksum: `swift package compute-checksum MobileTracker.xcframework.zip`
- Update checksum in Package.swift binary target
- Verify file wasn't corrupted during upload
- Ensure correct file was uploaded to GitHub Release

**Error Messages**:

```
Checksum mismatch for binary target
→ Recalculate: swift package compute-checksum MobileTracker.xcframework.zip
→ Update checksum in Package.swift binaryTarget
→ Commit and tag new version
```

## Testing Strategy

### Unit Testing

Unit tests will verify configuration and build artifacts:

1. **Package.swift Validation Tests**

   - Parse Package.swift and verify structure
   - Verify all required fields are present (name, platforms, products, targets)
   - Validate platform version requirements
   - Check dependency declarations

2. **Podspec Validation Tests**

   - Parse podspec file and verify structure
   - Verify required metadata (name, version, summary, homepage, license, author, source)
   - Validate source file patterns
   - Check deployment target and Swift version

3. **Version Consistency Tests**

   - Compare version in podspec with Git tags
   - Verify semantic version format (MAJOR.MINOR.PATCH)
   - Check version consistency across configuration files

4. **XCFramework Structure Tests**
   - Verify XCFramework directory structure
   - Check for required Info.plist files
   - Validate architecture slices are present
   - Verify framework binary exists

### Integration Testing

Integration tests will verify end-to-end publishing and consumption:

1. **Swift Package Manager Integration Test**

   - Create test consumer project
   - Add package dependency by URL
   - Verify package resolves successfully
   - Build consumer project and verify library is usable
   - Test importing and using library APIs

2. **CocoaPods Integration Test**

   - Create test consumer project with Podfile
   - Add pod dependency
   - Run `pod install`
   - Verify workspace is created
   - Build consumer project and verify library is usable

3. **XCFramework Integration Test**

   - Build XCFramework for all architectures
   - Create test consumer project
   - Manually link XCFramework
   - Build for device and simulator
   - Verify correct architecture is selected

4. **Binary SPM Distribution Test**

   - Build and zip XCFramework
   - Calculate checksum
   - Create Package.swift with binary target
   - Test resolution from binary target
   - Verify binary framework is usable

5. **Local Development Test**
   - Reference package by local path in SPM
   - Reference pod by local path in Podfile
   - Make changes to library
   - Verify changes are reflected in consumer project

### Property-Based Testing

Property-based tests will verify universal correctness properties:

1. **Git Tag Resolution Property**

   - Generate random valid semantic versions
   - Create Git tags for each version
   - Verify SPM can resolve each tagged version
   - **Validates: Property 1**

2. **XCFramework Architecture Property**

   - Build XCFramework multiple times
   - For each build, verify all required architectures are present
   - Use `lipo -info` or `file` command to inspect architectures
   - **Validates: Property 3**

3. **API Preservation Property**

   - Extract public API symbols from source code
   - Build XCFramework
   - Extract symbols from binary using `nm` or `otool`
   - Verify all public APIs are present in binary
   - **Validates: Property 5**

4. **Version Correspondence Property**
   - Generate random versions
   - Create Git tag and GitHub Release for each
   - Verify release version matches tag version
   - **Validates: Property 9**

### Manual Testing Checklist

Before releasing to production:

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Package.swift is valid (`swift package dump-package`)
- [ ] Podspec is valid (`pod spec lint`)
- [ ] XCFramework builds successfully for all architectures
- [ ] Test project can integrate via SPM
- [ ] Test project can integrate via CocoaPods
- [ ] Test project can integrate via manual XCFramework
- [ ] All public APIs are accessible
- [ ] Documentation includes all integration methods
- [ ] Version numbers are consistent across all files
- [ ] Git tag is created and pushed
- [ ] GitHub Release is created with XCFramework asset
- [ ] README includes correct integration instructions

## Implementation Details

### Option 1: Swift Package Manager (Recommended for Modern Projects)

**Current State**: Already configured in `ios/Package.swift`

**Setup Steps**:

1. Verify Package.swift is properly configured (already done)

2. Commit all changes and push to GitHub

3. Create and push a Git tag:

```bash
cd ios
git tag v0.1.0
git push origin v0.1.0
```

4. Package is immediately available via SPM

**Consumer Usage**:

In Xcode:

1. File → Add Packages...
2. Enter repository URL: `https://github.com/Eastplayers/genie-tracking-mobile`
3. Select version: `0.1.0`
4. Add to target

Or in Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/Eastplayers/genie-tracking-mobile", from: "0.1.0")
]
```

**Note**: The Package.swift file is located in the `/ios` subdirectory of the monorepo.

**Advantages**:

- Native Xcode integration
- No additional tools required
- Fast setup (< 5 minutes)
- Automatic dependency resolution
- Source-based (fast incremental builds)

**Disadvantages**:

- Requires Xcode 11+ / Swift 5.0+
- Source code is visible
- No centralized package registry (uses Git directly)

### Option 2: CocoaPods (Recommended for Existing CocoaPods Users)

**Current State**: Podspec already exists at `ios/MobileTracker.podspec`

**Setup Steps**:

1. Rename podspec file from `MobileTracker.podspec` to `FounderOSMobileTracker.podspec`

2. Update podspec with founder-os.ai branding and correct repository:

```ruby
s.name = 'FounderOSMobileTracker'
s.summary = 'Mobile Tracking SDK by founder-os.ai'
s.homepage = 'https://founder-os.ai'
s.author = { 'founder-os.ai' => 'contact@founder-os.ai' }
s.source = { :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git', :tag => "v#{s.version}" }
s.source_files = 'ios/MobileTracker/**/*.{swift,h,m}'  # Monorepo subpath
```

2. Validate podspec:

```bash
cd ios
pod spec lint MobileTracker.podspec
```

3. Register with CocoaPods Trunk (first time only):

```bash
pod trunk register your.email@example.com 'Your Name'
# Check email and click confirmation link
```

4. Create and push Git tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

5. Push to CocoaPods Trunk:

```bash
pod trunk push MobileTracker.podspec
```

**Consumer Usage**:

In Podfile:

```ruby
pod 'MobileTracker', '~> 0.1.0'
```

Then run:

```bash
pod install
```

**Advantages**:

- Widely adopted in iOS community
- Centralized package registry
- Good discoverability
- Works with older Xcode versions
- Supports complex dependency scenarios

**Disadvantages**:

- Requires CocoaPods installation
- Longer setup (30-60 minutes first time)
- Generates workspace file
- Source code is visible

### Option 3: XCFramework Distribution (Recommended for Binary Distribution)

**Setup Steps**:

1. Create build script `ios/build-xcframework.sh`:

```bash
#!/bin/bash
set -e

# Clean previous builds
rm -rf build
mkdir -p build

# Build for iOS device
xcodebuild archive \
  -scheme MobileTracker \
  -destination "generic/platform=iOS" \
  -archivePath "build/ios.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS simulator
xcodebuild archive \
  -scheme MobileTracker \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "build/ios-simulator.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
xcodebuild -create-xcframework \
  -framework build/ios.xcarchive/Products/Library/Frameworks/MobileTracker.framework \
  -framework build/ios-simulator.xcarchive/Products/Library/Frameworks/MobileTracker.framework \
  -output build/MobileTracker.xcframework

# Zip for distribution
cd build
zip -r MobileTracker.xcframework.zip MobileTracker.xcframework
cd ..

# Calculate checksum for SPM
swift package compute-checksum build/MobileTracker.xcframework.zip
```

2. Make script executable and run:

```bash
chmod +x ios/build-xcframework.sh
./ios/build-xcframework.sh
```

3. Create GitHub Release and upload XCFramework:

```bash
# Using GitHub CLI
gh release create v0.1.0 \
  build/MobileTracker.xcframework.zip \
  --title "Release 0.1.0" \
  --notes "Initial release"
```

4. (Optional) Update Package.swift to use binary target:

```swift
targets: [
    .binaryTarget(
        name: "MobileTracker",
        url: "https://github.com/user/repo/releases/download/v0.1.0/MobileTracker.xcframework.zip",
        checksum: "checksum-from-build-script"
    )
]
```

**Consumer Usage (Manual)**:

1. Download XCFramework from GitHub Releases
2. Drag into Xcode project
3. Embed in target: Target → General → Frameworks, Libraries, and Embedded Content
4. Set to "Embed & Sign"

**Consumer Usage (SPM with Binary)**:

Same as Option 1, but downloads pre-compiled binary instead of source

**Advantages**:

- Fastest build times for consumers
- Protects source code
- Supports all architectures in single file
- Can be distributed via SPM or manually
- Smaller download size (no source)

**Disadvantages**:

- Longer build process for maintainer
- Requires Xcode 11+
- Debugging is harder without source
- Must rebuild for each release
- Larger file size than source

### Option 4: Local/Private Distribution

**For Local Testing**:

SPM:

```swift
// In consumer's Package.swift
dependencies: [
    .package(path: "../mobile-tracking-sdk/ios")
]
```

CocoaPods:

```ruby
# In consumer's Podfile
pod 'MobileTracker', :path => '../mobile-tracking-sdk/ios'
```

**For Private Repository**:

SPM:

```swift
// In consumer's Package.swift
dependencies: [
    .package(url: "git@github.com:yourorg/mobile-tracking-sdk.git", from: "0.1.0")
]
```

CocoaPods:

```ruby
# In consumer's Podfile
pod 'MobileTracker', :git => 'git@github.com:yourorg/mobile-tracking-sdk.git', :tag => '0.1.0'
```

**Advantages**:

- Full control over distribution
- Can test before public release
- Works for proprietary code
- Same structure as public packages

**Disadvantages**:

- Requires authentication setup
- Not discoverable publicly
- Team members need repository access

## Recommended Approach

For the founder-os.ai iOS library with React Native support, we recommend a **phased approach**:

### Phase 1: CocoaPods (Priority - 1-2 hours)

- Update podspec with founder-os.ai branding and correct URLs
- Register with CocoaPods Trunk (email verification)
- Validate and push podspec
- Test pod installation in React Native project
- Test pod installation in native iOS project
- Update README with CocoaPods instructions

**Why First**: Required for React Native support, works for all iOS developers

### Phase 2: Local Testing (Immediate - 30 minutes)

- Set up local CocoaPods testing workflow
- Create test consumer projects (React Native + native iOS)
- Verify integration works correctly
- Document local development workflow

**Why Second**: Validate everything works before public release

### Phase 3: Swift Package Manager (Optional - 30 minutes)

- Verify existing Package.swift configuration
- Update repository URLs with founder-os.ai branding
- Create and push Git tag v0.1.0
- Test SPM integration in native iOS project
- Update README with SPM instructions (as alternative)

**Why Third**: Provides modern alternative for pure native iOS developers (not React Native)

### Phase 4: XCFramework + Binary Distribution (Optional - 2-3 hours)

- Create build script for XCFramework
- Build and test XCFramework
- Distribute via CocoaPods as binary pod
- Update README with binary integration instructions

**Why Fourth**: Performance optimization for faster builds

### Phase 5: Automation (Long-term - 4-6 hours)

- Create GitHub Actions workflow for automated builds
- Automate CocoaPods publishing on tag push
- Automate XCFramework building
- Set up version validation checks

**Why Last**: Streamlines future releases after manual process is proven

This approach prioritizes React Native compatibility (Phase 1), ensures quality (Phase 2), provides alternatives (Phase 3-4), and adds automation (Phase 5).

## Documentation Requirements

### README Updates

The README.md should include integration instructions for each method:

**Swift Package Manager**:

```markdown
### iOS - Swift Package Manager (Native iOS apps only, not React Native)

In Xcode:

1. File → Add Packages...
2. Enter: `https://github.com/Eastplayers/genie-tracking-mobile`
3. Select version: `0.1.0`

Or in Package.swift:
\`\`\`swift
dependencies: [
.package(url: "https://github.com/Eastplayers/genie-tracking-mobile", from: "0.1.0")
]
\`\`\`

Import in your Swift code:
\`\`\`swift
import MobileTracker // SPM uses the target name from Package.swift
\`\`\`

**Note**: The Package.swift is located in the `/ios` folder of the monorepo.
```

**CocoaPods**:

```markdown
### iOS - CocoaPods

Add to your Podfile:
\`\`\`ruby
pod 'FounderOSMobileTracker', '~> 0.1.0'
\`\`\`

Then run:
\`\`\`bash
pod install
\`\`\`

Import in your Swift code:
\`\`\`swift
import FounderOSMobileTracker
\`\`\`
```

**Manual XCFramework**:

```markdown
### iOS - Manual Integration

1. Download `MobileTracker.xcframework.zip` from [Releases](https://github.com/Eastplayers/genie-tracking-mobile/releases)
2. Unzip and drag `MobileTracker.xcframework` into your Xcode project
3. In target settings → General → Frameworks, Libraries, and Embedded Content
4. Set to "Embed & Sign"
```

### Publishing Guide

Create `ios/PUBLISHING.md` with:

- Step-by-step publishing instructions for each method
- Version update checklist
- Troubleshooting common issues
- Rollback procedures
- Testing requirements before publishing

### Integration Guide

Update documentation to include:

- Minimum iOS version (13.0)
- Minimum Xcode version (12.0)
- Swift version requirement (5.5)
- Required capabilities (if any)
- Common integration issues and solutions
- Migration guides for version updates
