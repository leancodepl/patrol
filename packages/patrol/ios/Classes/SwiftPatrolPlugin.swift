import Flutter
import GRPC
import UIKit

let kChannelName = "pl.leancode.patrol/main"
let kMethodAllTestsFinished = "allTestsFinished"

let kErrorCreateChannelFailed = "create_channel_failed"
let kErrorCreateChannelFailedMsg = "Failed to create GRPC channel"

/// A Flutter plugin that's responsible for communicating the test results back
/// to iOS XCUITest.
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
    NSLog("call on patrolChannel: %@", call.method)

    switch call.method {
    case kMethodAllTestsFinished:
      let arguments = (call.arguments ?? [:]) as! [String: Any]
      let results = arguments["results"] as! [String: String]

      let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
      defer {
        try? group.syncShutdownGracefully()
      }

      guard
        let channel = try? GRPCChannelPool.with(
          target: .host("localhost", port: 8081),
          transportSecurity: .plaintext,
          eventLoopGroup: group
        )
      else {
        result(
          FlutterError(
            code: kErrorCreateChannelFailed,
            message: kErrorCreateChannelFailedMsg,
            details: nil
          )
        )
        return
      }

      NSLog("SwiftPatrolPllugin: before creating client")
      let client = Patrol_NativeAutomatorNIOClient(
        channel: channel,
        defaultCallOptions: CallOptions(timeLimit: TimeLimit.timeout(.seconds(10)))
      )

      let call = client.submitTestResults(.with { $0.results = results })

      let status = try! call.status.wait()
      NSLog("SwiftPatrolPlugin: after submitTestResults, status: %@", status.description)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
