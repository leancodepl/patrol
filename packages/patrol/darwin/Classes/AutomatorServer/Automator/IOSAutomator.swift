#if PATROL_ENABLED && os(iOS)

import XCTest
import os

class IOSAutomator: Automator {
    private lazy var device: XCUIDevice = {
      return XCUIDevice.shared
    }()

    private lazy var springboard: XCUIApplication = {
      return XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }()

    private lazy var preferences: XCUIApplication = {
      return XCUIApplication(bundleIdentifier: "com.apple.Preferences")
    }()

    private var timeout: TimeInterval = 10

    func configure(timeout: TimeInterval) {
      self.timeout = timeout
    }

    func openApp(_ bundleId: String) throws {
      try runAction("opening app with id \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)
        app.activate()
      }
    }

    private func getApp(withBundleId bundleId: String) throws -> XCUIApplication {
      let app = XCUIApplication(bundleIdentifier: bundleId)
      // TODO: Doesn't work
      // See https://stackoverflow.com/questions/73976961/how-to-check-if-any-app-is-installed-during-xctest
      // guard app.exists else {
      //   throw PatrolError.appNotInstalled(bundleId)
      // }

      return app
    }

    private func runAction<T>(_ log: String, block: @escaping () throws -> T) rethrows -> T {
      return try DispatchQueue.main.sync {
        Logger.shared.i("\(log)...")
        let result = try block()
        Logger.shared.i("done \(log)")
        Logger.shared.i("result: \(result)")
        return result
      }
    }
}

  // MARK: Utilities

  // Adapted from https://samwize.com/2016/02/28/everything-about-xcode-ui-testing-snapshot/
  extension XCUIElement {
    func forceTap() {
      if self.isHittable {
        self.tap()
      } else {
        let coordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
        coordinate.tap()
      }
    }
  }

  extension NativeView {
    static func fromXCUIElement(_ xcuielement: XCUIElement, _ bundleId: String) -> NativeView {
      return NativeView(
        className: getElementTypeName(elementType: xcuielement.elementType),
        text: xcuielement.label,
        contentDescription: xcuielement.accessibilityLabel,
        focused: xcuielement.hasFocus,
        enabled: xcuielement.isEnabled,
        resourceName: xcuielement.identifier,
        applicationPackage: bundleId,
        children: xcuielement.children(matching: .any).allElementsBoundByIndex.map { child in
          return NativeView.fromXCUIElement(child, bundleId)
        })
    }

    static func fromXCUIElementSnapshot(_ xcuielement: XCUIElementSnapshot, _ bundleId: String)
      -> NativeView
    {
      return NativeView(
        className: getElementTypeName(elementType: xcuielement.elementType),
        text: xcuielement.label,
        contentDescription: "",  // TODO: Separate request
        focused: xcuielement.hasFocus,
        enabled: xcuielement.isEnabled,
        resourceName: xcuielement.identifier,
        applicationPackage: bundleId,
        children: xcuielement.children.map { child in
          return NativeView.fromXCUIElementSnapshot(child, bundleId)
        })
    }
  }
#endif
