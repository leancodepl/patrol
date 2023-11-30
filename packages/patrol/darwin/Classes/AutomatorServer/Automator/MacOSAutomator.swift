#if PATROL_ENABLED && os(macOS)
import XCTest

class MacOSAutomator: Automator {
    private var timeout: TimeInterval = 10
    
    private lazy var controlCenter: XCUIApplication = {
        return XCUIApplication(bundleIdentifier: "com.apple.controlcenter")
    }()
    
    private lazy var notificationCenter: XCUIApplication = {
        return XCUIApplication(bundleIdentifier: "com.apple.notificationcenterui")
    }()
    
    private lazy var systemPreferences: XCUIApplication = {
        return XCUIApplication(bundleIdentifier: "com.apple.systempreferences")
    }()
    
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

extension NativeView {
    static func fromXCUIElement(_ xcuielement: XCUIElement, _ bundleId: String) -> NativeView
    {
        return NativeView(
            className: String(xcuielement.elementType.rawValue),  // TODO: Provide mapping for names
            text: xcuielement.label,
            contentDescription: "",// TODO:
            focused: false,// TODO:
            enabled: xcuielement.isEnabled,
            resourceName: xcuielement.identifier,
            applicationPackage: bundleId,
            children: xcuielement.children(matching: .any).allElementsBoundByIndex.map { child in
                return NativeView.fromXCUIElement(child, bundleId)
            })
    }
}

#endif
