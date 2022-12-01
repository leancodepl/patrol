import Flutter
import UIKit
import eDistantObject
import Pods_RunnerUITests

let kMethodSubmitTestResults = "submitTestResults"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let patrolChannel = FlutterMethodChannel(name: "pl.leancode.patrol/main", binaryMessenger: controller.binaryMessenger)
    
    patrolChannel.setMethodCallHandler() { call, result  in
      if call.method == kMethodSubmitTestResults {
        let patrolObject = EDOClientService<PatrolSharedObject>.rootObject(withPort: UInt16(8081))
        patrolObject.submitTestResults("This is app under test speaking")
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
