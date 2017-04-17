Pod::Spec.new do |s|
  s.name         = "Feathers"
  # Version goes here and will be used to access the git tag later on, once we have a first release.
  s.version      = "0.0.1"
  s.summary      = "Swift framework for interacting with featherjs apis"
  s.description  = <<-DESC
                   Swift library for connecting to a FeathersJS backend
                   DESC
  s.homepage     = "https://github.com/startupthekid/feathers-ios"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = "startupthekid"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/startupthekid/feathers-ios.git", :tag => "#{s.version}" }
  # Directory glob for all Swift files
  s.source_files  = "Feathers/*.{swift}"
  s.dependency 'Result', '~> 3.2'
  s.dependency 'PromiseKit', '~> 4.0'
  s.dependency 'Alamofire', '~> 4.4'
  s.dependency 'ReactiveSwift', '~> 1.1'
  s.dependency 'Socket.IO-Client-Swift', '~> 8.3.3'


  s.pod_target_xcconfig = {"OTHER_SWIFT_FLAGS[config=Release]" => "-suppress-warnings" }
end
