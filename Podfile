# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

def framework_pods
  pod 'Result', '3.2.2'
  pod 'KeychainSwift', '8.0.2'
  pod 'ReactiveSwift', '1.1.3'
  pod 'RxSwift', '3.4.1'
  pod 'PromiseKit', '4.2.0'
end

target 'Feathers-iOS' do
  use_frameworks!
  platform :ios, '8.0'
  framework_pods
  target 'Feathers-iOSTests' do
    inherit! :search_paths
    testing_pods
  end

end

target 'Feathers-macOS' do
  use_frameworks!
  platform :osx, '10.10'
  framework_pods
  target 'Feathers-macOSTests' do
    inherit! :search_paths
    testing_pods
  end

end

target 'Feathers-tvOS' do
  use_frameworks!
  platform :tvos, '9.0'
  framework_pods

  target 'Feathers-tvOSTests' do
    inherit! :search_paths
    testing_pods
  end

end

target 'Feathers-watchOS' do
  use_frameworks!
  platform :watchos, '2.0'
  framework_pods
end
