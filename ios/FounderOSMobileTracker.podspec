Pod::Spec.new do |s|
  s.name             = 'FounderOSMobileTracker'
  s.version          = '0.1.3'
  s.summary          = 'Mobile Tracking SDK by founder-os.ai'
  s.description      = <<-DESC
    A cross-platform analytics and event tracking SDK for iOS applications.
    Provides event tracking, user identification, and screen tracking capabilities.
  DESC

  s.homepage         = 'https://founder-os.ai'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'founder-os.ai' => 'contact@founder-os.ai' }
  s.source           = { :git => 'https://github.com/Eastplayers/genie-tracking-mobile.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.5'

  s.source_files = 'ios/MobileTracker/**/*.{swift,h,m}'
  
  s.frameworks = 'Foundation'
end
