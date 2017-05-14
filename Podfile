# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Comics-ios' do

  # Pods for ComicReader
  pod 'Alamofire', '~> 4.4'
  pod 'AlamofireImage', '~> 3.2'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.1'
    end
  end
end
