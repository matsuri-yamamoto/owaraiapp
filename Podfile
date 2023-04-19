# Uncomment the next line to define a global platform for your project
platform :ios, '16.1.1'

install! 'cocoapods',
            :warn_for_unused_master_specs_repo => false

target 'owaraimemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for owaraimemo
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'FirebaseUI/Storage'
  pod 'youtube-ios-player-helper', '1.0.4'
  pod 'TabPageViewController'
  pod 'Tabman', '~> 2.12'
  pod 'MultiAutoCompleteTextSwift'
  pod 'IQKeyboardManagerSwift'
  pod 'OAuthSwift', '~> 2.2.0'
  pod 'FirebaseAuth'
  pod 'KeychainAccess'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Core'
  pod 'FirebaseStorageUI'
  pod 'MXParallaxHeader'
  pod 'FSCalendar'
  pod 'PromiseKit'
  pod 'PINRemoteImage'
  pod 'Onboard'


end


post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end