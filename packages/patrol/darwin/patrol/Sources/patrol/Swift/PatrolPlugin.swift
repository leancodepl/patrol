import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
  import AppKit
#endif

@objc public class PatrolPlugin: NSObject, FlutterPlugin {
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
      SwiftPatrolPlugin.register(with: registrar)
    }
}