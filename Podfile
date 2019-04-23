# Initial configuration
platform :ios, '8.0'
inhibit_all_warnings!

def shared_pods
  use_frameworks!
  
  pod 'SwiftyUserDefaults', :git => 'https://github.com/radex/SwiftyUserDefaults/', :tag => '4.0.0-beta.2'
end

target "SwiftySettings" do
  shared_pods
end

target "Example" do
  shared_pods
end

target "Tests" do
    pod 'Quick', '~> 2.0.0'
    pod 'Nimble', '~> 8.0.1'
end
