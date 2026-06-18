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
  # Swift sources live in PatrolImpl, the ObjC runner macros in patrol/include.
  # CocoaPods compiles them all into a single `patrol` module (DEFINES_MODULE),
  # so `@import patrol` exposes both — unlike SwiftPM, which requires the split.
  s.source_files = 'patrol/Sources/patrol/**/*.{swift,h,m}', 'patrol/Sources/PatrolImpl/**/*.{swift,h,m}', 'patrol/Sources/HTTPParserC/**/*.{c,h}'
  s.public_header_files = 'patrol/Sources/patrol/include/**/*.h', 'patrol/Sources/HTTPParserC/include/**/*.h'
  # SwiftPM-only files must not be picked up by CocoaPods:
  #  - module.modulemap: CocoaPods generates its own.
  #  - patrol.h: SwiftPM umbrella that `@import PatrolImpl` (a module that only
  #    exists under SwiftPM). Under CocoaPods the runner-macro headers are exposed
  #    directly as public headers and the Swift sources are in the same module.
  s.exclude_files = 'patrol/Sources/patrol/include/module.modulemap', 'patrol/Sources/patrol/include/patrol.h'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.14'
  s.weak_framework = 'XCTest'
  s.ios.framework  = 'UIKit'
  s.osx.framework  = 'AppKit'
  s.resource_bundles = {
    'patrol_privacy' => ['patrol/Sources/PatrolImpl/Resources/PrivacyInfo.xcprivacy']
  }

  # Include localization resources
  s.resources = [
    'patrol/Sources/PatrolImpl/Resources/*.lproj'
  ]

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'CocoaAsyncSocket', '~> 7.6'
end
