Pod::Spec.new do |s|
  s.name             = 'MobileTracker'
  s.version          = '0.1.0'
  s.summary          = 'Mobile Tracking SDK for iOS'
  s.description      = <<-DESC
    A cross-platform analytics and event tracking SDK for iOS applications.
    Provides event tracking, user identification, and screen tracking capabilities.
  DESC

  s.homepage         = 'https://github.com/yourusername/mobile-tracking-sdk'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/yourusername/mobile-tracking-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.5'

  s.source_files = 'MobileTracker/**/*.{swift,h,m}'
  
  s.frameworks = 'Foundation'
  
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/MobileTrackerTests/**/*.swift'
  end
end
