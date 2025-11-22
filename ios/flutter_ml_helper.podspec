#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_ml_helper.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ml_helper'
  s.version          = '0.0.3'
  s.summary          = 'Flutter ML Helper - Easy integration with TensorFlow Lite and ML Kit'
  s.description      = <<-DESC
Easy integration with TensorFlow Lite and ML Kit for Flutter applications. Supports all 6 platforms with WASM compatibility.
                       DESC
  s.homepage         = 'https://github.com/Dhia-Bechattaoui/flutter_ml_helper'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dhia Bechattaoui' => 'bechattaoui.dhiaeddine@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end




