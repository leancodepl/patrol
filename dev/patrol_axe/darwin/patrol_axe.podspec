#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'patrol_axe'
  s.version          = '0.0.1'
  s.summary          = 'Deque axe DevTools extension for Patrol.'
  s.description      = <<-DESC
Optional Patrol extension package for axe accessibility scanning in native UI tests.
                       DESC
  s.homepage         = 'https://patrol.leancode.co'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'LeanCode' => 'bartek.pacia@leancode.pl' }
  s.source           = { :path => '.' }
  s.source_files = 'patrol_axe/Sources/PatrolAxe/**/*.{swift,h,m}'
  s.ios.dependency 'Flutter'
  s.ios.dependency 'patrol'
  s.ios.deployment_target = '13.0'
  s.weak_frameworks = ['XCTest', 'axeDevToolsXCUI']
  s.ios.vendored_frameworks = [
    'axe-devtools-ios/axeDevToolsXCUI.xcframework',
  ]
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_SWIFT_FLAGS' => '$(inherited) -D PATROL_ENABLED',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
  s.swift_version = '5.0'
end
