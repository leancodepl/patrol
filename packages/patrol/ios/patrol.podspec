#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# Run `pod lib lint patrol.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'patrol'
  s.version          = '0.0.1'
  s.summary          = 'Adapter for integration tests using Patrol.'
  s.description      = <<-DESC
Runs tests that use flutter_test and patrol APIs as native iOS integration tests.
                       DESC
  s.homepage         = 'https://leancode.pl'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bartek Pacia' => 'bartek.pacia@leancode.pl' }
  s.source           = { :http => 'https://github.com/leancodepl/patrol/tree/master/packages/patrol' }
  s.source_files = 'Classes/**/*'
  # s.public_header_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.weak_framework = 'XCTest'
  s.ios.framework  = 'UIKit'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'Telegraph', '~> 0.30.0'
end
