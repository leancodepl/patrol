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
  
  s.dependency 'gRPC-ProtoRPC', '1.49.0'
  s.dependency 'SwiftNIOPosix', '2.40.0'
  s.pod_target_xcconfig = {
    # This is needed by all pods that depend on Protobuf:
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1',
    # This is needed by all pods that depend on gRPC-RxLibrary:
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }

  src = '/Users/cudzik/Documents/Leancode/patrol/patrol/'
  pods_root = '/Users/cudzik/Documents/Leancode/patrol/patrol/packages/patrol/example/macos/Pods'
  dir = "/Users/cudzik/Documents/Leancode/patrol/patrol/packages/patrol/macos/Classes/AutomatorServer"

  protoc_dir = "#{pods_root}/!ProtoCompiler"
  protoc = "#{protoc_dir}/protoc"
  plugin = "#{pods_root}/!ProtoCompiler-gRPCPlugin/grpc_objective_c_plugin"

  s.dependency '!ProtoCompiler-gRPCPlugin', '~> 1.0'

  # s.prepare_command = <<-CMD
  #   mkdir -p #{dir}
  #   #{protoc} \
  #       --plugin=protoc-gen-grpc=#{plugin} \
  #       --objc_out=#{dir} \
  #       --grpc_out=#{dir} \
  #       -I #{src} \
  #       -I #{protoc_dir} \
  #       #{src}/*.proto
  # CMD

  s.subspec 'Messages' do |ms|
    ms.source_files = "Classes/AutomatorServer/*.pbobjc.{h,m}"
    ms.header_mappings_dir = "Classes/AutomatorServer/"
    ms.requires_arc = false
    
    # The generated files depend on the protobuf runtime.
    ms.dependency 'Protobuf'
  end
end
