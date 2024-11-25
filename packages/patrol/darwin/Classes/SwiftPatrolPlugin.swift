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

/// A Flutter plugin that was responsible for communicating the test results back
/// to iOS/macOS XCUITest.
///
/// Since test reports are now sent directly from PatrolBinding to native test runners, this plugin does nothing.
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
    print("Printing the port from ProcessInfo")
    globalPort = Int32(Int(ProcessInfo.processInfo.arguments[2])!)
    print(globalPort)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }
}
