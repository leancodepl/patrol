import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

/// Flutter plugin that exposes native Patrol runtime state to Dart.
@objc(PatrolPlugin)
public class PatrolPlugin: NSObject, FlutterPlugin {
  private static let channelName = "pl.leancode.patrol/main"
  private static let getRuntimePortsMethod = "getRuntimePorts"

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #elseif os(macOS)
      let messenger = registrar.messenger
    #endif

    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )

    let instance = PatrolPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case Self.getRuntimePortsMethod:
      let environment = ProcessInfo.processInfo.environment
      var ports = [String: String]()
      ports["testServerPort"] = environment["PATROL_TEST_SERVER_PORT"]
      ports["appServerPort"] = environment["PATROL_APP_SERVER_PORT"]
      result(ports)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
