#if PATROL_ENABLED
import XCTest

class Automator {
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
    
    func openApp(_ bundleId: String) async throws {
        try await runAction("opening app with id \(bundleId)") {
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
    
    // MARK: Services
    
    func enableBluetooth() async throws {
        try await runSystemPreferencesAction("enabling bluetooth") {
            let bluetoothMenuItem = self.systemPreferences.menuItems["Bluetooth"]
            var exists = bluetoothMenuItem.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("BluetoothMenuItem")
            }
            bluetoothMenuItem.tap()
            
            let bluetoothSwitch = self.systemPreferences.switches.firstMatch
            exists = bluetoothSwitch.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("BluetoothSwitch")
            }
            
            if bluetoothSwitch.value! as! NSNumber == 0 {
                bluetoothSwitch.tap()
            } else {
                Logger.shared.i("bluetooth is already enabled")
            }
        }
    }
    
    func disableBluetooth() async throws {
        try await runSystemPreferencesAction("disabling bluetooth") {
            let bluetoothMenuItem = self.systemPreferences.menuItems["Bluetooth"]
            var exists = bluetoothMenuItem.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("BluetoothMenuItem")
            }
            bluetoothMenuItem.tap()
            
            let bluetoothSwitch = self.systemPreferences.switches.firstMatch
            exists = bluetoothSwitch.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("BluetoothSwitch")
            }
            
            if bluetoothSwitch.value! as! NSNumber == 1 {
                bluetoothSwitch.tap()
            } else {
                Logger.shared.i("bluetooth is already disabled")
            }
        }
    }
    
    func getNativeViews(
        byText text: String,
        inApp bundleId: String
    ) async throws -> [NativeView] {
        try await runAction("getting native views matching \(text)") {
            let app = try self.getApp(withBundleId: bundleId)
            
            // The below selector is an equivalent of `app.descendants(matching: .any)[text]`
            // TODO: We should consider more view properties. See #1554
            let format = """
             label == %@ OR \
             title == %@ OR \
             identifier == %@
             """
            let predicate = NSPredicate(format: format, text, text, text)
            let query = app.descendants(matching: .any).matching(predicate)
            let elements = query.allElementsBoundByIndex
            
            let views = elements.map { xcuielement in
                return NativeView.fromXCUIElement(xcuielement, bundleId)
            }
            
            return views
        }
    }
    
    // MARK: Notifications
    
    func openNotifications() async throws {
        try await runAction("opening notifications") {
            let clockItem = self.controlCenter.statusItems["com.apple.menuextra.clock"]
            var exists = clockItem.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("com.apple.menuextra.clock")
            }
            
            clockItem.tap()
        }
    }
    
    func tapOnNotification(byIndex index: Int) async throws {
        try await runAction("tapping on notification at index \(index)") {
            throw PatrolError.methodNotImplemented("tapOnNotification(byIndex)")
        }
    }
    
    func tapOnNotification(bySubstring substring: String) async throws { 
        try await runAction("tapping on notification containing text \(format: substring)") {
            throw PatrolError.methodNotImplemented("tapOnNotification(bySubstring)")
        }
    }
    
    // MARK: Permissions
    
    func isPermissionDialogVisible(timeout: TimeInterval) async -> Bool {
        return false // TODO:
    }
    
    private func runSystemPreferencesAction(_ log: String, block: @escaping () throws -> Void)
    async throws
    {
        try await runAction(log) {
            self.systemPreferences.activate()
            
            try block()
            
            self.systemPreferences.terminate()
        }
    }
    
    private func runAction<T>(_ log: String, block: @escaping () throws -> T) async rethrows -> T {
        return try await MainActor.run {
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
