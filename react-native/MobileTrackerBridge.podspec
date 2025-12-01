require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "MobileTrackerBridge"
  s.version      = package['version']
  s.summary      = package['description']
  s.homepage     = "https://founder-os.ai"
  s.license      = package['license']
  s.author       = package['author']
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/Eastplayers/genie-tracking-mobile.git", :tag => "v#{s.version}" }
  
  s.source_files = "ios/**/*.{h,m,swift}"
  
  s.dependency "React-Core"
  
  # ============================================================================
  # DEPENDENCY CONFIGURATION
  # ============================================================================
  # For local development, the version requirement should match the local SDK version
  # The Podfile in the example app uses :path to override this with the local SDK
  
  # Version requirement (matches local SDK version 0.1.x)
  s.dependency "FounderOSMobileTracker", "~> 0.1"
  
  # PRODUCTION NOTE: When publishing to production, update this to:
  # s.dependency "FounderOSMobileTracker", "~> 1.0"
  
  # To switch between configurations:
  # 1. Comment out the current dependency line
  # 2. Uncomment the desired dependency line
  # 3. Run 'pod install' in your app directory
  # 4. Clean build folder in Xcode if needed (Cmd+Shift+K)
end
