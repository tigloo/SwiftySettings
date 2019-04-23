Pod::Spec.new do |s|
  s.name = 'SwiftySettings'
  s.version = '1.0.5'
  s.license = 'MIT'
  s.summary = 'Declarative in-app settings stack in Swift'
  s.homepage = 'https://github.com/128keaton/SwiftySettings'
  s.authors = { 'Tomasz Gebarowski' => 'gebarowski@gmail.com', 'Keaton Burleson' => 'me@128keaton.com' }
  s.source = { :git => 'https://github.com/128keaton/SwiftySettings.git', :tag => s.version }
  s.ios.deployment_target = '11.0'
  s.source_files = 'Source/**/*.swift'
  s.requires_arc = true
  s.dependency "SwiftyUserDefaults" , '4.0.0-beta.2'
end
