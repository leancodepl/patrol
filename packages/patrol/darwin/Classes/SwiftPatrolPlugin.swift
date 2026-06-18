import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
  import AppKit
#endif

let kChannelName = "pl.leancode.patrol/main"
let kMethodAllTestsFinished = "allTestsFinished"

let kErrorCreateChannelFailed = "create_channel_failed"
let kErrorCreateChannelFailedMsg = "Failed to create GRPC channel"

/// A Flutter plugin that handles in-process method channel calls from Dart.
///
/// On iOS, this plugin installs AVCaptureSession swizzles for session tracking
/// and handles the `feedInjectedImageToViewfinder` call used by BrowserStack
/// camera image injection for QR scanner testing.
public class SwiftPatrolPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #elseif os(macOS)
      let messenger = registrar.messenger
    #endif

    let channel = FlutterMethodChannel(
      name: kChannelName,
      binaryMessenger: messenger
    )

    let instance = SwiftPatrolPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    #if os(iOS)
      switch call.method {
      case "enableBrowserStackFeatures":
        CameraViewfinderInjector.shared.installSwizzles()
        result(nil)
      case "feedInjectedImageToViewfinder":
        CameraViewfinderInjector.shared.feedInjectedImageToViewfinder { outcome in
          switch outcome {
          case .success:
            result(nil)
          case .failure(let error):
            result(FlutterError(code: "FEED_IMAGE_FAILED", message: error.localizedDescription, details: nil))
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    #else
      result(FlutterMethodNotImplemented)
    #endif
  }
}
