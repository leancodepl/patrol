#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# Run `pod lib lint patrol.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'patrol'
  s.version          = '0.0.1'
  s.summary          = 'Adapter for integration tests using Patrol.'
  s.description      = <<-DESC
Runs tests that use flutter_test and patrol APIs as native macOS / iOS integration tests.
                       DESC
  s.homepage         = 'https://leancode.pl'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bartek Pacia' => 'bartek.pacia@leancode.pl' }
  s.source           = { :http => 'https://github.com/leancodepl/patrol/tree/master/packages/patrol' }
  s.source_files = [
    'patrol/Sources/patrol/*.swift',
    'patrol/Sources/patrol/*.h',
    'patrol/Sources/patrol/*.c',
    'patrol/Sources/patrol/*.m',
    'patrol/Sources/patrol/**/*.swift',
    'patrol/Sources/patrol/**/*.h',
    'patrol/Sources/patrol/**/*.c',
    'patrol/Sources/patrol/**/*.m'
  ]
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.weak_framework = 'XCTest'
  s.ios.framework  = 'UIKit'
  s.osx.framework  = 'AppKit'
  s.resource_bundles = {
    'patrol_privacy' => ['patrol/PrivacyInfo.xcprivacy']
  }
  
  # Include localization resources
  s.resources = [
    'patrol/Sources/patrol/Resources/*.lproj'
  ]

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
