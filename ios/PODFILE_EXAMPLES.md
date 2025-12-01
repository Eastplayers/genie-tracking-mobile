# Podfile Examples

Example Podfile configurations for different scenarios when using FounderOSMobileTracker.

## Table of Contents

- [Local Development](#local-development)
- [Published Version](#published-version)
- [React Native Projects](#react-native-projects)
- [Native iOS Projects](#native-ios-projects)
- [Testing Specific Versions](#testing-specific-versions)
- [Private Repository](#private-repository)

---

## Local Development

### React Native Project (Local Development)

**File**: `examples/react-native/ios/Podfile`

```ruby
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

target 'YourApp' do
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

  target 'YourAppTests' do
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

### Native iOS Project (Local Development)

**File**: `examples/ios/YourApp/Podfile`

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  # ============================================
  # LOCAL DEVELOPMENT: Use local pod
  # ============================================
  pod 'FounderOSMobileTracker', :path => '../../../ios'

  # ============================================
  # PRODUCTION: Use published pod (comment out local, uncomment this)
  # ============================================
  # pod 'FounderOSMobileTracker', '~> 0.1.0'

  target 'YourAppTests' do
    inherit! :search_paths
  end
end
```

---

## Published Version

### React Native Project (Production)

```ruby
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

target 'YourApp' do
  # Use published version from CocoaPods Trunk
  pod 'FounderOSMobileTracker', '~> 0.1.0'

  config = use_native_modules!
  flags = get_default_flags()

  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => flags[:hermes_enabled],
    :fabric_enabled => flags[:fabric_enabled],
    :flipper_configuration => flipper_config,
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )

  post_install do |installer|
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false
    )
  end
end
```

### Native iOS Project (Production)

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  # Use published version from CocoaPods Trunk
  pod 'FounderOSMobileTracker', '~> 0.1.0'

  target 'YourAppTests' do
    inherit! :search_paths
  end
end
```

---

## React Native Projects

### Minimal React Native Podfile

```ruby
require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

platform :ios, '13.0'

target 'YourApp' do
  config = use_native_modules!

  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => true
  )

  # Add FounderOSMobileTracker
  pod 'FounderOSMobileTracker', '~> 0.1.0'

  post_install do |installer|
    react_native_post_install(installer)
  end
end
```

### React Native with Multiple Targets

```ruby
require_relative '../node_modules/react-native/scripts/react_native_pods'

platform :ios, '13.0'

# Shared pods
def shared_pods
  pod 'FounderOSMobileTracker', '~> 0.1.0'
end

target 'YourApp' do
  config = use_native_modules!
  use_react_native!(:path => config[:reactNativePath])

  shared_pods

  target 'YourAppTests' do
    inherit! :complete
  end
end

target 'YourAppStaging' do
  config = use_native_modules!
  use_react_native!(:path => config[:reactNativePath])

  shared_pods
end
```

---

## Native iOS Projects

### Simple Native iOS App

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  pod 'FounderOSMobileTracker', '~> 0.1.0'
end
```

### Native iOS with Tests

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  pod 'FounderOSMobileTracker', '~> 0.1.0'

  target 'YourAppTests' do
    inherit! :search_paths
    # Test-specific pods
  end

  target 'YourAppUITests' do
    inherit! :search_paths
    # UI test-specific pods
  end
end
```

### Multiple Targets with Shared Pods

```ruby
platform :ios, '13.0'

def shared_pods
  pod 'FounderOSMobileTracker', '~> 0.1.0'
  # Other shared pods
end

target 'YourApp' do
  use_frameworks!
  shared_pods
end

target 'YourAppStaging' do
  use_frameworks!
  shared_pods
end

target 'YourAppDev' do
  use_frameworks!
  shared_pods
end
```

---

## Testing Specific Versions

### Exact Version

```ruby
# Use exactly version 0.1.0
pod 'FounderOSMobileTracker', '0.1.0'
```

### Version Range

```ruby
# Use any version >= 0.1.0 and < 1.0.0
pod 'FounderOSMobileTracker', '~> 0.1.0'

# Use any version >= 0.1.0 and < 0.2.0
pod 'FounderOSMobileTracker', '~> 0.1'

# Use any version >= 0.1.0
pod 'FounderOSMobileTracker', '>= 0.1.0'
```

### Git Branch (Testing Unreleased Features)

```ruby
# Use specific branch
pod 'FounderOSMobileTracker',
    :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git',
    :branch => 'feature/new-feature'
```

### Git Commit (Testing Specific Commit)

```ruby
# Use specific commit
pod 'FounderOSMobileTracker',
    :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git',
    :commit => 'abc123def456'
```

### Git Tag (Testing Specific Release)

```ruby
# Use specific tag
pod 'FounderOSMobileTracker',
    :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git',
    :tag => 'v0.1.0'
```

---

## Private Repository

### Private Git Repository

```ruby
# Using SSH
pod 'FounderOSMobileTracker',
    :git => 'git@github.com:yourorg/mobile-tracking-sdk.git',
    :tag => 'v0.1.0'

# Using HTTPS with token
pod 'FounderOSMobileTracker',
    :git => 'https://YOUR_TOKEN@github.com/yourorg/mobile-tracking-sdk.git',
    :tag => 'v0.1.0'
```

### Private CocoaPods Spec Repository

```ruby
# Add private spec repo
source 'https://github.com/yourorg/private-specs.git'
source 'https://cdn.cocoapods.org/'  # Public specs

platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  # From private repo
  pod 'FounderOSMobileTracker', '~> 0.1.0'
end
```

### Local Podspec (Outside Monorepo)

```ruby
# Reference podspec by URL
pod 'FounderOSMobileTracker',
    :podspec => 'https://raw.githubusercontent.com/yourorg/mobile-tracking-sdk/main/ios/FounderOSMobileTracker.podspec'

# Reference local podspec file
pod 'FounderOSMobileTracker',
    :podspec => '/path/to/FounderOSMobileTracker.podspec'
```

---

## Advanced Configurations

### Conditional Installation

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  # Only install in debug builds
  pod 'FounderOSMobileTracker', '~> 0.1.0', :configurations => ['Debug']

  # Only install in release builds
  # pod 'FounderOSMobileTracker', '~> 0.1.0', :configurations => ['Release']
end
```

### Environment-Based Configuration

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  # Use local pod in development, published in production
  if ENV['USE_LOCAL_POD'] == '1'
    pod 'FounderOSMobileTracker', :path => '../../../ios'
  else
    pod 'FounderOSMobileTracker', '~> 0.1.0'
  end
end
```

Usage:

```bash
# Use local pod
USE_LOCAL_POD=1 pod install

# Use published pod
pod install
```

### Subspecs (If Available)

```ruby
# If the library has subspecs in the future
pod 'FounderOSMobileTracker/Core', '~> 0.1.0'
pod 'FounderOSMobileTracker/Location', '~> 0.1.0'
```

---

## Post-Install Hooks

### Custom Build Settings

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!

  pod 'FounderOSMobileTracker', '~> 0.1.0'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.name == 'FounderOSMobileTracker'
        target.build_configurations.each do |config|
          # Custom build settings for FounderOSMobileTracker
          config.build_settings['SWIFT_VERSION'] = '5.5'
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end
end
```

### Disable Warnings

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'FounderOSMobileTracker'
      target.build_configurations.each do |config|
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
      end
    end
  end
end
```

---

## Troubleshooting Podfiles

### Verify Podfile Syntax

```bash
# Check for syntax errors
pod install --verbose

# Dry run (doesn't actually install)
pod install --no-integrate
```

### Debug Pod Resolution

```bash
# Show detailed resolution process
pod install --verbose

# Update local specs repo first
pod repo update
pod install
```

### Clean Installation

```bash
# Remove all pods and reinstall
rm -rf Pods/ Podfile.lock
pod install

# Clear CocoaPods cache
pod cache clean --all
pod install
```

---

## Best Practices

### 1. Use Version Constraints

✅ **Good**:

```ruby
pod 'FounderOSMobileTracker', '~> 0.1.0'  # Allows 0.1.x updates
```

❌ **Avoid**:

```ruby
pod 'FounderOSMobileTracker'  # No version constraint (uses latest)
```

### 2. Comment Your Podfile

```ruby
# Analytics and tracking
pod 'FounderOSMobileTracker', '~> 0.1.0'

# Networking
pod 'Alamofire', '~> 5.0'
```

### 3. Group Related Pods

```ruby
# Analytics
pod 'FounderOSMobileTracker', '~> 0.1.0'
pod 'Firebase/Analytics'

# UI
pod 'SnapKit', '~> 5.0'
pod 'Kingfisher', '~> 7.0'
```

### 4. Use Shared Pods Function

```ruby
def shared_pods
  pod 'FounderOSMobileTracker', '~> 0.1.0'
  # Other shared pods
end

target 'YourApp' do
  shared_pods
end

target 'YourAppTests' do
  shared_pods
end
```

### 5. Commit Podfile.lock

Always commit `Podfile.lock` to version control to ensure consistent pod versions across team members.

```bash
git add Podfile.lock
git commit -m "Update Podfile.lock"
```

---

## Additional Resources

- [CocoaPods Podfile Syntax](https://guides.cocoapods.org/syntax/podfile.html)
- [CocoaPods Guides](https://guides.cocoapods.org/)
- [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md)
- [PUBLISHING.md](PUBLISHING.md)
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
