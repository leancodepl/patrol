import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    registerMacOSTestChannel(messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }

  private func registerMacOSTestChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "pl.leancode.patrol.e2e/macos",
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "showAlert":
        let alert = NSAlert()
        alert.messageText = "Patrol macOS Alert"
        alert.informativeText = "Native NSAlert for Patrol automation"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        result(response == .alertFirstButtonReturn ? "ok" : "cancel")
      case "getPatrolMenuActionCount":
        result(AppDelegate.patrolMenuActionCount)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
