import FlutterMacOS
import AppKit

let kChannelName = "pl.leancode.patrol/main"
let kMethodAllTestsFinished = "allTestsFinished"

let kErrorCreateChannelFailed = "create_channel_failed"
let kErrorCreateChannelFailedMsg = "Failed to create GRPC channel"

/// A Flutter plugin that was  responsible for communicating the test results back
/// to iOS XCUITest.
///
/// Since test reports are now sent directly from PatrolBinding to native test runners, this plugin does nothing.
public class SwiftPatrolPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
     let channel = FlutterMethodChannel(
       name: kChannelName,
       binaryMessenger: registrar.messenger
     )

     let instance = SwiftPatrolPlugin()
     registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     result(FlutterMethodNotImplemented)
  }
}
