# Local CocoaPods Development Guide

This guide explains how to develop and test the FounderOSMobileTracker library locally using CocoaPods without publishing to the public CocoaPods repository.

## Table of Contents

- [Overview](#overview)
- [Local Path Reference](#local-path-reference)
- [Example Podfile Configurations](#example-podfile-configurations)
- [Testing Workflow](#testing-workflow)
- [Verifying Changes](#verifying-changes)
- [Troubleshooting](#troubleshooting)

---

## Overview

Local CocoaPods development allows you to:

- ✅ Test library changes immediately without publishing
- ✅ Iterate quickly during development
- ✅ Verify integration in both React Native and native iOS projects
- ✅ Debug issues in consumer projects
- ✅ Validate podspec configuration before publishing

### How It Works

Instead of referencing a published pod from CocoaPods Trunk, you reference the local file path to your library. CocoaPods will use the local source files directly.

**Local Reference**:

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

**Published Reference** (for comparison):

```ruby
pod 'FounderOSMobileTracker', '~> 0.1.0'
```

---

## Local Path Reference

### Path Syntax

CocoaPods supports two ways to reference local pods:

#### 1. Relative Path (Recommended)

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

- Path is relative to the Podfile location
- Works when the library and consumer project are in the same repository or nearby
- Portable across different machines if directory structure is consistent

#### 2. Absolute Path

```ruby
pod 'FounderOSMobileTracker', :path => '/Users/yourname/projects/genie-tracking-mobile/ios'
```

- Path is absolute from filesystem root
- Not portable across machines
- Use only for temporary testing

### Path Resolution

The `:path` option should point to the directory containing the `.podspec` file.

**Monorepo Structure**:

```
genie-tracking-mobile/
├── ios/
│   ├── FounderOSMobileTracker.podspec  ← Path should point here
│   ├── MobileTracker/
│   │   └── *.swift
│   └── Package.swift
├── examples/
│   ├── ios/
│   │   └── MobileTrackerExample/
│   │       └── Podfile  ← Reference from here
│   └── react-native/
│       └── ios/
│           └── Podfile  ← Reference from here
```

**From React Native example** (`examples/react-native/ios/Podfile`):

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
# Goes up 3 levels: ios/ → react-native/ → examples/ → root, then into ios/
```

**From native iOS example** (`examples/ios/MobileTrackerExample/Podfile`):

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
# Goes up 3 levels: MobileTrackerExample/ → ios/ → examples/ → root, then into ios/
```

---

## Example Podfile Configurations

### 1. React Native Project

**File**: `examples/react-native/ios/Podfile`

```ruby
# Resolve react_native_pods.rb with node to allow for hoisting
require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', __dir__]).strip

platform :ios, min_ios_version_supported
prepare_react_native_project!

flipper_config = ENV['NO_FLIPPER'] == "1" ? FlipperConfiguration.disabled : FlipperConfiguration.enabled

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
  Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
  use_frameworks! :linkage => linkage.to_sym
end

target 'MobileTrackerExample' do
  # ============================================
  # LOCAL DEVELOPMENT: Use local pod
  # ============================================
  pod 'FounderOSMobileTracker', :path => '../../../ios'

  # ============================================
  # PRODUCTION: Use published pod (comment out local, uncomment this)
  # ============================================
  # pod 'FounderOSMobileTracker', '~> 0.1.0'

  config = use_native_modules!

  flags = get_default_flags()

  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => flags[:hermes_enabled],
    :fabric_enabled => flags[:fabric_enabled],
    :flipper_configuration => flipper_config,
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )

  target 'MobileTrackerExampleTests' do
    inherit! :complete
  end

  post_install do |installer|
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false
    )
  end
end
```

### 2. Native iOS Project

**File**: `examples/ios/MobileTrackerExample/Podfile`

```ruby
platform :ios, '13.0'

target 'MobileTrackerExample' do
  use_frameworks!

  # ============================================
  # LOCAL DEVELOPMENT: Use local pod
  # ============================================
  pod 'FounderOSMobileTracker', :path => '../../../ios'

  # ============================================
  # PRODUCTION: Use published pod (comment out local, uncomment this)
  # ============================================
  # pod 'FounderOSMobileTracker', '~> 0.1.0'

end
```

### 3. New Consumer Project (Outside Monorepo)

If you're testing in a project outside the monorepo:

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  # Use absolute path or relative path to the library
  pod 'FounderOSMobileTracker', :path => '/path/to/genie-tracking-mobile/ios'

  # Or use Git reference with local override
  # pod 'FounderOSMobileTracker', :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git', :branch => 'main'

end
```

### 4. Testing Specific Branch

To test a specific Git branch without local path:

```ruby
pod 'FounderOSMobileTracker', :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git', :branch => 'feature/new-feature'
```

Or a specific commit:

```ruby
pod 'FounderOSMobileTracker', :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git', :commit => 'abc123'
```

---

## Testing Workflow

### Step 1: Make Changes to Library

Edit source files in `ios/MobileTracker/`:

```bash
cd ios/MobileTracker
vim MobileTracker.swift  # Make your changes
```

### Step 2: Test in React Native Project

```bash
# Navigate to React Native example
cd examples/react-native/ios

# Install pods (first time or after Podfile changes)
pod install

# Run the app
cd ..
npx react-native run-ios
```

**What happens**:

- CocoaPods reads the Podfile
- Sees the `:path` reference to local library
- Copies source files from `ios/MobileTracker/` into `Pods/Development Pods/FounderOSMobileTracker/`
- Builds the library with your changes
- Links it into the app

### Step 3: Test in Native iOS Project

```bash
# Navigate to native iOS example
cd examples/ios/MobileTrackerExample

# Install pods (first time or after Podfile changes)
pod install

# Open workspace in Xcode
open MobileTrackerExample.xcworkspace
```

In Xcode:

1. Build the project (⌘B)
2. Run on simulator or device (⌘R)
3. Test your changes

### Step 4: Iterate

After making changes to the library:

**Option A: Rebuild in Xcode**

- Just rebuild the project (⌘B)
- Xcode will recompile the changed files
- No need to run `pod install` again

**Option B: Clean and Reinstall** (if changes aren't reflected)

```bash
# In React Native
cd examples/react-native/ios
rm -rf Pods/ Podfile.lock
pod install

# In native iOS
cd examples/ios/MobileTrackerExample
rm -rf Pods/ Podfile.lock
pod install
```

### Step 5: Validate Before Publishing

Before publishing to CocoaPods:

```bash
# Validate podspec
pod spec lint ios/FounderOSMobileTracker.podspec --allow-warnings

# Run tests
cd ios
swift test

# Test in both example projects
# (Follow steps 2 and 3 above)
```

---

## Verifying Changes

### 1. Check Pod Installation

After running `pod install`, verify the local pod is being used:

```bash
cat Podfile.lock
```

Look for:

```yaml
EXTERNAL SOURCES:
  FounderOSMobileTracker:
    :path: '../../../ios'
```

This confirms CocoaPods is using the local path.

### 2. Inspect Development Pods

The local pod is installed as a "Development Pod":

```bash
ls -la Pods/Development\ Pods/FounderOSMobileTracker/
```

You should see your source files symlinked or copied here.

### 3. Check Xcode Project

In Xcode, expand the `Pods` project in the navigator:

```
Pods
├── Development Pods
│   └── FounderOSMobileTracker
│       └── MobileTracker
│           ├── MobileTracker.swift
│           ├── Configuration.swift
│           └── ...
```

Development Pods are shown separately from regular pods.

### 4. Test Import Statement

In your app code:

```swift
import FounderOSMobileTracker

// Test that you can access the library
let tracker = MobileTracker.shared
```

If the import works and you can access classes, the local pod is correctly integrated.

### 5. Verify Changes Are Reflected

Make a visible change to test:

**In library** (`ios/MobileTracker/MobileTracker.swift`):

```swift
public func testLocalDevelopment() {
    print("🚀 Local development is working!")
}
```

**In app**:

```swift
import FounderOSMobileTracker

MobileTracker.shared.testLocalDevelopment()
```

Rebuild and run. You should see the print statement in the console.

---

## Troubleshooting

### Issue 1: Changes Not Reflected

**Symptom**: You make changes to the library but they don't appear in the app.

**Solutions**:

1. **Clean build folder** (Xcode):

   - Product → Clean Build Folder (⌘⇧K)
   - Rebuild (⌘B)

2. **Reinstall pods**:

   ```bash
   rm -rf Pods/ Podfile.lock
   pod install
   ```

3. **Check symlinks**:

   ```bash
   ls -la Pods/Development\ Pods/FounderOSMobileTracker/
   ```

   If files are symlinked (shown with `→`), changes should be automatic.
   If files are copied, you may need to reinstall pods.

4. **Verify path is correct**:
   ```bash
   cat Podfile.lock | grep -A 5 "EXTERNAL SOURCES"
   ```

### Issue 2: Pod Not Found

**Symptom**: `[!] Unable to find a specification for 'FounderOSMobileTracker'`

**Solutions**:

1. **Check path in Podfile**:

   ```ruby
   pod 'FounderOSMobileTracker', :path => '../../../ios'
   ```

   Verify this path is correct relative to the Podfile location.

2. **Verify podspec exists**:

   ```bash
   ls -la ../../../ios/FounderOSMobileTracker.podspec
   ```

3. **Check podspec name**:
   The podspec filename should match the pod name:
   - File: `FounderOSMobileTracker.podspec`
   - Inside: `s.name = 'FounderOSMobileTracker'`

### Issue 3: Build Errors

**Symptom**: Build fails with compilation errors.

**Solutions**:

1. **Check Swift version**:

   - Library requires Swift 5.5+
   - Verify Xcode version supports this

2. **Check deployment target**:

   - Library requires iOS 13.0+
   - Verify app's deployment target is >= 13.0

3. **Check for syntax errors**:

   ```bash
   cd ios
   swift build
   ```

4. **Validate podspec**:
   ```bash
   pod spec lint ios/FounderOSMobileTracker.podspec --verbose
   ```

### Issue 4: Module Not Found

**Symptom**: `No such module 'FounderOSMobileTracker'`

**Solutions**:

1. **Verify workspace is open** (not project):

   - Open `YourApp.xcworkspace` (not `YourApp.xcodeproj`)
   - The workspace includes both your app and the Pods project

2. **Check framework is linked**:

   - Target → General → Frameworks, Libraries, and Embedded Content
   - Should include `FounderOSMobileTracker.framework`

3. **Clean and rebuild**:
   - Product → Clean Build Folder (⌘⇧K)
   - Product → Build (⌘B)

### Issue 5: React Native Specific Issues

**Symptom**: Pod install fails in React Native project.

**Solutions**:

1. **Update CocoaPods**:

   ```bash
   sudo gem install cocoapods
   ```

2. **Clear React Native cache**:

   ```bash
   cd examples/react-native
   rm -rf node_modules ios/Pods ios/Podfile.lock
   npm install
   cd ios
   pod install
   ```

3. **Check Ruby version**:

   ```bash
   ruby --version  # Should be 2.6+
   ```

4. **Use Bundler** (if available):
   ```bash
   bundle install
   bundle exec pod install
   ```

---

## Switching Between Local and Published

### From Local to Published

When you're ready to use the published version:

1. **Edit Podfile**:

   ```ruby
   # Comment out local path
   # pod 'FounderOSMobileTracker', :path => '../../../ios'

   # Uncomment published version
   pod 'FounderOSMobileTracker', '~> 0.1.0'
   ```

2. **Update pods**:

   ```bash
   pod install
   ```

3. **Verify**:

   ```bash
   cat Podfile.lock
   ```

   Should show:

   ```yaml
   PODS:
     - FounderOSMobileTracker (0.1.0)

   SPEC REPOS:
     trunk:
       - FounderOSMobileTracker
   ```

### From Published to Local

To switch back to local development:

1. **Edit Podfile**:

   ```ruby
   # Comment out published version
   # pod 'FounderOSMobileTracker', '~> 0.1.0'

   # Uncomment local path
   pod 'FounderOSMobileTracker', :path => '../../../ios'
   ```

2. **Update pods**:

   ```bash
   pod install
   ```

3. **Verify**:
   ```bash
   cat Podfile.lock
   ```
   Should show:
   ```yaml
   EXTERNAL SOURCES:
     FounderOSMobileTracker:
       :path: '../../../ios'
   ```

---

## Best Practices

### 1. Use Relative Paths

Always use relative paths in Podfiles that are committed to version control:

✅ **Good**:

```ruby
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

❌ **Bad**:

```ruby
pod 'FounderOSMobileTracker', :path => '/Users/yourname/projects/genie-tracking-mobile/ios'
```

### 2. Document Path Structure

Add comments to Podfiles explaining the path:

```ruby
# Local development: Path goes up 3 levels to repo root, then into ios/
pod 'FounderOSMobileTracker', :path => '../../../ios'
```

### 3. Test Both Platforms

Always test changes in both:

- React Native example project
- Native iOS example project

They may have different integration requirements.

### 4. Validate Before Publishing

Before publishing to CocoaPods:

```bash
# 1. Validate podspec
pod spec lint ios/FounderOSMobileTracker.podspec --allow-warnings

# 2. Run tests
cd ios && swift test

# 3. Test in React Native
cd examples/react-native/ios && pod install && cd .. && npx react-native run-ios

# 4. Test in native iOS
cd examples/ios/MobileTrackerExample && pod install && open MobileTrackerExample.xcworkspace
```

### 5. Keep Podfile.lock in Version Control

For example projects, commit `Podfile.lock`:

```bash
git add examples/react-native/ios/Podfile.lock
git add examples/ios/MobileTrackerExample/Podfile.lock
git commit -m "Update Podfile.lock"
```

This ensures consistent pod versions across team members.

### 6. Use Comments for Switching

Make it easy to switch between local and published:

```ruby
# ============================================
# LOCAL DEVELOPMENT: Use local pod
# ============================================
pod 'FounderOSMobileTracker', :path => '../../../ios'

# ============================================
# PRODUCTION: Use published pod (comment out local, uncomment this)
# ============================================
# pod 'FounderOSMobileTracker', '~> 0.1.0'
```

---

## Quick Reference

### Install Local Pod

```bash
# React Native
cd examples/react-native/ios
pod install

# Native iOS
cd examples/ios/MobileTrackerExample
pod install
```

### Reinstall After Changes

```bash
rm -rf Pods/ Podfile.lock
pod install
```

### Verify Local Pod

```bash
cat Podfile.lock | grep -A 5 "EXTERNAL SOURCES"
```

### Switch to Published

```ruby
# In Podfile, change from:
pod 'FounderOSMobileTracker', :path => '../../../ios'

# To:
pod 'FounderOSMobileTracker', '~> 0.1.0'
```

Then run:

```bash
pod install
```

---

## Additional Resources

- [CocoaPods Guides - Using Pod Lib Create](https://guides.cocoapods.org/making/using-pod-lib-create.html)
- [CocoaPods Podfile Syntax Reference](https://guides.cocoapods.org/syntax/podfile.html)
- [Local Development with CocoaPods](https://guides.cocoapods.org/using/the-podfile.html#using-the-files-from-a-folder-local-to-the-machine)
- [founder-os.ai](https://founder-os.ai)
