import Flutter
import UIKit

let kChannelName = "pl.leancode.patrol/main"

let kErrorInvalidValue = "invalid value"
let kErrorInvalidValueMsg = "isInitialRun env var is not a bool"

/// A Flutter plugin that was  responsible for communicating the test results back
/// to iOS XCUITest.
///
/// Since test reports are now sent directly from PatrolBinding to native test runners, this plugin does nothing.
public class SwiftPatrolPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: kChannelName,
      binaryMessenger: registrar.messenger()
    )

    let instance = SwiftPatrolPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
      case "isInitialRun":
      let rawInitialRun = ProcessInfo.processInfo.environment["PATROL_INITIAL_RUN"]
      let initialRun = Bool(rawInitialRun ?? "invalid")
      if initialRun == nil {
        result(FlutterError(
          code: kErrorInvalidValue,
          message: "PATROL_INITIAL_RUN value is invalid: \(String(describing: rawInitialRun))",
          details: nil)
        )
      } else {
        result(initialRun)
      }
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
