import GCDWebServer
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var server: GCDWebServer?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    self.server = GCDWebServer()
    self.server?.addDefaultHandler(
      forMethod: "GET", request: GCDWebServerRequest.self,
      processBlock: { request in
        return GCDWebServerDataResponse(text: "Hello World")
      })

    do {
      try server?.start(options: [
        GCDWebServerOption_Port: 8081,
        GCDWebServerOption_BindToLocalhost: true,
      ])
      print("Server started")
    } catch let err {
      print("Failed to start server: \(err)")
    }

    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(
      name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(
    _ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

}
