#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# Run `pod lib lint patrol.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'patrol'
  s.version          = '0.0.1'
  s.summary          = 'Adapter for integration tests using Patrol.'
  s.description      = <<-DESC
Runs tests that use flutter_test and patrol APIs as macos integration tests.
                       DESC
  s.homepage         = 'https://leancode.pl'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Damian Cudzik' => 'damian.cudzik@leancode.pl' }
  s.source           = { :http => 'https://github.com/leancodepl/patrol/tree/master/packages/patrol' }
  s.source_files     = 'Classes/**/*'
  # s.public_header_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.weak_framework = 'XCTest'
  s.osx.framework  = 'AppKit'
  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  s.dependency 'Telegraph', '~> 0.30.0'
end
