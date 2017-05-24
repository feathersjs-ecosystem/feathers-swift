Pod::Spec.new do |s|
  s.name         = "Feathers"
  # Version goes here and will be used to access the git tag later on, once we have a first release.
  s.version      = "5.0.1"
  s.summary      = "Swift framework for interacting with Featherjs apis"
  s.description  = <<-DESC
                   Swift library for connecting to a FeathersJS backend.

                   ReactiveSwift and RxSwift extensions are available.
                   DESC
  s.homepage     = "https://github.com/startupthekid/feathers-swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "startupthekid"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.source       = { :git => "https://github.com/startupthekid/feathers-swift.git", :tag => "#{s.version}" }

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = "Feathers/Core/*.{swift}"
    ss.framework = "Foundation"
    ss.dependency 'KeychainSwift', '8.0.2'
    ss.dependency 'Result'
    ss.dependency "ReactiveSwift"
  end

  s.pod_target_xcconfig = {"OTHER_SWIFT_FLAGS[config=Release]" => "-suppress-warnings" }
end
