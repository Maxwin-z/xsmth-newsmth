source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "13.0"

target "newsmth" do
  pod "ReactiveObjC", '~> 2.1.2'
  pod "WKVerticalScrollBar"
  pod 'ActionSheetPicker-3.0', '~> 1.3.10'
  pod 'TOWebViewController', '2.2.8'
  pod 'JPVideoPlayer'
  pod 'ASIHTTPRequest'
  pod 'Alamofire', '~> 5.2'
  pod 'MMKV'
  pod 'Loaf'
end


post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

