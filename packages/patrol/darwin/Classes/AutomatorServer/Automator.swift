// #if PATROL_ENABLED
import XCTest

protocol Automator {
    func configure(timeout: TimeInterval)
    func openApp(_ bundleId: String) throws
    func getApp(withBundleId bundleId: String) throws -> XCUIApplication
}

extension Automator {
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

// #endif
