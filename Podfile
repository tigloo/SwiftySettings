# Initial configuration
platform :ios, '8.0'
inhibit_all_warnings!

def shared_pods
  use_frameworks!
  
  pod 'SwiftyUserDefaults', '5.0.0-beta.5'
end

target "SwiftySettings" do
  shared_pods
end

target "Example" do
  shared_pods
end

target "Tests" do
  shared_pods
  
  pod 'Quick', '~> 2.0.0'
  pod 'Nimble', '~> 8.0.1'
end
