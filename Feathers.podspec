Pod::Spec.new do |s|
  s.name         = "Feathers"
  # Version goes here and will be used to access the git tag later on, once we have a first release.
  s.version      = "0.0.73"
  s.summary      = "Swift framework for interacting with featherjs apis"
  s.description  = <<-DESC
                   Swift library for connecting to a FeathersJS backend.

                   ReactiveSwift and RxSwift extensions are available.
                   DESC
  s.homepage     = "https://github.com/startupthekid/feathers-ios"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = "startupthekid"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/startupthekid/feathers-ios.git", :tag => "#{s.version}" }

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = "Feathers/Core/*.{swift}"
    ss.dependency "Alamofire", '~> 4.4.0'
    ss.framework = "Foundation"
    ss.dependency 'Socket.IO-Client-Swift', '~> 8.3.3'
    ss.dependency 'KeychainSwift'
    ss.dependency 'Result'
  end

  s.subspec "ReactiveSwift" do |ss|
    ss.source_files = "Feathers/ReactiveSwift/*{.swift}"
    ss.dependency "Feathers/Core"
    ss.dependency "ReactiveSwift", "~> 1.1"
  end

  s.subspec "RxSwift" do |ss|
    ss.source_files = "Feathers/RxSwift/*{.swift}"
    ss.dependency "Feathers/Core"
    ss.dependency "RxSwift", "~> 3.0"
  end

  s.pod_target_xcconfig = {"OTHER_SWIFT_FLAGS[config=Release]" => "-suppress-warnings" }
end
