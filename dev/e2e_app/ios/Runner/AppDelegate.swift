import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let mapsApiKey = ProcessInfo.processInfo.environment["MAPS_API_KEY"] ?? "YOUR_API_KEY"
    GMSServices.provideAPIKey(mapsApiKey)
    GeneratedPluginRegistrant.register(with: self)
    
    // Register BrowserStack Camera Injection plugin for image injection on BrowserStack
    BrowserStackCameraInjectionPlugin.register(with: registrar(forPlugin: "BrowserStackCameraInjectionPlugin")!)
    
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
