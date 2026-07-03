import Flutter
import UIKit

@objc(PatrolAxePlugin)
public class PatrolAxePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Native work happens in AxeServerExtension on the Patrol automation server.
  }
}
