Pod::Spec.new do |spec|

  spec.name         = "Skylab"
  spec.version      = "0.0.3"
  spec.summary      = "Skylab SDK"
  spec.license      = { :type => "MIT" }
  spec.author       = { "Amplitude" => "skylab@amplitude.com" }
  spec.homepage     = "https://amplitude.com"
  spec.source       = { :git => "https://github.com/amplitude/skylab-ios-client.git", :tag => "v#{spec.version}" }

  spec.swift_version = '5.0'
  
  spec.ios.deployment_target  = '10.0'
  spec.ios.source_files       = 'Sources/Skylab/**/*.{h,swift}'

  spec.dependency 'Amplitude'

end
