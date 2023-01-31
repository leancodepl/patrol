import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    
    let testName = ProcessInfo.processInfo.environment["PATROL_TEST_NAME"]!
    NSLog("HELLO! Patrol testName: %@", testName)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
