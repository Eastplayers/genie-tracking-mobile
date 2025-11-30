require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "MobileTrackerBridge"
  s.version      = package['version']
  s.summary      = package['description']
  s.homepage     = "https://github.com/yourusername/mobile-tracking-sdk"
  s.license      = package['license']
  s.author       = package['author']
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/yourusername/mobile-tracking-sdk.git", :tag => "v#{s.version}" }
  
  s.source_files = "ios/**/*.{h,m,swift}"
  
  s.dependency "React-Core"
  s.dependency "MobileTracker"
end
