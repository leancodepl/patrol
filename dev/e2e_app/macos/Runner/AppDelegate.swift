import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private(set) static var patrolMenuActionCount = 0

  @IBAction
  func patrolMenuAction(_ sender: Any?) {
    Self.patrolMenuActionCount += 1
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
